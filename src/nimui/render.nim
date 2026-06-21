## NimUI/render — HTML rendering for RootView
##
## String concatenation at runtime (Q4 design decision). HTML-escapes user
## text to prevent XSS (BR-07). CSS classes follow `nimui-{kind}-{hash}`
## naming (BR-09).

import core
import std/[strutils, hashes]  # core exports Modifier, RootKind, RootView, Handler
proc htmlEscape*(s: string): string =
  ## Escapes `&`, `<`, `>`, `"`, `'` (BR-07).
  result = newStringOfCap(s.len)
  for c in s:
    case c
    of '&':  result.add("&amp;")
    of '<':  result.add("&lt;")
    of '>':  result.add("&gt;")
    of '"':  result.add("&quot;")
    of '\'': result.add("&#39;")
    else:    result.add(c)

proc cssHash*(kind: RootKind, view: RootView): string =
  ## Deterministic 8-char hash for stable CSS class generation (BR-09).
  var h: Hash = 0
  h = h !& hash(kind.ord)
  case view.kind
  of rkText:
    h = h !& hash(view.text)
  of rkVStack, rkHStack:
    for c in view.children:
      h = h !& hash(c.kind.ord)
  of rkButton:
    h = h !& hash(view.label)
    h = h !& hash(view.handlerId)
  # Include modifiers in the hash to differentiate styles
  for m in view.modifiers:
    h = h !& hash(m.property)
    h = h !& hash(m.value)
  result = $h.abs.toHex[0 ..< min(8, ($h.abs.toHex).len)]

proc styleAttr*(mods: seq[Modifier]): string =
  ## Joins modifiers into a `style="..."` attribute. Empty when no modifiers.
  if mods.len == 0:
    return ""
  # Build the attribute using a pre‑allocated string for efficiency.
  var buf = newStringOfCap(mods.len * 20)  # rough estimate per modifier
  for m in mods:
    buf.add(m.property)
    buf.add(":")
    buf.add(m.value)
    buf.add(";")
  result = " style=\"" & buf & "\""

proc classAttr*(kind: RootKind, view: RootView): string =
  ## BR-09: `nimui-{kind}-{hash}`.
  let kindName = case kind
    of rkText:   "text"
    of rkVStack: "vstack"
    of rkHStack: "hstack"
    of rkButton: "button"
  result = " class=\"nimui-" & kindName & "-" & cssHash(kind, view) & "\""

proc renderRoot*(view: RootView): string =
  ## Renders a RootView to an HTML fragment.
  case view.kind
  of rkText:
    let cls = classAttr(rkText, view)
    let st  = styleAttr(view.modifiers)
    "<span" & cls & st & ">" & htmlEscape(view.text) & "</span>"
  of rkVStack:
    let cls = classAttr(rkVStack, view)
    let st  = styleAttr(@[Modifier(property: "display", value: "flex"),
                          Modifier(property: "flex-direction", value: "column")] &
                        view.modifiers)
    var body = "<div" & cls & st & ">"
    for c in view.children:
      body.add(renderRoot(c))
    body.add("</div>")
    body
  of rkHStack:
    let cls = classAttr(rkHStack, view)
    let st  = styleAttr(@[Modifier(property: "display", value: "flex"),
                          Modifier(property: "flex-direction", value: "row")] &
                        view.modifiers)
    var body = "<div" & cls & st & ">"
    for c in view.children:
      body.add(renderRoot(c))
    body.add("</div>")
    body
  of rkButton:
    let cls = classAttr(rkButton, view)
    let st  = styleAttr(view.modifiers)
    let handlerName = "nimui_handler_" & $view.handlerId
    "<button" & cls & st & " onclick=\"" & handlerName & "()\">" &
      htmlEscape(view.label) & "</button>"

proc renderHandlers*(handlers: seq[Handler]): string =
  ## Generates `<script>` JS function bodies. On `nim js`, the Nim code in
  ## `bodyStmt` is emitted as-is into the function body (BR-12).
  if handlers.len == 0:
    return ""
  var buf = newStringOfCap(handlers.len * 80)
  for h in handlers:
    buf.add("function nimui_handler_" & $h.id & "() {\n")
    if h.bodyStmt.strip().len == 0:
      buf.add("  // no action\n")
    else:
      buf.add("  " & h.bodyStmt & "\n")
    buf.add("}\n")
  buf
