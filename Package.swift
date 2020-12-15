// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LFSPointers",
	platforms: [.macOS(.v10_15), .iOS(.v13)],
	products: [
		.executable(name: "LFSPointers", targets: ["LFSPointersExecutable"]),
		.library(name: "LFSPointersKit", targets: ["LFSPointersKit"])
	],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
		.package(url: "https://github.com/apple/swift-argument-parser.git", from: "0.3.1"),
		.package(url: "https://github.com/onevcat/Rainbow", from: "3.1.5"),
		.package(url: "https://github.com/JohnSundell/Files", from: "4.1.1"),
		.package(url: "https://github.com/apple/swift-crypto.git", from: "1.1.2")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "LFSPointersKit",
			dependencies: [
				"Files",
				.product(name: "Crypto", package: "swift-crypto")
			]
		),
		.target(
			name: "LFSPointersExecutable",
			dependencies: [
				.product(name: "ArgumentParser", package: "swift-argument-parser"), 
				"Rainbow",
				"Files", 
				"LFSPointersKit"
			]
		),
        .testTarget(
            name: "LFSPointersTests",
            dependencies: ["LFSPointersKit"]
		)
    ]
)
