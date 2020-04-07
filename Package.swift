// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LFSPointers",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
         .package(url: "https://github.com/kareman/SwiftShell", from: "5.0.1"),
		 .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMinor(from: "0.0.4")),
		 .package(url: "https://github.com/onevcat/Rainbow", from: "3.1.5")
		 
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "LFSPointers",
            dependencies: ["SwiftShell", .product(name: "ArgumentParser", package: "swift-argument-parser"), "Rainbow"]),
        .testTarget(
            name: "LFSPointersTests",
            dependencies: ["LFSPointers"]),
    ]
)
