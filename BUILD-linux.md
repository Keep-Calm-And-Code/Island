# Building on linux

## Dependencies

1. Install gcc; e.g. `sudo apt install gcc`
2. [Install `haxe` compiler][haxe]; e.g. `sudo apt install haxe`
3. Setup `haxelib`; e.g. `haxelib setup ~/.local/lib`
4. Install HashLink library: `haxelib install hashlink`

[haxe]: https://haxe.org/download/

## Makefile build

1. `make` This downloads runtime dependencies and builds the native application.
    - Dependencies are placed in `_deps`
    - Generated C code is placed in `_gen`
    - The native application is placed in `build`
2. `make package` Packages the native application into a distributable `.tar.gz`
    - The package is placed in `dist`
