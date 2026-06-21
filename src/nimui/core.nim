## NimUI/core — Domain entities (View concept, root types, handlers)
##
## Mirrors `aidlc-docs/construction/nimui/functional-design/domain-entities.md`.
##
## Note: We use concrete object kinds (RootKind enum + RootView variant) instead
## of Nim `concept` because macros cannot easily pattern-match on concepts.
## The `View` concept is provided for documentation/duck-typing convenience
## only.

type
  Modifier* = object
    ## A single CSS property/value pair (BR-05, BR-06).
    property*: string
    value*:    string

  RootKind* = enum
    rkText
    rkVStack
    rkHStack
    rkButton

  RootView* = object
    ## Sum-type root representation produced by the macros.
    ## `modifiers` is hoisted out of the `case` branches because Nim's
    ## `object case` forbids fields that share names across branches.
    modifiers*: seq[Modifier]
    case kind*: RootKind
    of rkText:
      text*: string
    of rkVStack, rkHStack:
      children*: seq[RootView]
    of rkButton:
      label*:     string
      handlerId*: int           ## index into UiBuilder.handlers (BR-08)

  Handler* = object
    ## A generated event handler. Compiled to a JS function on `nim js`.
    id*:       int
    bodyStmt*: string          ## Nim source of the action block (for inspection/tests)

## Documentation-only View concept (see domain-entities.md).
## Not used for dispatch — see RootView above.
{.hint[XDeclaredButNotUsed]: off.}
type
  View* = concept v
    render(v) is string
