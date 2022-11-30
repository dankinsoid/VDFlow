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
struct TabSteps {

  @Step() var tab1
  @Step var tab2 = SomeTab2Data()
  @Step var tab3 = NavigationSteps()
}

struct NavigationSteps {

  @Step() var screen1
  @Step() var screen2 = PickerSteps()
}

struct PickerSteps {

  @Step() var text1
  @Step() var text2

  var prefixString = "Some string"
}
```
```swift
@Step var steps = TabSteps()
```
If you want to open `Tab2` you need mark `tab2` as selected. You have several ways to do it:
1. Call `select` method on the property:
```swift
steps.$tab2.select()
```
2. Just mutate `.tab2`:
```swift
steps.tab2 = SomeTab2Data()
```
3. Call `select` method with `KeyPath`:
 ```swift
 $steps.select(\.$tab2)
 ```
You can check which property is selected:
1. With `isSelected` method:
```swift
$steps.isSelected($tab2)
```
2. With `selected` property:
```swift
$steps.selected == $steps.key(\.$tab)
```
3. With `switch`
```swift
switch $steps.selected {
case \.$tab:
  ...
default:
  break
}
```
but not nested: `case \.tab3.$screen1:` doesn't matched.\
Also you can set default selected property:
```swift
@Step(\.$text1) var screen3 = PickerSteps()
```
### Deeplink
 Then you got a deep link for example and you need to change `Tab2` to third tab with `NavigationView`, push to `Push2View` and select `Text2` in `PickerView`.
 ```swift
 steps.tab3.screen2.$text2.select()
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
  
  @StateStep(\.$tab1) var step = TabSteps()
  
  var body: some View {
    TabView(selection: $step.selected) {
      Tab1()
        .step(_step.tab1)
      
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
        NavigationLink(isActive: _step.isSelected(\.$screen3)) {
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
        .tag(_step.text1)
      
      Text("\(step.prefixString) 1")
        .tag(_step.text2)
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
let stepsSubject = CurrentValueSubject(
  Step(TabSteps(), selected: \$tab1)
)

stepsSubject
  .map(\.selected)
  .removeDublicates()
  .sink { selected in
    switch selected {
    case \.$tab1:
      ... 
    }
  }

stepsSubject.value.$tab2.select()
```
or use `didSet`:
```swift
var steps = Step(TabSteps(), selected: \$tab1) {
  didSet {
    guard oldValue.selected != steps.selected else { return }
    ... 
  }
}
```

## Installation

1. [Swift Package Manager](https://github.com/apple/swift-package-manager)

Create a `Package.swift` file.
```swift
// swift-tools-version:5.7
import PackageDescription

let package = Package(
  name: "SomeProject",
  dependencies: [
    .package(url: "https://github.com/dankinsoid/VDFlow.git", from: "3.0.3")
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
