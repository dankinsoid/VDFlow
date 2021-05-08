# VDFlow

## Description
This repository provides a new declarative way to describe flows
## Example
```swift
struct AppFlow: View {
  
  @FlowState var flowId = 0

  var body: some View {
    TabView(selection: $page) {
      Tab0View()
	.flow(_page, for: 0)
      Tab1View()
	.tag(1)
      Tab1View()
	.flow(_page, for: 2)
    }
  }
}
```
## Usage
//TODO
## Installation

1. [Swift Package Manager](https://github.com/apple/swift-package-manager)

Create a `Package.swift` file.
```swift
// swift-tools-version:5.0
import PackageDescription

let package = Package(
  name: "SomeProject",
  dependencies: [
    .package(url: "https://github.com/dankinsoid/VDFlow.git", from: "1.16.0")
  ],
  targets: [
    .target(name: "SomeProject", dependencies: ["VDFlow"])
  ]
)
```
```ruby
$ swift build
```

## Author

dankinsoid, voidilov@gmail.com

## License

VDFlow is available under the MIT license. See the LICENSE file for more info.
