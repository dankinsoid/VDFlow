# VDFlow

## Description
This repository provides a new declarative way to describe flows
## Usage
Describe your flow steps as struct via `Step` property wrapper
```swift
struct TabSteps: Equatable {
  @Step var tab1
  @Step var tab2 = SomeData()
  @Step var tab3 = NavigationSteps()
}

struct NavigationSteps: Equatable {
  @Step var screen1
  var screen2 = Step() //it works too
  @Step(\.$view1) var screen3 = PickerSteps()
}

struct PickerSteps: Equatable {
  @Step var view1
  @Step var view2
}
```
Use structs in a `View` with `StateStep` property wrapper
```swift
struct RootTabView: View {
  
  @StateStep(\.$tab1) var step = TabSteps()
  
  var body: some View {
    TabView(selection: $step.selected) {
      Text("0")
        .step(_step.$tab1)
      
      Text("1")
        .step(_step.$tab2)
      
      EmbededNavigation()
        .step(_step.$tab3)
    }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
  }
}

struct EmbededNavigation: View {
  
  @StateStep var step = NavigationSteps()
  
  var body: some View {
    NavigationFlow($step.selected) {
      Text("0")
        .navigationTitle("0")
        .step(_step.$screen1)
      
      Text("1")
        .navigationTitle("1")
        .step(_step.$screen2)
      
      //you can use Binding<Step<...>> and tag(...) instead of .step(...) to guarantee 
      EmbededPicker(step: $step.$screen)
        .navigationTitle("2")
        .tag(_step.tag(\.$screen3))
    }
  }
}

struct EmbededPicker: View {
  
  @StateStep var step: PickerSteps

  init(step: Binding<Step<PickerSteps>>) {
    _step = StateStep(step)
  }
  
  var body: some View {
    Picker("3", selection: $step.selected) {
      Text("0")
        .step(_step.$view1)
      
      Text("1")
        .step(_step.$view2)
    }.pickerStyle(WheelPickerStyle())
  }
}
```
Just change value of any property or call `select` to update flow
```swift
//step is Step or StateStep 
step.tab2 = SomeData()
step.$tab1.select()                 //you have to use $ to call select
step.tab3.screen3.view2.select()    //except for empty steps
step.tab3.screen3.$view2.select()  
_step.select(\.tab3.screen3.$view2) //or you can use KeyPath to any Step property

//TODO: add next() and previuos() methods
```
## Installation

1. [Swift Package Manager](https://github.com/apple/swift-package-manager)

Create a `Package.swift` file.
```swift
// swift-tools-version:5.0
import PackageDescription

let package = Package(
  name: "SomeProject",
  dependencies: [
    .package(url: "https://github.com/dankinsoid/VDFlow.git", from: "2.2.0")
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
