## nimui unit tests — MVP coverage
##
## Tests run on the Nim C backend (no DOM) and validate:
##  - macro expansion produces a UiBuilder
##  - HTML output for each component
##  - modifier chain
##  - HTML escaping (BR-07)
##  - BR-01..BR-12 design rules where applicable

{.define(nimuiTestMode).}

import nimui
import nimui/core
import nimui/modifiers
import nimui/render
import std/[unittest, strutils, macros]

suite "nimui MVP":
  test "Text renders a span":
    let doc = ui:
      Text("Hello")
    let html = doc.render()
    check "Hello" in html
    check "<span" in html
    check "</span>" in html

  test "VStack emits flex column layout":
    let doc = ui:
      VStack:
        Text("a")
        Text("b")
    let html = doc.render()
    check "<div" in html
    check "</div>" in html
    check "display:flex" in html
    check "flex-direction:column" in html

  test "HStack emits flex row layout":
    let doc = ui:
      HStack:
        Text("a")
        Text("b")
    let html = doc.render()
    check "flex-direction:row" in html

  test "modifier chain on Text":
    let doc = ui:
      Text("hi")
        .padding(16)
        .foregroundColor("red")
        .font(18)
    let html = doc.render()
    check "padding:16px" in html
    check "color:red" in html
    check "font-size:18px" in html

  test "HTML escaping (BR-07)":
    let doc = ui:
      Text("<script>alert('xss')</script>")
    let html = doc.render()
    check "<script>" notin html
    check "&lt;script&gt;" in html

  test "Button generates handler and onclick (BR-08)":
    let doc = ui:
      Button(text = "OK"):
        echo "clicked"
    let html = doc.render()
    check "<button" in html
    check "onclick=\"nimui_handler_1()\"" in html
    check "<script>" in html
    check "function nimui_handler_1()" in html
    check doc.handlers.len == 1
    check doc.handlers[0].id == 1

  test "Unique handler IDs across buttons (BR-08)":
    let doc = ui:
      VStack:
        Button(text = "A"):
          echo "A"
        Button(text = "B"):
          echo "B"
    let html = doc.render()
    check "nimui_handler_1()" in html
    check "nimui_handler_2()" in html
    check doc.handlers.len == 2

  test "CSS class naming follows nimui-{kind}-{hash} (BR-09)":
    let doc = ui:
      VStack:
        Text("x")
    let html = doc.render()
    check "nimui-vstack-" in html
    check "nimui-text-" in html

  test "Nested stacks work":
    let doc = ui:
      VStack:
        Text("outer")
        HStack:
          Text("a")
          Text("b")
    let html = doc.render()
    check "flex-direction:column" in html
    check "flex-direction:row" in html

  test "BR-04: Text accepts a string literal":
    let doc = ui:
      Text("ok")
    check doc.root.kind == rkText
    check doc.root.text == "ok"
