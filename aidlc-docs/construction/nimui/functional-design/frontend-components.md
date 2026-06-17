# Frontend Components — nimui DSL Component Reference

> **Note**: nimui is a UI _library_ (not an application), so "frontend
> components" here refer to the DSL API components that users compose to build
> UIs.

## Component Hierarchy

```
ui
 ├── VStack (vertical flexbox container)
 │    ├── Text
 │    │    └── Modifier chain (.padding, .foregroundColor, .font)
 │    ├── HStack (horizontal flexbox container)
 │    │    ├── Text
 │    │    │    └── Modifier chain
 │    │    ├── Button
 │    │    │    └── [action block: inline Nim code]
 │    │    └── Text
 │    │         └── Modifier chain
 │    └── Button
 │         └── [action block: inline Nim code]
```

## Component API Reference

### `ui` Macro

**Signature**:

```nim
macro ui(body: untyped): untyped
```

**Usage**:

```nim
ui:
  VStack:
    Text("Hello")
```

**Behavior**:

- Entry point macro that wraps the DSL block
- Expands to produce an `HtmlDocument` with a `.render(): string` method

---

### Text

**Signature**:

```nim
macro Text(text: string): untyped
```

**Props**:

| Prop   | Type     | Required | Description                 |
| ------ | -------- | -------- | --------------------------- |
| `text` | `string` | Yes      | The text content to display |

**Modifiers**:

| Modifier           | Signature                         | Description                           |
| ------------------ | --------------------------------- | ------------------------------------- |
| `.padding`         | `.padding(value: int)`            | Adds padding around the text (pixels) |
| `.foregroundColor` | `.foregroundColor(color: string)` | Sets text color (CSS color string)    |
| `.font`            | `.font(size: int)`                | Sets font size (pixels)               |

**HTML Output**: `<span style="...">text</span>`

---

### VStack

**Signature**:

```nim
macro VStack(children: untyped): untyped
```

**Props**: None (all content is child views in the block)

**CSS**: `display: flex; flex-direction: column;`

**HTML Output**: `<div style="display:flex;flex-direction:column;...">...</div>`

---

### HStack

**Signature**:

```nim
macro HStack(children: untyped): untyped
```

**Props**: None (all content is child views in the block)

**CSS**: `display: flex; flex-direction: row;`

**HTML Output**: `<div style="display:flex;flex-direction:row;...">...</div>`

---

### Button

**Signature**:

```nim
macro Button(text: string, action: untyped): untyped
```

**Props**:

| Prop     | Type              | Required | Description                       |
| -------- | ----------------- | -------- | --------------------------------- |
| `text`   | `string`          | Yes      | Button label text                 |
| `action` | `untyped` (block) | Yes      | Inline Nim code executed on click |

**Usage**:

```nim
Button(text = "Click Me"):
  echo "Button was clicked!"
```

**HTML Output**:

```html
<button onclick="nimui_handler_1()">Click Me</button>
<script>
  function nimui_handler_1() {/* user code */}
</script>
```

---

### Modifier Chain (UFCS)

All view types support modifier procs via UFCS (Uniform Function Call Syntax):

```nim
Text("Hello")
  .padding(16)
  .foregroundColor("#333333")
  .font(18)
```

**Available Modifiers (MVP)**:

| Modifier              | CSS Property | Value Format                        |
| --------------------- | ------------ | ----------------------------------- |
| `.padding(n)`         | `padding`    | `{n}px`                             |
| `.foregroundColor(c)` | `color`      | Raw string (e.g., `#ff0000`, `red`) |
| `.font(n)`            | `font-size`  | `{n}px`                             |

## Component Interaction Flow

### 1. User writes DSL code

```nim
let doc = ui:
  VStack:
    Text("Welcome!")
      .padding(16)
    Button(text = "OK"):
      echo "Confirmed"
```

### 2. Macros expand at compile time

The `ui` macro processes the AST, identifies each component and modifier, and
produces Nim code equivalent to:

```nim
let doc = HtmlDocument(
  html: buildHtml(
    VStackView(
      children: @[
        ModifiedView[TextView](
          inner: TextView(text: "Welcome!"),
          modifiers: @[Modifier(property: "padding", value: "16px")]
        ),
        ButtonView(text: "OK", action: ...)
      ]
    )
  )
)
```

### 3. User calls render at runtime

```nim
let htmlString = doc.render()
```

This concatenates the HTML string:

```html
<div style="display:flex;flex-direction:column;">
  <span style="padding:16px;">Welcome!</span>
  <button onclick="nimui_handler_1()">OK</button>
</div>
<script>function nimui_handler_1() { echo "Confirmed" }</script>
```

## User Interaction Model (MVP)

In the MVP, user interaction is limited to:

1. **Button clicks** — Inline Nim code is embedded as JavaScript event handlers
2. **Static rendering** — No state management; each `ui` call produces a fixed
   HTML string
3. **No reactivity** — Re-rendering requires re-executing the `ui` macro (at
   runtime, the Nim code)

## Rendering Output Flow

```
DSL Code (Nim)
    │
    ▼  [compile-time macro expansion]
Nim code with HTML builder calls
    │
    ▼  [compile to executable]
Nim binary
    │
    ▼  [runtime execution]
HTML string output
    │
    ▼  [browser/webview]
Rendered UI
```
