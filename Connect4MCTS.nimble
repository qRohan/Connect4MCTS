# Package

version       = "0.1.0"
author        = "Rohan Jakhar"
description   = "Connect4 AI using Monte Carlo Tree Search"
license       = "MIT"
srcDir        = "src"
# bin           = @["main"]
namedBin      = {"main": "Connect4MCTS"}.toTable


# Dependencies

requires "nim >= 1.6.12"

task windows, "build for windows using mingw":
    exec "nimble c -d:release -d:mingw --out:Connect4MCTS.exe src/main.nim"