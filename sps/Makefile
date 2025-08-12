# Simple build helpers for SPS
.PHONY: build test clean deps scan validate query export-matrix

build:
	swift build -c release

test:
	swift test

clean:
	rm -rf .build .swiftpm

deps:
	./install-deps.sh

scan:
	.build/release/sps scan Samples/sample.pdf --out spec/index.json --include-text --sha256 || true

validate:
	.build/release/sps index validate spec/index.json

query:
	.build/release/sps query spec/index.json --q "Note On"

export-matrix:
	.build/release/sps export-matrix spec/index.json --out spec/matrix.json
# © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
