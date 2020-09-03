# LFS Pointers

<p align="center"><strong>A command line tool and SPM package that allows you to convert a Git repository directory of large files to Git LFS pointers.</strong></p>

[![Swift 5.2](https://img.shields.io/badge/Swift-5.2-brightgreen.svg)](https://swift.org)
[![SPM Compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager)
[![https://img.shields.io/badge/Platforms-MacOS%20%7C%20Linux-lightgrey](https://img.shields.io/badge/Platforms-MacOS%20%7C%20Linux-lightgrey)](https://img.shields.io/badge/Platforms-MacOS%20%7C%20Linux-lightgrey)
[![](https://img.shields.io/github/v/tag/LebJe/LFSPointers)](https://github.com/LebJe/LFSPointers/releases)
[![Build and Test](https://github.com/LebJe/LFSPointers/workflows/Build%20and%20Test/badge.svg)](https://github.com/LebJe/LFSPointers/actions)

* [LFS Pointers](#lfs-pointers)
	* [Install Program](#install-program)
		* [<a href="https://github.com/yonaskolb/mint">Mint</a>](#mint)
		* [<a href="https://brew.sh" rel="nofollow">Homebrew</a>](#homebrew)
		* [Manually](#manually)
			* [From GitHub Release](#from-github-release)
		* [Setup Shell Completions](#setup-shell-completions)
			* [ZSH](#zsh)
			* [Oh My ZSH](#oh-my-zsh)
			* [Without Oh My ZSH](#without-oh-my-zsh)
			* [Bash](#bash)
	* [Install Library](#install-library)
		* [Swift Package Manager](#swift-package-manager)
	* [Usage](#usage)
		* [Library](#library)
			* [Import](#import)
			* [File Conversion](#file-conversion)
			* [Folder Conversion](#folder-conversion)
			* [Writing Pointers](#writing-pointers)
			* [Generating JSON](#generating-json)
		* [Command Line](#command-line)
	* [Dependencies](#dependencies)
	* [More Information](#more-information)
	* [Tested Platforms](#tested-platforms)
		* [Mac](#mac)
	* [Linux](#linux)
	* [iOS, watchOS, tvOS](#ios-watchos-tvos)
	* [JSON Structure for LFSPointer Array](#json-structure-for-lfspointer-array)
	* [JSON Structure for Single LFSPointer](#json-structure-for-single-lfspointer)
	* [Install <a href="https://swift.org/download/" rel="nofollow">Swift</a>](#install-swift)
		* [MacOS](#macos)
		* [Linux (x86_64)](#linux-x86_64)
			* [Ubuntu 20.04](#ubuntu-2004)
			* [Ubuntu 18.04](#ubuntu-1804)
			* [Ubuntu 16.04](#ubuntu-1604)
		* [Linux (aarch64)](#linux-aarch64)

It it recommended that you read the [Git-LFS Homepage](https://git-lfs.github.com) before continuing.

## Install Program

### [Mint](https://github.com/yonaskolb/mint)

`$ mint install LebJe/LFSPointers`

### [Homebrew](https://brew.sh)

Install Swift, as described [here](#Install-Swift),
then run:

```
$ brew install LebJe/formulae/lfs-pointers
```

### Manually

[Install Swift](#Install-Swift), then:

```bash
path/to/LFSPointers $ swift build -c release && cp .build/release/LFSPointers /usr/local/bin
```

this will build the program, then copy it into `/usr/local/bin`.

### From GitHub Release

[Install Swift](#Install-Swift), then download the release asset.

Currently you can't download a pre-built binary for Linux since [Swift can't build a statically linked executable.](https://bugs.swift.org/browse/SR-648)

### Setup Shell Completions

#### ZSH

##### Oh My ZSH

Create a file called `~/.oh-my-zsh/completions/_LFSPointers`, then run:

```zsh
% LFSPointers --generate-completion-script zsh > ~/.oh-my-zsh/completions/_LFSPointers
```
##### Without Oh My ZSH
Add 

```zsh
fpath=(~/.zsh/completion $fpath)
autoload -U compinit
compinit
```

to your `.zshrc`, then create `~/.zsh/completion`, and run:

```zsh
% LFSPointers --generate-completion-script zsh > ~/.zsh/completion/_LFSPointers
```

#### Bash

Create a directory to store Bash completions, for example: `mkdir ~/.bash_completions/`, add this to your `.bashrc` or `.bash_profile`:

```bash
source ~/.bash_completions/LFSPointers.bash
```

, then run:
```bash
$ LFSPointers --generate-completion-script bash > ~/.bash_completions/LFSPointers.bash
```

## Install Library
### Swift Package Manager
Add this to the `dependencies` array in `Package.swift`:

```swift
.package(url: "https://github.com/LebJe/LFSPointers.git", from: "1.0.0")
```
. Also add this to the `targets` array in the aforementioned file:

```swift
.product(name: "LFSPointersKit", package: "LFSPointers")
```

## Usage
### Library
#### Import
```swift
import LFSPointersKit
```

#### File Conversion
To convert a file to a pointer you could write:

```swift
let pointer = try LFSPointer(fromFile: URL(fileURLWithPath: "path/to/file"))
```

The pointer is represented as a Swift `struct`.

```swift
public struct LFSPointer {
	/// The version of the pointer. Example: "https://git-lfs.github.com/spec/v1".
	public let version: String

	/// An SHA 256 hash for the pointer.
	public let oid: String

	/// The size of the converted file.
	public let size: Int
	
	/// String representation of this pointer.
	public var stringRep: String {
		...
	}
	...
}
```

#### Folder Conversion

To convert a folder of files to pointers, you could write: 

```swift
let pointers = try LFSPointer.pointers(forDirectory: URL(fileURLWithPath: "path/to/folder"), searchType: .filenames(["foo.java", "bar.js", "baz.py"]))
```

The search types available are:

```swift
// Array of filenames.
.fileNames(["foo.java", "bar.js", "baz.py"])

// Regular expression.
.regex(NSRegularExpression(pattern: "^*.swift$"))

// All files.
.all
```

This returns an array of `JSONPointer` that each contain the filename, file path, and `LFSPointer`: 

```swift
public struct JSONPointer: Codable {
	public let filename: String
	public let filePath: String
	public let pointer: LFSPointer
}
```

#### Writing Pointers
After you generate a pointer, write it to a file using:

```swift
let pointer = try LFSPointer(...)
try pointer.write(toFile: URL(fileURLWithPath: "path/to/file"), shouldAppend: false)
```

#### Generating JSON
To convert a pointer to JSON:

```swift
let pointer = try LFSPointer(...)
let json = pointer.json
```

and to convert an array of tuples consisting of filename, file path, and pointer:

```swift
let pointers = try LFSPointer.pointers(...)
toJSON(array: pointers)
```

The JSON for the `LFSPointer` array will be structured as shown [here](#json-structure-for-lfspointer-array), and the JSON for the single `LFSPointer` will be structured as shown [here](#json-structure-for-single-lfspointer).

### Command Line
Let's imagine you have a directory of large `png` and `jpg` files called `Project Logos`. If you wanted to convert the files with the extension `png` to LFS pointers, you could run 

```bash
$ LFSPointers path/to/Project\ Logos *.png
```

. The first argument is the path to the directory, and the second argument is a regular expression used to search for `png` files that your shell will convert to a list of filenames.\
But wait! It's not safe to run random programs on your computer! To backup your files just in case something goes wrong, add `-b path/to/backup-directory` to the previous command, like this:

```bash
$ LFSPointers -b path/to/backup-directory path/to/Project\ Logos *.png
```

If you want to generate JSON output instead, do:

```bash
$ LFSPointers --json path/to/Project\ Logos *.png
```

The JSON will be structured as shown [here](#json-structure-for-lfspointer-array).

## Dependencies

- [Files](https://github.com/JohnSundell/Files)
- [Rainbow](https://github.com/onevcat/Rainbow)
- [Swift Argument Parser](https://github.com/apple/swift-argument-parser)

## More Information
Run `$ LFSPointers --help`.

## Tested Platforms

### Mac
Tested on MacOS 10.15, using Swift 5.2.
### Linux
Tested on Ubuntu 18.04 (`x86_64` and `aarch64`), also using Swift 5.2.
## iOS, watchOS, tvOS
These platforms have not been tested on yet, although, at the time of writing the iOS project in the `Samples/FileToPointer` directory is currently working.

## JSON Structure for LFSPointer Array

```json
[
	{
		"filename": "foo.txt",
		"filePath": "/path/to/foo.txt",
		"pointer": {
			"version": "https://git-lfs.github.com/spec/v1",
			"oid": "10b2cd328e193dd4b81d921dbe91bda74bda704c37bca43f1e15f41fcd20ac2a",
			"size": 1455
		}
	},
	{
		"filename": "bar.txt",
		"filePath": "/path/to/bar.txt",
		"pointer": {
			"version": "https://git-lfs.github.com/spec/v1",
			"oid": "601952b2d85214ea602104a4784728ffa6b323b3a6131a124044fa5bfc2f7bf2",
			"size": 1285200
		}
	}
]
```

## JSON Structure for Single LFSPointer

```json
{
	"version": "https://git-lfs.github.com/spec/v1",
	"oid": "10b2cd328e193dd4b81d921dbe91bda74bda704c37bca43f1e15f41fcd20ac2a",
	"size": 1455
}
```



## Install [Swift](https://swift.org/download/)

More information at [https://swift.org/download/](https://swift.org/download/).

### MacOS

Install [Xcode](https://apps.apple.com/us/app/xcode/id497799835?mt=12), or:

```bash
$ sudo xcode-select --install
```



### Linux (`x86_64`)

#### Ubuntu 20.04

```bash
$ # Install Dependencies
apt install \
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
# Download Swift
wget https://swift.org/builds/swift-5.2.5-release/ubuntu2004/swift-5.2.5-RELEASE/swift-5.2.5-RELEASE-ubuntu20.04.tar.gz

tar -zxvf swift-5.2.5-RELEASE-ubuntu20.04.tar.gz

export PATH="$HOME/swift-5.2.5-RELEASE-ubuntu20.04/usr/bin:$PATH"
```



#### Ubuntu 18.04

```bash
$ # Install Dependencies
apt install \
          binutils \
          git \
          libc6-dev \
          libcurl4 \
          libedit2 \
          libgcc-5-dev \
          libpython2.7 \
          libsqlite3-0 \
          libstdc++-5-dev \
          libxml2 \
          pkg-config \
          tzdata \
          zlib1g-dev
# Download Swift
wget https://swift.org/builds/swift-5.2.5-release/ubuntu1804/swift-5.2.5-RELEASE/swift-5.2.5-RELEASE-ubuntu18.04.tar.gz

tar -zxvf swift-5.2.5-RELEASE-ubuntu18.04.tar.gz

export PATH="$HOME/swift-5.2.5-RELEASE-ubuntu18.04.tar.gz/usr/bin:$PATH"
```



#### Ubuntu 16.04

```bash
$ # Install Dependencies
apt install \
          binutils \
          git \
          libc6-dev \
          libcurl3 \
          libedit2 \
          libgcc-5-dev \
          libpython2.7 \
          libsqlite3-0 \
          libstdc++-5-dev \
          libxml2 \
          pkg-config \
          tzdata \
          zlib1g-dev
# Download Swift
wget https://swift.org/builds/swift-5.2.5-release/ubuntu1604/swift-5.2.5-RELEASE/swift-5.2.5-RELEASE-ubuntu16.04.tar.gz

tar -zxvf swift-5.2.5-RELEASE-ubuntu16.04.tar.gz

export PATH="$HOME/swift-5.2.5-RELEASE-ubuntu16.04.tar.gz/usr/bin:$PATH"
```





### Linux (`aarch64`)

More information at [https://github.com/futurejones/swift-arm64](https://github.com/futurejones/swift-arm64)

#### Ubuntu

```bash
$ curl -s https://packagecloud.io/install/repositories/swift-arm/release/script.deb.sh | sudo bash
sudo apt install swift-lang
```

