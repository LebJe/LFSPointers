# LFSPointers

<p align="center">
	<a href="https://swift.org">
	<img src="https://img.shields.io/badge/swift-5.2-brightgreen.svg" alt="Swift 5.2">
	</a>
	<a href="https://swift.org/package-manager">
	<img src="https://img.shields.io/badge/spm-compatible-brightgreen.svg" alt="SPM Compatible">
	</a>
	<a href="https://travis-ci.org/github/LebJe/LFSPointers">
	<img src="https://travis-ci.org/LebJe/LFSPointers.svg?branch=master" alt="Build Status">
	</a>
</p>


A command line tool that allows you to convert a directory of large files to Git LFS pointers.

## Prerequisites
### [Git](https://git-scm.com)
Install Git at [https://git-scm.com](https://git-scm.com).

### [Git-LFS](https://git-lfs.github.com)
Install Git-LFS at [https://git-lfs.github.com](https://git-lfs.github.com).

## Install
### [Mint](https://github.com/yonaskolb/mint)
`$ mint install LebJe/LFSPointers`
### [Homebrew](https://brew.sh)
`$ brew install LebJe/formulae/lfs-pointers`

### Manually
#### Install
Install [Swift](https://swift.org) at [https://swift.org/download/](https://swift.org/download/), then run:\
`$ swift build -c release && cp .build/release/LFSPointers ~/usr/bin/local`

## Usage
### Library
Coming soon!

### Command Line
To convert all files with the extension `png` (the files are in the directory `large-files`) to LFS pointers, run `$ LFSPointers large-files "^*.png$"`.

## More Information
Run `$ LFSPointers --help`.