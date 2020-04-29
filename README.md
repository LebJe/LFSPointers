# LFS Pointers

<p align="center"><strong>A command line tool and SPM package that allows you to convert a Git repository directory of large files to Git LFS pointers.</strong></p>

<p align="center">
	<a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-5.2-brightgreen.svg" alt="Swift 5.2"></a>
	<a href="https://swift.org/package-manager"><img src="https://img.shields.io/badge/SPM-compatible-brightgreen.svg" alt="SPM Compatible"></a>
	<a href="https://travis-ci.org/github/LebJe/LFSPointers"><img src="https://travis-ci.org/LebJe/LFSPointers.svg?branch=master" alt="Build Status"></a>
	<a href="https://img.shields.io/badge/Platforms-MacOS%20%7C%20Linux-lightgrey"><img src="https://img.shields.io/badge/Platforms-MacOS%20%7C%20Linux-lightgrey" alt="Platforms: MacOS | Linux"></a>
	<a href="https://github.com/LebJe/LFSPointers/releases"><img src="https://img.shields.io/github/v/tag/LebJe/LFSPointers" alt=""></a>
</p>



## Prerequisites
### [Git](https://git-scm.com)
Install Git at [https://git-scm.com](https://git-scm.com).

### [Git-LFS](https://git-lfs.github.com)
Install Git-LFS at [https://git-lfs.github.com](https://git-lfs.github.com), then run:

```bash
$ git lfs install
```

It it recommended that you read [https://git-lfs.github.com](https://git-lfs.github.com) before continuing.

## Install Program
### [Mint](https://github.com/yonaskolb/mint)
`$ mint install LebJe/LFSPointers`
### [Homebrew](https://brew.sh)
`$ brew install LebJe/formulae/lfs-pointers`

### Manually
Install [Swift 5.2.2](https://swift.org) at [https://swift.org/download/](https://swift.org/download/), then run:

```bash
path/to/LFSPointers $ swift build -c release && cp .build/release/LFSPointers ~/usr/bin/local
```

## Install Library
### Swift Package Manager
Add this to the `dependencies` array in `Package.swift`:

```swift
.package(url: "https://github.com/LebJe/LFSPointers.git", .upToNextMinor(from: "0.11.3"))
```
. Also add this to the `targets` array in the aforementioned file:
```swift
.product(name: "LFSPointersLib", package: "LFSPointers")
```

## Usage
### Library
#### Import
```swift
import LFSPointersLibrary
```

#### File Conversion
To convert a file to a pointer you could write:
```swift
let pointer = try LFSPointer(fromFile: URL(fileURLWithPath: "path/to/file"))
```

The pointer is represented as a Swift struct.
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

This returns an array of tuples, that each contain the filename, file path, and `LFSPointer`: 
```swift
(filename: String, filePath: URL, pointer: LFSPointer)
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
toJSON(pointers)
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
- [SwiftShell](https://github.com/kareman/SwiftShell)

## More Information
Run `$ LFSPointers --help`.

## Tested Platforms
### Mac
Tested on MacOS Catalina 10.15.4 (19E287), using Swift 5.2.2.
### Linux
Tested on Ubuntu 18.04.4 LTS (Bionic Beaver), also using Swift 5.2.2.
## iOS, watchOS, tvOS
Unfortunately, you cannot install command line programs, like `git`, on these systems And because this program depends on `git`, it can't be installed.

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
