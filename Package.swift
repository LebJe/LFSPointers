// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LFSPointers",
	products: [
		.executable(name: "LFSPointers", targets: ["LFSPointersExecutable"]),
		.library(name: "LFSPointersLib", targets: ["LFSPointersLibrary"])
	],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
         .package(url: "https://github.com/kareman/SwiftShell", from: "5.0.1"),
		 .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMinor(from: "0.0.4")),
		 .package(url: "https://github.com/onevcat/Rainbow", from: "3.1.5"),
		 .package(url: "https://github.com/JohnSundell/Files", from: "4.1.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "LFSPointersLibrary",
			dependencies: ["SwiftShell", "Files"]),
		.target(
			name: "LFSPointersExecutable",
			dependencies: ["SwiftShell", .product(name: "ArgumentParser", package: "swift-argument-parser"), "Rainbow", "Files", "LFSPointersLibrary"]),
        .testTarget(
            name: "LFSPointersTests",
            dependencies: ["LFSPointersLibrary", "SwiftShell"]),
    ]
)
