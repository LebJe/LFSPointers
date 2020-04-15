# LFSPointers

A command line tool that allows you to convert a directory of large files to Git LFS pointers.

## Prerequisites
### [Git](https://git-scm.com)
Install Git at [https://git-scm.com](https://git-scm.com).

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