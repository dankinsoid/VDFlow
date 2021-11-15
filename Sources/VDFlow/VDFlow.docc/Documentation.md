# VDFlow

## Description
This repository provides a new simple way to describe routers
## Usage
Describe your flow as struct with `Step`s
```swift
struct TabSteps {
  var tab1 = Step()
  @Step var tab2 = SomeData()
  @Step var tab3 = NavigationSteps()
}

struct NavigationSteps {
  var screen1 = Step()
  var screen2 = Step()
  @Step(\.view1) var screen3 = PickerSteps()
}

struct PickerSteps {
  var view1 = Step()
  var view2 = Step()
}
```
Just change value of any property or call `select` to update flow
```swift
//step is Step or StateStep 
step.tab2 = SomeData()
step.tab1.select()                 
step.tab3.screen3.view2.select()   
_step.select(\.tab3.screen3.view2) //or you can use KeyPath to any Step property
```
Use flow structs in a `View` with `StateStep` property wrapper. `StateStep` updates view, stores your flow struct or binds it from parent view. To bind flow down the view hierarchy you need use `.step(...)`, `.stepEnvironment(...)` view modifiers or create `StateView` with `Binding`. 
```swift
struct RootTabView: View {
  
  @StateStep(\.tab1) var step = TabSteps()
  
  var body: some View {
    TabView(selection: $step.selected) {
      SomeView("0")
        .step(_step.tab1)
      
      Text("1")
        .tag(_step.$tab2)
      
      EmbededNavigation()
        .step(_step.$tab3)
    }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
  }
}

struct EmbededNavigation: View {
  
  @StateStep var step = NavigationSteps()
  
  var body: some View {
    NavigationFlow($step.selected) {
      SomeView("0")
        .navigationTitle("0")
        .step(_step.screen1)
      
      Text("1")
        .navigationTitle("1")
        .tag(_step.screen2)
      
      //you can use Binding<Step<...>> and tag(...) instead of .step(...)
      EmbededPicker(step: $step.$screen3)
        .navigationTitle("2")
        .tag(_step.$screen3)
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
        .step(_step.view1)
      
      Text("1")
        .step(_step.view2)
    }.pickerStyle(WheelPickerStyle())
  }
}
```
You can switch `.selected` with `KeyPath`es
```swift
switch step.selected {
case \.tab1: ...
case \.tab2: ...
default: ...
}
```
but not nested: `case \.tab3.screen1:` doesn't matched 
## NavigationFlow
`UINavigationController` wrapper implementing stack like navigation.
```swift
@State private var step = NavigationScreen.default

var body: some View {
  NavigationFlow($step) {
    Screen1()
      .tag(.screen1)

    Screen2()
      .tag(.screen2)

    Screen3()
      .tag(.screen3)

    ...
  }
  .navigationFlow(barColor: .black)
  .navigationFlow(barShadowColor: .blue)
  .navigationFlow(largeTitleFont: someUIFont)
  .navigationFlow(largeTitleColor: .white)
  .navigationFlow(titleFont: someUIFont)
  .navigationFlow(titleColor: .white)
  .navigationFlow(prefersLargeTitle: true)
  .navigationFlow(largeTitleMode: .always)
  .navigationFlow(backImage: someUIImage)
  .navigationFlow(showBackText: false)
  .navigationFlow(barPadding: EdgeInsets())
  .navigationFlow(barAccentColor: .red)
}
```
## PresentFlow
`UIViewController` wrapper implementing stack like present flow.
```swift
@State private var step = PresentScreen.default

var body: some View {
  PresentFlow($step, style: .native(.formSheet, .crossDissolve)) {
    Screen1()
      .tag(.screen1)

    Screen2()
      .tag(.screen2)

    Screen3()
      .tag(.screen3)

    ...
  }
}
```
## FlowStack
`ZStack` wrapper implementing selection of current view and interactive animations
```swift
@State private var step = FlowStep.default

var body: some View {
  FlowStack($step) {
    Screen1()
      .tag(.screen1)

    Screen2()
      .tag(.screen2)

    Screen3()
      .tag(.screen3)

    ...
  }
  .flowStackTransition(front: .move(edge: .top), back: .identity)
  .flowStackInteractive(hide: .top)
}
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
    .package(url: "https://github.com/dankinsoid/VDFlow.git", from: "2.11.0")
  ],
  targets: [
    .target(name: "SomeProject", dependencies: ["VDFlow"])
  ]
)
```
```ruby
$ swift build
```
2. [CocoaPods](https://cocoapods.org)

Add the following line to your Podfile:
```ruby
pod 'VDFlow'
```
and run `pod update` from the podfile directory first.
## Author

dankinsoid, voidilov@gmail.com

## License

VDFlow is available under the MIT license. See the LICENSE file for more info.