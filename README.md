# VDFlow

## Description
This repository provides a new simple way to describe routers.\
I view the application flow as a tree of all possible screen states. From this point of view, navigation is the selection of a node of this tree.
## Example
Take for example an application with such a hierarchy of screens:
```swift
             TabView          
   ┌────────────┼────────────┐
  Tab1         Tab2    NavigationView
                    ┌────────┴────────┐
                 RootView         Push1View
                                      │
                                  PickerView
                              ┌───────┴───────┐
                            Text1           Text2
```
`PickerView` is here to demonstrate that navigation can mean not only changing screens, but also changing any state of any view.

Describe your flow as a struct with `Step` properties:
```swift
@Steps
struct TabSteps {

  var tab1
  var tab2: SomeTab2Data = .init()
  var tab3: NavigationSteps = .screen1
  var none
}

@Steps
struct NavigationSteps {

  var screen1
  var screen2: PickerSteps = .none
}

@Steps
struct PickerSteps {

  var text1
  var text2
  var none
}
```
```swift
var steps: TabSteps = .tab1
```
If you want to open `Tab2` you need mark `tab2` as selected. You have several ways to do it:
1. Set `selected` property:
```swift
steps.selected = .tab2
```
2. Use auto-generated static functions:
```swift
steps = .tab2(SomeTab2Data())
```
You can check which property is selected:
1. With `selected` property:
```swift
$steps.selected == .tab2
```
Also you can set initial selected property:
```swift
var screen3: PickerSteps = .text1
```
### Deeplink
 Then you got a deep link for example and you need to change `Tab2` to third tab with `NavigationView`, push to `Push2View` and select `Text2` in `PickerView`.
 ```swift
 steps.tab3.$screen2.select(with: .text2)
 ```
 Now `tab3`, `screen3`, `text2` properties are marked as selected.
### Integration with UI
SwiftUI is a state driven framework, so it's easy to implement navigation with `Step`s.
#### 1. `StateStep` property wrapper.
`StateStep` updates view, stores your flow struct or binds it from parent view as an environment value. To bind flow down the view hierarchy you need use `.step(...)` or `.stepEnvironment(...)` view modifiers or initialize `StateStep` with `Binding<Step<...>>`.\
`stepEnvironment` binds current step down the view hierarchy for embedded `StateStep` properties.
`step` modifier is just a combination of `tag` and `stepEnvironment` modifiers.
```swift
struct RootTabView: View {

  @StateStep var step: TabSteps = .tab1
  
  var body: some View {
    TabView(selection: $step.selected) {
      Tab1()
        .step(_step.$tab1)
      
      Tab2()
        .step(_step.$tab2)
      
      EmbededNavigation()
        .step(_step.$tab3)
    }
    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
  }
}

struct EmbededNavigation: View {
  
  @StateStep var step = NavigationSteps()
  
  var body: some View {
    NavigationView {
      RootView {
        NavigationLink(isActive: $step.isSelected(.screen3)) {
          EmbededPicker()
            .stepEnvironment($step.$screen2)
        } label: {
          Text("push")
        }
      }
    }
  }
}

struct EmbededPicker: View {
  
  @StateStep var step = PickerSteps()
  
  var body: some View {
    Picker("3", selection: $step.selected) {
      Text("\(step.prefixString) 0")
        .tag(PickerSteps.Steps.text1)
      
      Text("\(step.prefixString) 1")
        .tag(PickerSteps.Steps.text2)
    }
    .pickerStyle(WheelPickerStyle())
  }
}
```
#### 4. Binding
You can use `Step` directly without `StateStep` wrapper, in `ObservableObject` view model or as a part of state in [TCA](https://github.com/pointfreeco/swift-composable-architecture) `Store`, etc.

#### 5. UIKit
There is no any special instrument for UIKit, because UIKit doesn't support state driven navigation, but it's possible to use Combine to subscribe on `Step` changes:
```swift
let stepsSubject = CurrentValueSubject(TabSteps(.tab1))

stepsSubject
  .map(\.selected)
  .removeDublicates()
  .sink { selected in
    switch selected {
    case .tab1:
      ... 
    }
  }

stepsSubject.value.$tab2.select()
```
or use `didSet`:
```swift
var steps = TabSteps(.tab1) {
  didSet {
    guard oldValue.selected != steps.selected else { return }
    ... 
  }
}
```
### Tools
#### `NavigationLink` convenience init
```swift
@StateStep var steps = Steps()
...
NavigationLink(step: _steps.$link) {
  ...
} label: {
  ...
}
```
#### `navigationPath()` extension on `Binding<Step<...>>` and two `navigationDestination` methods
```swift
@StateStep var steps = Steps()
    
var body: some View {
    NavigationStack(path: $steps.navigationPath) {
        RootView()
            .navigationDestination(step: _steps.$link) {
                PushView()
            }
            // or
            .navigationDestination(for: _steps) {
                switch $0 {
                case .link:
                    PushView()
                    	.step(_step.$link)
                default:
                    EmptyView()
                }
            }
    }
    
}
```
## Installation

1. [Swift Package Manager](https://github.com/apple/swift-package-manager)

Create a `Package.swift` file.
```swift
// swift-tools-version:5.9
import PackageDescription

let package = Package(
  name: "SomeProject",
  dependencies: [
    .package(url: "https://github.com/dankinsoid/VDFlow.git", from: "4.31.0")
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

Daniil Voidilov, voidilov@gmail.com

## License

VDFlow is available under the MIT license. See the LICENSE file for more info.
