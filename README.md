# VDFlow

## Description
This repository provides a new simple way to describe routers.\
I view the application flow as a tree of all possible screen states. From this point of view, navigation is the selection of a node of this tree.

## Example
Take for example an application with such a hierarchy of screens:
```swift
             TabView          
   ┌────────────┼────────────┐
  Home        Explore    NavigationView
                    ┌────────┴────────┐
                ProfileView       DetailView
                                      │
                                  ThemeSelector
                              ┌───────┴───────┐
                            Light           Dark
```
`ThemeSelector` is here to demonstrate that navigation can mean not only changing screens, but also changing any state of any view.

Describe your flow as a struct with `Step` properties:
```swift
@Steps
struct AppSteps {

  var home
  var explore = ExploreData()
  var profile: ProfileSteps = .main
  var none
}

@Steps
struct ProfileSteps {

  var main
  var detail: ThemeSteps = .none
}

@Steps
struct ThemeSteps {

  var light
  var dark
  var none
}
```
```swift
var steps: AppSteps = .home
```
If you want to open `Explore` you need mark `explore` as selected. You have several ways to do it:
1. Set `selected` property:
```swift
steps.selected = .explore
```
2. Use auto-generated static functions:
```swift
steps = .explore(ExploreData())
```
You can check which property is selected:
1. With `selected` property:
```swift
$steps.selected == .explore
```
Also you can set initial selected property:
```swift
var profileFlow: ProfileSteps = .main
```
### Deeplink
 Then you got a deep link for example and you need to navigate to the `Profile` tab, push to `DetailView` and select `Dark` theme in `ThemeSelector`.
 ```swift
 steps.profile.$detail.select(with: .dark)
 ```
 Now `profile`, `detail`, `dark` properties are marked as selected.

### Integration with UI
SwiftUI is a state driven framework, so it's easy to implement navigation with `Step`s.

#### 1. `StateStep` property wrapper.
`StateStep` updates view, stores your flow struct or binds it from parent view as an environment value. To bind flow down the view hierarchy you need use `.step(...)` or `.stepEnvironment(...)` view modifiers or initialize `StateStep` with `Binding<Step<...>>`.\
`stepEnvironment` binds current step down the view hierarchy for embedded `StateStep` properties.
`step` modifier is just a combination of `tag` and `stepEnvironment` modifiers.
```swift
struct MainTabView: View {

  @StateStep var step: AppSteps = .home
  
  var body: some View {
    TabView(selection: $step.selected) {
      HomeView()
        .step(_step.$home)
      
      ExploreView()
        .step(_step.$explore)
      
      ProfileNavigation()
        .step(_step.$profile)
    }
    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
  }
}

struct ProfileNavigation: View {
  
  @StateStep var step = ProfileSteps()
  
  var body: some View {
    NavigationView {
      ProfileView {
        NavigationLink(isActive: $step.isSelected(.detail)) {
          ThemeSelectorView()
            .stepEnvironment($step.$detail)
        } label: {
          Text("Change Theme")
        }
      }
    }
  }
}

struct ThemeSelectorView: View {
  
  @StateStep var step = ThemeSteps()
  
  var body: some View {
    Picker("Theme", selection: $step.selected) {
      Text("Light Mode")
        .tag(ThemeSteps.Steps.light)
      
      Text("Dark Mode")
        .tag(ThemeSteps.Steps.dark)
    }
    .pickerStyle(WheelPickerStyle())
  }
}
```
#### 2. Binding
You can use `Step` directly without `StateStep` wrapper, in `ObservableObject` view model or as a part of state in [TCA](https://github.com/pointfreeco/swift-composable-architecture) `Store`, etc.

#### 3. UIKit
There is no any special instrument for UIKit, because UIKit doesn't support state driven navigation, but it's possible to use Combine to subscribe on `Step` changes:
```swift
let stepsSubject = CurrentValueSubject(AppSteps(.home))

stepsSubject
  .map(\.selected)
  .removeDublicates()
  .sink { selected in
    switch selected {
    case .home:
      // Handle home tab selection
    case .explore:
      // Handle explore tab selection
    case .profile:
      // Handle profile tab selection
    default:
      break
    }
  }

stepsSubject.value.$explore.select()
```
or use `didSet`:
```swift
var steps = AppSteps(.home) {
  didSet {
    guard oldValue.selected != steps.selected else { return }
    // Handle selection change
    ... 
  }
}
```

### Observing Steps

VDFlow provides a built-in observer system to track step changes throughout your application. This is useful for analytics, logging, or triggering side effects when navigation occurs.

```swift
// Create a custom observer
class MyStepsObserver: StepsObserver {
  func stepWillChange<Parent: StepsCollection, Value>(
    to newValue: Parent.AllSteps, 
    in type: Parent.Type, 
    with value: Value
  ) {
    print("Will navigate to \(newValue) in \(Parent.self)")
  }
  
  func stepDidChange<Parent: StepsCollection, Value>(
    to newValue: Parent.AllSteps, 
    in type: Parent.Type, 
    with value: Value
  ) {
    print("Did navigate to \(newValue) in \(Parent.self)")
    
    // Perform heavy work in background queue to avoid blocking the UI
    DispatchQueue.global().async {
      // Analytics tracking, logging, etc.
    }
  }
}

// Register the observer globally
StepSystem.observer = MyStepsObserver()
```

The observer will be called whenever any step changes in the application, allowing for centralized navigation tracking.

### Tools

#### `NavigationLink` convenience init
```swift
@StateStep var steps = ProfileSteps()
...
NavigationLink(step: _steps.$detail) {
  ThemeSelectorView()
} label: {
  Text("Change Theme")
}
```

#### `navigationPath()` extension on `Binding<Step<...>>` and two `navigationDestination` methods
```swift
@StateStep var steps = ProfileSteps()
    
var body: some View {
    NavigationStack(path: $steps.navigationPath) {
        ProfileView()
            .navigationDestination(step: _steps.$detail) {
                ThemeSelectorView()
            }
            // or
            .navigationDestination(for: _steps) {
                switch $0 {
                case .detail:
                    ThemeSelectorView()
                    	.step(_steps.$detail)
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
    .package(url: "https://github.com/dankinsoid/VDFlow.git", from: "4.32.0")
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
