# Building on Windows

## Dependencies

1. Install the `haxe` compiler from https://haxe.org/download/

2. Setup `haxelib`, the Haxe package manager. e.g. from the command line, `haxelib setup` and press Enter to accept the default directory.

3. Install `hxcpp`: `haxelib install hxcpp`

## Compiling for Windows

Run e.g. `haxe -p .\src -cpp .\bin\Island -main Main`