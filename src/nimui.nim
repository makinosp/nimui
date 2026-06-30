## NimUI — SwiftUI-style declarative UI DSL for Nim
##
## Public API entry point. Re-exports the DSL macros and runtime types.
## Compilation target: Nim JS backend (`nim js`). See BR-12.
##
## MVP architecture: all macros (`ui`, `Text`, `VStack`, `HStack`,
## `Button`) and the `View` runtime live in this single module to avoid
## Nim 2.2.4's `=destroy` operator issue on `NimNode` (ref type) when
## macros are split across modules with overlapping `import std/macros`.

from nimui/core import Modifier, RootKind, RootView, Handler, State, StateID, StateObserver, gStateObservers

from nimui/render import renderRoot, renderHandlers, renderStateBindings
import std/macros as macrosMod

when not defined(js) and not defined(nimuiTestMode):
  {.error: "NimUI requires the Nim JS backend. Use `nim js` to compile.".}

type
  UiBuilder* = object
    root*:     RootView
    handlers*: seq[Handler]
    observers*: seq[StateObserver]  ## State observers for reactive binding (FR-S2)
    nextId*:   int

## Thread-local storage for Button handlers during ui macro expansion.
## This avoids the need for a global variable while allowing Button macros
## to register handlers that the ui macro can collect.
var gButtonHandlers* {.threadvar.}: seq[Handler]
var gButtonNextId* {.threadvar.}: int

## State ID counter for generating unique state identifiers
var gStateNextId* {.threadvar.}: int

proc State*[T](initial: T): State[T] =
  ## Creates a reactive state wrapper (FR-S1).
  ## Returns a State[T] object with a unique ID.
  inc gStateNextId
  result = State[T](id: gStateNextId, value: initial, elementIds: @[])

proc bindState*[T](state: var State[T], elementId: string) =
  ## Binds a DOM element ID to this state (FR-S2).
  state.elementIds.add(elementId)

proc render*(b: UiBuilder): string =
  ## Renders a `UiBuilder` to a complete HTML fragment, including any
  ## generated `<script>` event handlers and state bindings (FR-S1..S3).
  let body = renderRoot(b.root)
  var scriptParts: seq[string]
  if b.handlers.len > 0:
    scriptParts.add(renderHandlers(b.handlers))
  if b.observers.len > 0:
    scriptParts.add(renderStateBindings(b.observers))
  if scriptParts.len == 0:
    return body
  result = body
  for part in scriptParts:
    result.add("\n<script>\n")
    result.add(part)
    result.add("\n</script>")

# --- Macros ---------------------------------------------------------------

macro Text*(arg: untyped): untyped =
  ## BR-04: requires a string literal as the first argument.
  ## Also supports State[T] objects for reactive text binding (FR-S2).
  ## Usage: Text("static") or Text(myState.value)
  if arg.kind == nnkStrLit:
    # Static text case
    let lit = arg.strVal
    result = quote do:
      RootView(kind: rkText, text: `lit`, modifiers: @[], elementId: "")
  elif arg.kind == nnkDotExpr and arg[1].eqIdent("value"):
    # State binding case - arg is state.value
    # Generate element ID and register binding
    let elemIdSym = genSym(nskLet, "nimuiElemId")
    let stateSym = arg[0]  # The state variable
    result = quote do:
      block:
        let `elemIdSym` = "nimui_text_" & $`stateSym`.id
        gStateObservers.add(StateObserver(
          stateId: `stateSym`.id,
          elementId: `elemIdSym`,
          updateFn: "nimui_updateElement('" & `elemIdSym` & "', newValue);"
        ))
        RootView(kind: rkText, text: $`stateSym`.value, modifiers: @[], elementId: `elemIdSym`)
  else:
    error("NimUI Error: Text requires a string argument or State.value (BR-04)", arg)

macro VStack*(body: untyped): untyped =
  ## BR-02: VStack requires a block with child views.
  if body.kind != nnkStmtList and body.kind != nnkStmtListExpr:
    error("NimUI Error: VStack requires a block with child views (BR-02)", body)
  # Workaround for Nim 2.x macro hygiene: we bind the children seq
  # to a fresh ident outside of `quote do:` so subsequent
  # `quote do:` blocks reuse the same gensym'd identifier.
  let childrenSym = genSym(nskVar, "nimuiChildren")
  let blockBody = newStmtList()
  blockBody.add newVarStmt(childrenSym, quote do: @[RootView(kind: rkText, text: "", modifiers: @[])])
  # Clear the placeholder
  blockBody[^1] = quote do:
    var `childrenSym`: seq[RootView] = @[]
  for s in body:
    blockBody.add quote do:
      `childrenSym`.add(`s`)
  blockBody.add quote do:
    RootView(kind: rkVStack, children: `childrenSym`, modifiers: @[])
  result = newStmtList(newBlockStmt(blockBody))

macro HStack*(body: untyped): untyped =
  if body.kind != nnkStmtList and body.kind != nnkStmtListExpr:
    error("NimUI Error: HStack requires a block with child views (BR-02)", body)
  let childrenSym = genSym(nskVar, "nimuiChildren")
  let blockBody = newStmtList()
  blockBody.add quote do:
    var `childrenSym`: seq[RootView] = @[]
  for s in body:
    blockBody.add quote do:
      `childrenSym`.add(`s`)
  blockBody.add quote do:
    RootView(kind: rkHStack, children: `childrenSym`, modifiers: @[])
  result = newStmtList(newBlockStmt(blockBody))

macro Button*(text: untyped, action: untyped): untyped =
  ## BR-03: requires a text arg and an action block.
  ## BR-04: text must be a string literal.
  var label = ""
  if text.kind == nnkExprEqExpr and text[0].eqIdent("text"):
    if text[1].kind != nnkStrLit:
      error("NimUI Error: Button requires text = \"...\" string argument (BR-04)", text)
    label = text[1].strVal
  else:
    if text.kind != nnkStrLit:
      error("NimUI Error: Button requires text = \"...\" string argument (BR-04)", text)
    label = text.strVal
  ## Validate that an action block is provided (BR-03)
  if action.kind != nnkStmtList and action.kind != nnkStmtListExpr:
    error("NimUI Error: Button requires an action block (BR-03)", action)
  ## For now we store a placeholder string for the action code. In a full
  ## implementation this would be the source code of the block, compiled to JS.
  let actionCode = "/* action code */"
  result = quote do:
    block:
      inc gButtonNextId
      let hid = gButtonNextId
      gButtonHandlers.add(Handler(id: hid, bodyStmt: `actionCode`))
      RootView(kind: rkButton,
               label: `label`,
               handlerId: hid,
               modifiers: @[])

macro ui*(body: untyped): untyped =
  ## Top-level DSL entry point.
  ## BR-01: the body must contain a single root view expression.
  ## FR-S1: collects state IDs for reactive rendering.
  if body.kind != nnkStmtList and body.kind != nnkStmtListExpr:
    error("NimUI Error: ui block must contain a single root view (BR-01)", body)
  if body.len == 0:
    error("NimUI Error: ui block is empty (BR-01)", body)
  if body.len > 1:
    error("NimUI Error: ui block must contain a single root view (BR-01)", body)
  let rootExpr = body[0]
  result = quote do:
    block:
      gButtonNextId = 0
      gButtonHandlers = @[]
      gStateNextId = 0
      gStateObservers = @[]
      let root = `rootExpr`
      UiBuilder(root: root, handlers: gButtonHandlers, observers: gStateObservers, nextId: gButtonNextId)
