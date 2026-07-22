#!/bin/sh
git submodule update --init --recursive --filter='blob:none'
cd emsdk
./emsdk install 6.0.3
./emsdk activate 6.0.3
echo "!!! dear pesky plumber: please actually add this to your shell"
