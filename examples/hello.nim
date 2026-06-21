## NimUI example — "Hello, World!" demo
##
## Build with: nimble buildExample
## Then open build/hello.html in a browser (or `nim js` directly).

import nimui
import nimui/modifiers
import std/dom  ## Provided by Nim's stdlib on `nim js`; emits `document`.

let doc = ui:
  VStack:
    Text("Hello, World!")
      .padding(16)
      .foregroundColor("#333")
      .font(24)
    HStack:
      Text("Welcome to ")
        .foregroundColor("#666")
      Text("NimUI")
        .foregroundColor("#007acc")
        .font(20)
    Button(text = "Click me"):
      echo "Button clicked!"

## Emit the rendered HTML to the DOM body on `nim js`.
document.body.innerHTML = doc.render().cstring
