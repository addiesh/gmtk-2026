#!/bin/bash
set -e
ARGS=""
if [[ $1 = "release" ]]; then
	ARGS+=--release
fi


export GDRUST_GODOT_BIN=$(realpath ~/Godot_v4.7.1-stable_linux.x86_64)
cargo build --target x86_64-unknown-linux-gnu $ARGS
# cargo build --target aarch64-apple-darwin $ARGS
if [[ $2 = "all" ]]; then
	cargo +nightly build --target wasm32-unknown-emscripten $ARGS
	cargo build --target x86_64-pc-windows-gnu $ARGS
fi
