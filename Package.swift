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
		.package(url: "https://github.com/krzyzanowskim/CryptoSwift", from: "1.3.1"),
		// Enable ZSH and Bash completions.
		.package(url: "https://github.com/apple/swift-argument-parser.git", .branch("master")),
	//	.package(url: "https://github.com/apple/swift-argument-parser.git", from: "0.2.0"),
		.package(url: "https://github.com/onevcat/Rainbow", from: "3.1.5"),
		.package(url: "https://github.com/JohnSundell/Files", from: "4.1.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "LFSPointersLibrary",
			dependencies: ["Files", "CryptoSwift"]),
		.target(
			name: "LFSPointersExecutable",
			dependencies: [
				.product(name: "ArgumentParser", package: "swift-argument-parser"), 
				"Rainbow",
				"Files", 
				"LFSPointersLibrary"
			]
		),
        .testTarget(
            name: "LFSPointersTests",
            dependencies: ["LFSPointersLibrary"])
    ]
)

#if os(Linux)
// SwiftyJSON is not supported on Linux, so we need to use a fork from IBM-Swift that is supported.
package.dependencies.append(.package(url: "https://github.com/IBM-Swift/SwiftyJSON.git", from: "17.0.5"))
#elseif os(macOS)
package.dependencies.append(.package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0"))
#endif

package.targets[0].dependencies.append("SwiftyJSON")
package.targets[1].dependencies.append("SwiftyJSON")
