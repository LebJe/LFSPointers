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
		 .package(url: "https://github.com/apple/swift-argument-parser.git", .exact("0.0.4")),
		 .package(url: "https://github.com/onevcat/Rainbow", from: "3.1.5"),
		 .package(url: "https://github.com/JohnSundell/Files", from: "4.1.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "LFSPointersLibrary",
			dependencies: ["SwiftShell", "Files", "Rainbow"]),
		.target(
			name: "LFSPointersExecutable",
			dependencies: ["SwiftShell", .product(name: "ArgumentParser", package: "swift-argument-parser"), "Rainbow", "Files", "LFSPointersLibrary"]),
        .testTarget(
            name: "LFSPointersTests",
            dependencies: ["LFSPointersLibrary", "SwiftShell"]),
    ]
)

// SwiftyJSON is not supported on linux, so we need to use a fork that is supported.
#if os(Linux)
package.dependencies.append(.package(url: "https://github.com/IBM-Swift/SwiftyJSON.git", from: "17.0.5"))
#elseif os(macOS)
package.dependencies.append(.package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0"))
#endif

package.targets[0].dependencies.append("SwiftyJSON")
package.targets[1].dependencies.append("SwiftyJSON")
