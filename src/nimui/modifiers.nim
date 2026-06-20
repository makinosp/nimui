## nimui/modifiers — UFCS modifier procs
##
## Each modifier appends a CSS key/value pair to the view's `modifiers` seq.
## Modifiers are order-independent at runtime; duplicates take last-wins (BR-05).
## Validation occurs at macro / runtime construction (BR-06).

import core

proc padding*(v: var RootView, value: int) =
  ## Adds a `padding: {value}px` modifier.
  if value < 0:
    raise newException(ValueError, "padding(value) requires a non-negative integer (BR-06)")
  v.modifiers.add(Modifier(property: "padding", value: $value & "px"))

proc foregroundColor*(v: var RootView, color: string) =
  ## Sets the `color` modifier. `color` must be a non-empty CSS color token.
  if color.len == 0:
    raise newException(ValueError, "foregroundColor(color) requires a non-empty CSS color string (BR-06)")
  v.modifiers.add(Modifier(property: "color", value: color))

proc font*(v: var RootView, size: int) =
  ## Sets the `font-size: {size}px` modifier.
  if size <= 0:
    raise newException(ValueError, "font(size) requires a positive integer (BR-06)")
  v.modifiers.add(Modifier(property: "font-size", value: $size & "px"))

## Overloads accepting RootView by value (used inside `Text("...").padding(N)`
## chains). These return a mutated copy to preserve value semantics.
proc padding*(v: RootView, value: int): RootView =
  result = v
  result.padding(value)

proc foregroundColor*(v: RootView, color: string): RootView =
  result = v
  result.foregroundColor(color)

proc font*(v: RootView, size: int): RootView =
  result = v
  result.font(size)
