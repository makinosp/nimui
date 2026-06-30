## NimUI example — Counter demo with State Management
##
## Build with: nimble buildCounter
## Then open build/counter.html in a browser.

import nimui
import nimui/modifiers
import std/dom  ## Provided by Nim's stdlib on `nim js`; emits `document`.

## Define reactive state (FR-S1)
var count = State(0)

let doc = ui:
  VStack:
    Text(count.value)
      .font(32)
      .foregroundColor("#333")
    HStack:
      Button(text = "-"):
        count.value -= 1
      Button(text = "+"):
        count.value += 1

## Emit the rendered HTML to the DOM body on `nim js`.
document.body.innerHTML = doc.render().cstring
