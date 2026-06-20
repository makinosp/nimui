# Requirements — nimui

## Intent Analysis Summary

- **User Request**: SwiftUI-style DSL implemented in Nim
- **Request Type**: New Project (Greenfield)
- **Scope Estimate**: Single Component (Nim library)
- **Complexity Estimate**: Simple to Moderate — DSL design with HTML/CSS
  rendering backend
- **Target Platform**: Web browser (HTML/CSS via webview)
- **Maturity Stage**: Just starting — project structure and build system setup

## Functional Requirements

### FR-01: SwiftUI-like DSL Syntax

The library shall provide a Nim-based domain-specific language (DSL) inspired by
SwiftUI's declarative syntax, enabling users to compose UI hierarchies using
Nim's macro system.

### FR-02: Core UI Components (MVP)

The initial release shall include basic building blocks:

- **View** — base protocol/concept for all UI elements
- **Text** — for rendering text content
- **VStack / HStack** — vertical and horizontal layout containers
- **Button** — interactive clickable element
- Basic modifiers (padding, foreground color, font)

### FR-03: HTML/CSS Rendering Backend

The DSL shall compile/render to HTML and CSS for display in a web browser or
webview environment.

### FR-04: Project Structure

The project shall have a standard Nimble package structure with:

- `src/nimui.nim` — main module entry point
- `src/nimui/` — submodules directory
- `tests/` — test directory
- `nimui.nimble` — package definition

## Non-Functional Requirements

### NFR-01: Developer Experience

- Clean, idiomatic Nim macro API that feels natural to Nim developers
- Minimal boilerplate required to create a UI

### NFR-02: Maintainability

- Modular architecture separating DSL layer from rendering backend
- Well-documented public API

### NFR-03: Testability

- Unit tests for DSL parsing and HTML generation
- Property-based tests not required at this stage

### NFR-04: Compilation Target

- The library targets the **Nim JS backend** (`nim js`) by default
- Button action blocks written in Nim are compiled to JavaScript and executed in the browser
- Nim C backend is not supported in MVP (no browser execution context)

## Out of Scope (MVP)

- State management / reactivity system
- Complex widget library (lists, forms, navigation)
- Animation system
- Cross-platform target (desktop/mobile)
- Accessibility features

## Extension Configuration

All extensions opted out for initial MVP phase (can be enabled later):

- **Resiliency Baseline**: Skipped
- **Security Rules**: Skipped
- **Property-Based Testing**: Skipped

## Key Design Decisions

1. **Nim Macros** — SwiftUI-like syntax is best achieved via Nim's macro system
2. **HTML/CSS Backend** — fastest path to a working rendering target, enabling
   rapid prototyping
3. **MVP First** — start with minimal surface area and expand based on real
   usage
4. **No Frameworks** — no external Nim UI framework dependency; output is pure
   HTML+CSS
