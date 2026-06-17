# Domain Entities — nimui DSL Type System

## Core Type Hierarchy

```
View (concept)
  │
  ├── TextView
  │     - text: string
  │     - modifiers: seq[Modifier]
  │
  ├── VStackView
  │     - children: seq[View]
  │     - modifiers: seq[Modifier]
  │
  ├── HStackView
  │     - children: seq[View]
  │     - modifiers: seq[Modifier]
  │
  └── ButtonView
        - text: string
        - action: NimNode (AST fragment)
        - modifiers: seq[Modifier]
```

## Entity Definitions

### View (Concept)

The `View` concept defines the minimum interface any UI component must satisfy.

| Property   | Type           | Description                            |
| ---------- | -------------- | -------------------------------------- |
| `render()` | `proc: string` | Returns the HTML string representation |

```nim
type
  View = concept v
    render(v) is string
```

### Modifier

Represents a single CSS style modification applied to a view.

| Field      | Type     | Description                                                     |
| ---------- | -------- | --------------------------------------------------------------- |
| `property` | `string` | CSS property name (e.g., `"padding"`, `"color"`, `"font-size"`) |
| `value`    | `string` | CSS property value (e.g., `"16px"`, `"#ff0000"`)                |

```nim
type
  Modifier = object
    property*: string
    value*: string
```

### ModifiedView[T]

Generic wrapper type that composes a view with additional modifiers.

| Field       | Type            | Description                                    |
| ----------- | --------------- | ---------------------------------------------- |
| `inner`     | `T`             | The wrapped view (must satisfy `View` concept) |
| `modifiers` | `seq[Modifier]` | Additional CSS modifications                   |

```nim
type
  ModifiedView*[T: View] = object
    inner: T
    modifiers: seq[Modifier]
```

### TextView

Renders a string of text as an HTML element.

| Field       | Type            | Description                 |
| ----------- | --------------- | --------------------------- |
| `text`      | `string`        | The text content to display |
| `modifiers` | `seq[Modifier]` | CSS style modifications     |

```nim
type
  TextView* = object
    text*: string
    modifiers*: seq[Modifier]
```

### VStackView / HStackView

Layout containers that arrange children vertically or horizontally.

| Field       | Type              | Description                                        |
| ----------- | ----------------- | -------------------------------------------------- |
| `children`  | `seq[View]`       | Child views to lay out                             |
| `modifiers` | `seq[Modifier]`   | CSS style modifications                            |
| `direction` | `LayoutDirection` | `Vertical` or `Horizontal` (internal; set by type) |

```nim
type
  LayoutDirection* = enum
    ldVertical
    ldHorizontal

  StackView* = object
    children*: seq[View]
    modifiers*: seq[Modifier]
    direction*: LayoutDirection
```

### ButtonView

Interactive clickable element with an associated action.

| Field       | Type            | Description                                      |
| ----------- | --------------- | ------------------------------------------------ |
| `text`      | `string`        | Button label text                                |
| `action`    | `NimNode`       | AST fragment representing the click handler code |
| `modifiers` | `seq[Modifier]` | CSS style modifications                          |

```nim
type
  ButtonView* = object
    text*: string
    action*: NimNode
    modifiers*: seq[Modifier]
```

## Render Output Types

### HtmlDocument

The final output produced by rendering a `ui` block.

| Field          | Type     | Description                           |
| -------------- | -------- | ------------------------------------- |
| `html`         | `string` | Full HTML string                      |
| `inlineStyles` | `string` | CSS styles (inline, embedded in HTML) |

```nim
type
  HtmlDocument* = object
    html*: string
```

## Module-Level Entities

### NimuiConfig (Future / Post-MVP)

Global configuration for the nimui renderer (deferred to post-MVP).

| Field            | Type         | Description                            |
| ---------------- | ------------ | -------------------------------------- |
| `baseFontSize`   | `int`        | Default font size in pixels            |
| `defaultPadding` | `int`        | Default padding value                  |
| `renderMode`     | `RenderMode` | Inline styles vs external CSS (future) |

## Type Relationships

```
View (concept)
  ▲         ▲         ▲         ▲
  │         │         │         │
TextView  StackView  StackView  ButtonView
           (Vertical) (Horizontal)
               ▲          ▲
               │          │
           VStackView  HStackView  (type aliases)
```

**Note**: `VStackView` and `HStackView` are type aliases or instantiated
variants of `StackView` with `direction` set to `ldVertical` and `ldHorizontal`
respectively.
