// swift-tools-version:5.7
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
	],
	targets: [
		.target(name: "VDFlow", dependencies: [])
	]
)
