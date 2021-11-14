// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "VDFlow",
	platforms: [
		.iOS(.v13), .macOS(.v10_15), .watchOS(.v6)
	],
	products: [
		.library(name: "VDFlow", targets: ["VDFlow"]),
	],
	dependencies: [
		.package(url: "https://github.com/dankinsoid/IterableView.git", from: "1.0.0"),
	],
	targets: [
		.target(name: "VDFlow", dependencies: ["IterableView"])
	]
)
