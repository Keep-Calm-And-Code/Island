PLATFORM = linux-amd64
HL = hashlink-2f8a703-$(PLATFORM)
ARTIFACT = island-$(shell git rev-parse --short HEAD)-$(PLATFORM)

.PHONY: clean package

all: build/island

build/island: _gen/island.c build/lib/libhl.so _deps/$(HL)
	gcc -O3 -o build/island -I _gen _gen/island.c -lhl -L_deps/$(HL) -I_deps/$(HL)/include -Wl,-rpath='$$ORIGIN/lib'

build/lib/libhl.so: _deps/$(HL)
	mkdir -p build/lib
	cp _deps/$(HL)/libhl.so build/lib

_gen/island.c: src/*.hx
	haxe -cp src -main Main -hl _gen/island.c

_deps/$(HL):
	mkdir -p _deps
	curl -L https://github.com/HaxeFoundation/hashlink/releases/download/latest/$(HL).tar.gz | tar -xzC _deps

clean:
	rm -r -f _gen build dist

package: build/island build/lib/libhl.so
	mkdir -p dist
	tar czf dist/$(ARTIFACT).tar.gz -C build island lib --transform "s,^,$(ARTIFACT)/,"
