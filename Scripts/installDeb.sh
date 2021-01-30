#!/bin/bash

case $(uname -m) in
	x86_64) wget -O LFSPointers.deb "https://github.com/LebJe/LFSPointers/releases/download/4.0.0/LFSPointers_4.0.0-1_amd64.deb" ;;
	aarch64) wget -O LFSPointers.deb "https://github.com/LebJe/LFSPointers/releases/download/4.0.0/LFSPointers_4.0.0-1_arm64.deb" ;;
esac

dpkg -i LFSPointers.deb
