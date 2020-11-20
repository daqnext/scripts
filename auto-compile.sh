#!/bin/sh
# Copyright 2020 Daqnext Foundation Ltd.

VERSION="v0.1.1"

mkdir build

echo "Compiling Windows x86/x86_64 version"
GOOS=windows GOARCH=386   go build -o ./build/meson-${VERSION}-win32.exe
GOOS=windows GOARCH=amd64 go build -o ./build/meson-${VERSION}-win64.exe

echo "Compiling MAC     x86_64 version"
GOOS=darwin GOARCH=amd64 go build -o ./build/meson-${VERSION}-darwin-amd64

echo "Compiling Linux   x86/x86_64 version"
GOOS=linux GOARCH=386   go build -o ./build/meson-${VERSION}-linux-x86
GOOS=linux GOARCH=amd64 go build -o ./build/meson-${VERSION}-linux-amd64
