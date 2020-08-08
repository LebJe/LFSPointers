// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UploadAssets",
	platforms: [.macOS(.v10_14)],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
		.package(url: "https://github.com/dduan/Just.git", from: "0.8.0"),
		.package(url: "https://github.com/JohnSundell/ShellOut.git", from: "2.3.0"),
		.package(url: "https://github.com/onevcat/Rainbow.git", from: "3.0.0"),
		.package(url: "https://github.com/sendyhalim/Swime.git", from: "3.0.7")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "UploadAssets",
            dependencies: ["Just", "ShellOut", "Rainbow", "Swime"]
		),
        .testTarget(
            name: "UploadAssetsTests",
            dependencies: ["UploadAssets"]
		),
    ]
)
