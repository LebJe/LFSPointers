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
	<a href="https://img.shields.io/badge/Platforms-MacOS-lightgrey">
	<img src="https://img.shields.io/badge/Platforms-MacOS-lightgrey" alt="">
	</a>
</p>


A command line tool that allows you to convert a directory of large files to Git LFS pointers.

## Prerequisites
### [Git](https://git-scm.com)
Install Git at [https://git-scm.com](https://git-scm.com).

### [Git-LFS](https://git-lfs.github.com)
Install Git-LFS at [https://git-lfs.github.com](https://git-lfs.github.com).
It it recommended that you read [https://git-lfs.github.com](https://git-lfs.github.com) before continuing.

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
Let's imagine you have a directory of large `png` and `jpg` files called `Project Logos`. If you wanted to convert the files with the extension `png` to LFS pointers, you could run 
```
$ LFSPointers path/to/Project\ Logos "^*.png$"
```
. The first argument is the path to the directory, and the second argument is the regular expression used to search for `png` files.\
But wait! It's not safe to run random programs on your computer! To backup your files just in case something goes wrong, add `-b path/to/backup-directory` to the previous command, like this:
```
$ LFSPointers -b path/to/backup-directory path/to/Project\ Logos "^*.png$"
```

## More Information
Run `$ LFSPointers --help`.