#!/bin/bash

if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then
	DIR="$(pwd)"
	cd ..
	export SWIFT_VERSION=swift-5.2.1-RELEASE
	export SWIFT_BRANCH=swift-5.2.1-release
    wget https://swift.org/builds/${SWIFT_BRANCH}/ubuntu1804/${SWIFT_VERSION}/${SWIFT_VERSION}-ubuntu18.04.tar.gz
	tar xzf $SWIFT_VERSION-ubuntu18.04.tar.gz
	export PATH="${PWD}/${SWIFT_VERSION}-ubuntu18.04/usr/bin:${PATH}"
	cd "$DIR"

	sudo apt-get install git-lfs

	git lfs install
else
	brew update
	brew upgrade git
	brew install git-lfs
	git lfs install
fi