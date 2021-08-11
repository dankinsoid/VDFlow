# VDFlow

## Description
This repository provides a new declarative way to describe flows
## Example
```swift
struct AppFlow: View {
  
  @FlowState var flowId = 0

  var body: some View {
    TabView(selection: $flowId) {
      Tab0View()
	.flow(_flowId, for: 0)
      Tab1View()
	.tag(1)
      Tab1View()
	.flow(_flowId, for: 2)
    }
  }
}

struct Tab0View: View {
  
  @FlowState var flowId = "1"

  var body: some View {
    NavigationFlow($flowId) {
      View1()
	.flow(_flowId, for: "0")
      View2()
	.tag("1")
    }
  }
}
...

FlowPath.current = [.id(0), .id("1")]
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
    .package(url: "https://github.com/dankinsoid/VDFlow.git", from: "1.37.0")
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
