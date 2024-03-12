// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
	name: "VDFlow",
	platforms: [
		.iOS(.v13), .macOS(.v10_15), .watchOS(.v6),
	],
	products: [
		.library(name: "VDFlow", targets: ["VDFlow"]),
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.2"),
	],
	targets: [
		.target(name: "VDFlow", dependencies: ["VDFlowMacros"]),
		.macro(
			name: "VDFlowMacros",
			dependencies: [
				.product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
				.product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
			]
		),
		.testTarget(name: "VDFlowTests", dependencies: ["VDFlow"]),
	]
)
