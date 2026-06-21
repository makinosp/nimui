# nimui

**SwiftUI-style declarative UI DSL for Nim** — targets HTML/CSS via the Nim JS backend.

nimui lets you build web frontends entirely in Nim. Describe your UI with a declarative DSL inspired by SwiftUI, compile it to JavaScript with `nim js`, and render it in the browser.

## Features

- **Declarative DSL** — `Text`, `VStack`, `HStack`, `Button` with a SwiftUI-like syntax
- **Modifier chains** — `.padding()`, `.foregroundColor()`, `.font()` and more
- **HTML/CSS output** — renders to semantic HTML with inline styles and hashed CSS classes
- **XSS-safe** — user text is HTML-escaped by default
- **Event handlers** — `Button` actions compile to JavaScript `<script>` blocks
- **Zero runtime dependencies** — ships a single JS file

## Requirements

- Nim >= 1.6.0

## Quick Start

### Install

```bash
nimble install nimui
```

### Write a UI

```nim
import nimui
import nimui/modifiers

let doc = ui:
  VStack:
    Text("Hello, World!")
      .padding(16)
      .foregroundColor("#333")
      .font(24)
    HStack:
      Text("Welcome to ")
        .foregroundColor("#666")
      Text("nimui")
        .foregroundColor("#007acc")
        .font(20)
    Button(text = "Click me"):
      echo "Button clicked!"

document.body.innerHTML = doc.render().cstring
```

### Build

```bash
nim js -o:build/app.js src/main.nim
```

Then include the output JS in an HTML page.

### Build Tasks

| Command              | Description                          |
| -------------------- | ------------------------------------ |
| `nimble build`       | Build the nimui library (JS backend) |
| `nimble buildExample`| Build the hello-world example        |
| `nimble test`        | Run unit tests (C backend)           |
| `nimble testJs`      | Smoke test — compile to JS           |
| `nimble clean`       | Remove build artifacts               |

## Architecture

```
nimui.nim          — Public API entry point; re-exports macros and runtime types
nimui/
  core.nim         — Domain entities (RootView, Modifier, Handler)
  render.nim       — HTML rendering (string concatenation, HTML escaping)
  modifiers.nim    — UFCS modifier procs (.padding, .foregroundColor, .font)
nimui.js           — JavaScript runtime support
```

The `ui` macro collects view declarations at compile time into a `UiBuilder`. At runtime, `render()` walks the view tree and produces an HTML fragment.

## Project Status

**v0.1.0** — MVP. Core components (`Text`, `VStack`, `HStack`, `Button`) and basic modifiers are implemented. See `aidlc-docs/` for design documentation.

## License

BSD 3-Clause. See [LICENSE](LICENSE) for details.
