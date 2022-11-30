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
    .package(url: "https://github.com/dankinsoid/swift-url-routing.git", branch: "swift-5-7")
	],
	targets: [
		.target(
        name: "VDFlow",
        dependencies: [
        .product(name: "URLRouting", package: "swift-url-routing")
    	]
    )
	]
)
