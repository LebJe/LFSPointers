#!/bin/bash

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    swift build -c release --disable-sandbox -Xswiftc -static-stdlib -Xswiftc -static-executable
elif [[ "$OSTYPE" == "darwin"* ]]; then
        swift build -c release --disable-sandbox
fi
