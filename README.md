# VDFlow

## Description
This repository provides a new declarative way to describe flows
## Example
```swift
struct AppFlow: Flow {
  static let tab1Step = FlowID<Void>()

  let window: UIWindow

  var root: some BaseFlow {
    WindowFlow(window) {
      if !autorise {
        LoginFlow()
      } else {
        TabFlow {
          Tab1()
            .identified(by: AppFlow.tab1Step)
          Tab2()
            .present {
              NavigationFlow {
                Item1()
                Item2()
              }
            }
        }
      }
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
    .package(url: "https://github.com/dankinsoid/VDFlow.git", from: "1.0.19")
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
