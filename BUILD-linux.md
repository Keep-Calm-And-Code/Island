# Building on Linux

## Dependencies

1. Install the `haxe` compiler: `sudo apt install haxe`

2. Setup `haxelib`, the Haxe package manager. e.g. `haxelib setup`, then press Enter to accept the default directory

3. Install `hxcpp`: `haxelib install hxcpp`

## Compiling for Linux

Run e.g. `haxe -p ./src -cpp ./bin/Island linux -main Main`