# Business Logic Model — nimui DSL Macro API

## Overview

nimui is a SwiftUI-style declarative UI DSL embedded in Nim via compile-time AST
macros. The DSL expresses UI hierarchies as nested Nim expressions, which are
transformed by macros into HTML/CSS rendering code executed at runtime.

**Compilation Target**: nimui targets the **Nim JS backend** (`nim js`). All DSL
code is compiled to JavaScript and executed in the browser. This enables Button
action blocks (Nim code) to be directly compiled into JavaScript event handlers.

## Macro Transformation Pipeline

```
Source Code (Nim DSL)
      │
      ▼
┌─────────────────────────────┐
│  ui macro (entry point)     │  ← Compile-time: Nim macro
│  - parses DSL block         │
│  - dispatches child nodes   │
└─────────────────────────────┘
      │
      ▼
┌─────────────────────────────┐
│  Per-component macros       │  ← Compile-time: AST transformation
│  - Text("hello")            │
│  - VStack(...)              │
│  - HStack(...)              │
│  - Button("ok", ...)        │
│  - .padding(10)  (UFCS)    │
└─────────────────────────────┘
      │
      ▼
┌─────────────────────────────┐
│  Nim code generation        │  ← Compile-time: outputs Nim code
│  - builds HTML string ops   │
│  - registers event handlers │
└─────────────────────────────┘
      │
      ▼
┌─────────────────────────────┐
│  Runtime HTML rendering     │  ← Runtime: string concatenation
│  - constructs HTML string   │
│  - applies CSS styles       │
│  - returns rendered HTML    │
└─────────────────────────────┘
```

## Core DSL Structure

### Entry Point: `ui` Macro

The `ui` macro is the top-level entry point that wraps a DSL block and produces
a renderable UI.

```nim
ui:
  VStack:
    Text("Hello, World!")
      .padding(16)
    Button(text = "Click Me"):
      echo "Button clicked!"
```

The `ui` macro expands to a Nim expression that:

1. Processes the nested DSL block
2. Builds an internal representation
3. Provides a `.render()` method or similar output mechanism

### Component DSL Pattern

Each component follows a consistent pattern:

- **Constructor call** — e.g., `Text("hello")`, `VStack:`, `HStack:`
- **Modifier chain** — via UFCS, e.g., `.padding(10).foregroundColor("#ff0000")`
- **Child blocks** — layout components (VStack, HStack) accept child DSL blocks
- **Action blocks** — interactive components (Button) accept a code block for
  the action

## View Concept

Defined as a Nim `concept` that any UI component type must satisfy:

```nim
type
  View = concept v
    render(v) is string
```

Any type that implements a `render()` proc returning a `string` satisfies the
`View` concept.

## Component Specifications

### Text

- **Signature**: `Text(text: string): auto`
- **Purpose**: Renders a text string as an HTML `<span>` or `<p>` element
- **Modifiers**: `.font(size: int)`, `.foregroundColor(color: string)`,
  `.padding(value: int)`
- **HTML Output**: `<span style="...">text</span>`

### VStack

- **Signature**: `VStack(children: untyped): auto` (macro with block)
- **Purpose**: Vertical layout container using CSS Flexbox
  (`flex-direction: column`)
- **Children**: Accepts multiple View-producing expressions
- **HTML Output**:
  `<div style="display:flex;flex-direction:column;...">...</div>`

### HStack

- **Signature**: `HStack(children: untyped): auto` (macro with block)
- **Purpose**: Horizontal layout container using CSS Flexbox
  (`flex-direction: row`)
- **Children**: Accepts multiple View-producing expressions
- **HTML Output**: `<div style="display:flex;flex-direction:row;...">...</div>`

### Button

- **Signature**: `Button(text: string, action: untyped): auto` (macro with block
  for action)
- **Purpose**: Interactive clickable element
- **Action**: Inline Nim code block, compiled to JavaScript via Nim JS backend
- **JS Backend**: The action block is emitted as a JavaScript function in the
  generated HTML's `<script>` tag, enabling direct browser execution
- **HTML Output**: `<button onclick="...">text</button>`

## Modifier Chain

Modifiers are implemented as UFCS procs that return a new view instance wrapping
the original with additional styling:

```nim
type
  ModifiedView[T: View] = object
    inner: T
    styles: seq[(string, string)]

proc padding[T: View](v: T, value: int): ModifiedView[T] =
  ModifiedView[T](inner: v, styles: @[("padding", $value & "px")])
```

Each modifier adds CSS style entries. The final `render()` call concatenates all
styles into the HTML element's `style` attribute.

## Module Structure

```
src/
  nimui.nim          # Main module, re-exports all public symbols
  nimui/
    core.nim         # View concept, base types
    text.nim         # Text component
    layout.nim       # VStack, HStack components
    button.nim       # Button component
    modifiers.nim    # Modifier procs (padding, foregroundColor, font)
    render.nim       # HTML rendering logic
```

Users can `import nimui` to get everything, or import specific submodules for
granular control.
