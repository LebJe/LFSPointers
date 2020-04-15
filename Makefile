prefix ?= /usr/local
bindir = $(prefix)/bin

build:
	swift build -c release --disable-sandbox

install: build
	install ".build/release/LFSPointers" "$(bindir)"

uninstall:
	rm -rf "$(bindir)/LFSPointers"

clean:
	rm -rf .build

.PHONY: build install uninstall clean
