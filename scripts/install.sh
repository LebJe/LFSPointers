#!/bin/bash

if [[ $TRAVIS_OS_NAME = 'osx' ]]; then
	brew update
	brew upgrade git
	brew install git-lfs
	git lfs install
elif [[ $TRAVIS_OS_NAME = 'linux' ]]; then
  # download swift
  wget https://swift.org/builds/swift-5.2-release/ubuntu1804/swift-5.2-RELEASE/swift-5.2-RELEASE-ubuntu18.04.tar.gz
  # extract the archive
  tar xzf swift-5.2-RELEASE-ubuntu18.04.tar.gz
  # include the swift command in the PATH
  export PATH="${PWD}/swift-5.2-RELEASE-ubuntu18.04/usr/bin:$PATH"

  sudo apt-get install git-lfs

	git lfs install
fi