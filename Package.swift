// swift-tools-version:5.2

import PackageDescription

let package = Package(
	name: "LFSPointers",
	platforms: [.macOS(.v10_15), .iOS(.v13)],
	products: [
		.executable(name: "LFSPointers", targets: ["LFSPointersExecutable"]),
		.library(name: "LFSPointersKit", targets: ["LFSPointersKit"]),
	],
	dependencies: [
		// Straightforward, type-safe argument parsing for Swift
		.package(url: "https://github.com/apple/swift-argument-parser.git", from: "0.3.1"),

		// Delightful console output for Swift developers.
		.package(url: "https://github.com/onevcat/Rainbow", from: "3.1.5"),

		// A nicer way to handle files & folders in Swift
		.package(url: "https://github.com/JohnSundell/Files", from: "4.1.1"),

		// Open-source implementation of a substantial portion of the API of Apple CryptoKit suitable for use on Linux platforms.
		.package(url: "https://github.com/apple/swift-crypto.git", from: "1.1.2"),

		// Swift System provides idiomatic interfaces to system calls and low-level currency types.
		.package(url: "https://github.com/apple/swift-system.git", .exact("0.0.1")),
	],
	targets: [
		.target(
			name: "LFSPointersKit",
			dependencies: [
				"Files",
				.product(name: "Crypto", package: "swift-crypto"),
				.product(name: "SystemPackage", package: "swift-system"),
			]
		),
		.target(
			name: "LFSPointersExecutable",
			dependencies: [
				"Files",
				"LFSPointersKit",
				"Rainbow",
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
			]
		),
		.testTarget(
			name: "LFSPointersTests",
			dependencies: ["LFSPointersKit"]
		),
	]
)
