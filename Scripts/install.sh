#!/bin/bash

SWIFT_VER="5.2.2"

if [[ "$OSTYPE" == "darwin"* ]]; then
  brew update
  brew upgrade git
  brew install git-lfs
  git lfs install
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  RELEASE_DOT=$(lsb_release -sr)
  RELEASE_NUM=${RELEASE_DOT//[-._]/}
  wget https://swift.org/builds/swift-${SWIFT_VER}-release/ubuntu${RELEASE_NUM}/swift-${SWIFT_VER}-RELEASE/swift-${SWIFT_VER}-RELEASE-ubuntu${RELEASE_DOT}.tar.gz
  tar xzf swift-${SWIFT_VER}-RELEASE-ubuntu${RELEASE_DOT}.tar.gz

fi