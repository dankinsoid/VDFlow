// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "VDFlow",
	platforms: [
		.macOS(.v10_13),
		.iOS(.v13)
	],
	products: [
		.library(name: "VDFlow", targets: ["VDFlow"]),
	],
	dependencies: [
		.package(url: "https://github.com/dankinsoid/VDKit.git", from: "1.80.0"),
	],
	targets: [
		.target(name: "VDFlow", dependencies: ["VDKit"])
	]
)
