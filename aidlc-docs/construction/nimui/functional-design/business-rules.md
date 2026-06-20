# Business Rules — nimui DSL Macro Constraints

## DSL Syntax Rules

### BR-01: Only One Root Element

The `ui` macro block must contain exactly one root element (a single VStack,
HStack, or other view).

- **Validation**: Compile-time error if block contains multiple top-level
  expressions in sequence
- **Error Message**: `nimui Error: ui block must contain a single root view`

### BR-02: Well-Formed Component Nesting

Layout components (VStack, HStack) must use Nim's block syntax (`:` + indented
body).

- **Validation**: Compile-time check that the macro receives a valid statement
  list
- **Error Message**:
  `nimui Error: VStack/HStack requires a block with child views`

### BR-03: Button Must Have Action Block

Button requires both a `text` argument and an action code block.

- **Validation**: Compile-time detection of missing action block
- **Error Message**: `nimui Error: Button requires an action block`

### BR-04: Text Requires String Argument

Text must receive a string literal as its first argument.

- **Validation**: Compile-time check for string literal type
- **Error Message**: `nimui Error: Text requires a string argument`

## Modifier Rules

### BR-05: Modifier Chain Order Independence

Modifiers can be chained in any order; the final rendered style is the union of
all applied modifiers.

- **Implementation**: Each modifier adds to a key-value style list; no
  order-dependent override (last-wins for duplicate keys)

### BR-06: Modifier Validation

Modifier values are validated at compile time where possible:

- `padding(value)` — value must be a non-negative integer
- `font(size)` — size must be a positive integer
- `foregroundColor(color)` — color must be a valid CSS color string (basic hex
  validation)

## HTML Output Rules

### BR-07: Safe HTML Text

Text content is HTML-escaped to prevent XSS.

- **Characters escaped**: `<`, `>`, `&`, `"`, `'`
- **Implementation**: Runtime escaping in the render proc

### BR-08: Unique Event Handler IDs

Each Button generates a unique onclick handler ID to avoid conflicts when
multiple buttons exist in the same UI.

- **Implementation**: Counter or UUID-based ID generation at macro expansion
  time

### BR-09: Consistent CSS Class Naming

Generated CSS classes follow the pattern `nimui-{component}-{hash}` to avoid
conflicts with user-defined styles.

## Compile-Time Rules

### BR-10: Macro Expansion Order

The `ui` macro expands top-down: the parent macro processes children
recursively, ensuring nested components are evaluated before their parent.

### BR-11: No Runtime Type Dispatch

All view type resolution happens at compile time via macro expansion. No runtime
type introspection is used for rendering dispatch.

### BR-12: JS Backend Compilation Target

The nimui library requires the **Nim JS backend** (`nim js`) for compilation.

- **Rationale**: Button action blocks contain Nim code that must be compiled to
  JavaScript for browser execution
- **Constraint**: The library is not guaranteed to function correctly with the
  Nim C backend (C code cannot run in browser context)
- **Build Command**: `nim js -c src/nimui.nim` (or via Nimble with a custom
  task)
- **Validation**: Header check in `nimui.nim` — compile-time error if not
  compiling with `nim js`

## Future Constraints (Post-MVP)

### BR-F1: No State Management in MVP

State management, reactivity, and two-way data binding are out of scope for the
MVP. The library produces static HTML output only.

### BR-F2: No Dynamic Updates in MVP

The MVP does not support dynamic re-rendering or DOM diffing. Each `ui` block
produces a static HTML fragment.

### BR-F3: Minimal CSS in MVP

The MVP generates inline styles only. External stylesheet generation is deferred
to post-MVP.
