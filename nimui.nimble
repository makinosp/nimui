## Package

version       = "0.1.0"
author        = "makinosp"
description   = "SwiftUI-style declarative UI DSL for Nim (HTML/CSS backend, Nim JS target)"
license       = "MIT"
srcDir        = "src"
bin           = @[]

## Dependencies

requires "nim >= 1.6.0"

## Tasks

task build, "Build the nimui library (Nim JS backend)":
  exec "nim js --path:src -d:release --opt:size -o:build/nimui.js src/nimui.nim"

task buildExample, "Build the hello-world example (Nim JS backend)":
  exec "nim js --path:src -d:release --opt:size -o:build/hello.js examples/hello.nim"

task test, "Run nimui unit tests":
  exec "nim c -r --path:src tests/test_nimui.nim"

task testJs, "Build nimui under the Nim JS backend (smoke test)":
  exec "nim js --path:src -o:build/nimui_smoke.js src/nimui.nim"

task clean, "Remove build artifacts":
  rmDir "build"
