# Functional Design Plan — NimUI DSL Macro API

## Unit Information

- **Unit Name**: NimUI Library
- **Description**: SwiftUI-style DSL in Nim with HTML/CSS rendering backend
- **Deliverable**: DSL macro API design document

## Plan

### Step 1: Core DSL Syntax Design

- [ ] Define the top-level `ui` macro entry point signature
- [ ] Design `View` concept (type class / concept in Nim)
- [ ] Design `Text` component API
- [ ] Design `VStack` / `HStack` layout components API
- [ ] Design `Button` component API
- [ ] Define modifier chain pattern (e.g., `.padding()`, `.foregroundColor()`,
      `.font()`)

### Step 2: HTML/CSS Mapping Specification

- [ ] Define HTML element mapping per DSL component
- [ ] Define CSS class/styling strategy per modifier
- [ ] Specify how nested VStack/HStack translate to HTML layout
- [ ] Define how Button's click handler maps to HTML events

### Step 3: Macro Implementation Strategy

- [ ] Specify macro type (template vs AST-based, `macro` vs `template` in Nim)
- [ ] Define AST transformation pipeline (DSL AST → Nim HTML builder calls)
- [ ] Specify compile-time vs runtime evaluation split
- [ ] Define how user-provided code blocks (button actions) are captured

### Step 4: Public API Surface

- [ ] Define module export structure (`nimui.nim`, submodules)
- [ ] Specify import conventions (what users `import`)
- [ ] Define builder pattern for the DSL root

### Step 5: Error Handling & Validation

- [ ] Define compile-time validation for DSL syntax
- [ ] Define error messages for common mistakes
- [ ] Specify unsupported usage patterns that should fail gracefully

## Questions for Design Decisions

Please answer the following questions to guide the functional design:

---

### Q1: Macro Approach — Template vs AST Macro

Nim offers two macro approaches. Which style do you prefer for the DSL?

A) **Template macros** — Lighter weight, uses Nim's `template` for DSL-like
syntax; simpler but less powerful AST manipulation B) **AST macros** (`macro`) —
Full compile-time AST transformation; more powerful, can generate arbitrary
code, better error messages C) **Hybrid** — Templates for simple wrappers, AST
macros for complex transformations (layout nesting, conditional rendering)

[Answer]:

---

### Q2: View Protocol — Type Class vs Concrete Base

How should the `View` concept be modeled?

A) **Concept** (Nim's `concept`) — Define a `View` concept that any type can
implement; max flexibility but more verbose B) **Ref object base** — All views
inherit from a `View` ref object; simpler, consistent but less flexible C) **No
formal View type** — Each component is its own macro; the DSL just produces HTML
strings; simplest approach

[Answer]:

---

### Q3: Modifier Implementation — Method Chain vs Wrapper

How should modifiers (`.padding()`, `.foregroundColor()`) be implemented?

A) **Method chain on views** — Each view type has modifier methods returning
transformed copies; feels natural in Nim with UFCS B) **Wrapper macro** — A
`.modifier(...)` macro that wraps the view AST at compile time C) **Standalone
modifier objects** — Modifiers are separate types applied via an operator like
`view | Modifier.padding(10)`

[Answer]:

---

### Q4: HTML Rendering Strategy

How should the DSL output HTML?

A) **String concatenation at runtime** — Macro expands DSL to Nim code that
builds HTML strings; simplest, fast to prototype B) **Compile-time HTML
generation** — Macro expands DSL directly into HTML string literals at compile
time; zero runtime overhead C) **DOM-like intermediate representation** — DSL
expands to a Nim DOM tree (seq of nodes), then rendered to HTML; enables future
optimization

[Answer]:

---

### Q5: Layout Model — Flexbox vs Grid

For VStack/HStack layout containers, which CSS layout strategy should be used?

A) **CSS Flexbox** — VStack = `flex-direction: column`, HStack =
`flex-direction: row`; standard, well-supported B) **CSS Grid** — All layouts
via CSS Grid; powerful but more complex C) **Both** — Let the renderer choose
based on context; flexible but more implementation work

[Answer]:

---

### Q6: Button Action Handling

How should button click handlers work?

A) **Inline Nim code** — Button action is a Nim code block that gets embedded
directly; simplest MVP approach B) **Callback proc** — Button takes a `proc()`
callback; decouples DSL from event handling C) **Event identifier** — Button
specifies an event name string; external event dispatcher matches and calls
handlers; most flexible

[Answer]:

---

### Q7: Public API — Module Granularity

How should the public API be organized?

A) **Single module** — Everything exported from `nimui.nim`; simplest for users
B) **Submodule per component** — `nimui/text.nim`, `nimui/layout.nim`,
`nimui/button.nim`; cleaner but more imports C) **Flat with optional
submodules** — Main `nimui.nim` re-exports all; power users can import specific
submodules

[Answer]:

---

### Q8: MVP Component Scope — Which additional components?

Beyond Text, VStack, HStack, Button — are there any other components you'd like
in the MVP?

A) **None — keep it minimal** B) **Image** — For rendering images C) **Spacer**
— Flexible spacing helper (common in SwiftUI) D) **ZStack** — Overlay/positioned
layout E) **TextField / Input** — Basic form input F) **List / ForEach** —
Iterative list rendering

[Answer]:
