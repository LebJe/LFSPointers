#!/bin/bash

export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true

buildOnARM() {
	curl -s https://packagecloud.io/install/repositories/swift-arm/release/script.deb.sh | bash
	apt update -yq
	apt install -yq swiftlang
	swift build -c release --enable-test-discovery --static-swift-stdlib -Xswiftc -static-executable -Xswiftc -cross-module-optimization
	cp .build/release/LFSPointers .
}

buildOnIntel() {
	apt install -yq \
	  binutils \
	  git \
	  gnupg2 \
	  libc6-dev \
	  libcurl4 \
	  libedit2 \
	  libgcc-9-dev \
	  libpython2.7 \
	  libsqlite3-0 \
	  libstdc++-9-dev \
	  libxml2 \
	  libz3-dev \
	  pkg-config \
	  tzdata \
	  zlib1g-dev
	wget -O swift.tar.gz https://swift.org/builds/swift-5.3.1-release/ubuntu2004/swift-5.3.1-RELEASE/swift-5.3.1-RELEASE-ubuntu20.04.tar.gz
	tar -xvzf swift.tar.gz
	swift-5.3.1-RELEASE-ubuntu20.04/usr/bin/swift build -c release --enable-test-discovery --static-swift-stdlib -Xswiftc -static-executable -Xswiftc -cross-module-optimization
	cp .build/release/LFSPointers .
}

case $(uname -m) in
	x86_64)	buildOnIntel ;;
	aarch64) buildOnARM ;; 
esac

