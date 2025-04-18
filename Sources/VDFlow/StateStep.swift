import SwiftUI

/// A property wrapper type that stores or binds a navigation step collection and invalidates a view whenever the step changes.
///
/// `StateStep` serves as the primary way to integrate VDFlow's navigation with SwiftUI's view system.
/// It can either own the state itself (like `@State`) or bind to external state (like `@Binding`).
///
/// There are three primary ways to use `StateStep`:
///
/// 1. Create and own the state:
/// ```swift
/// struct ContentView: View {
///     @StateStep var steps = TabSteps.home
///
///     var body: some View {
///         TabView(selection: $steps.selected) {
///             HomeView()
///                 .step(_steps.$home)
///             ProfileView()
///                 .step(_steps.$profile)
///         }
///     }
/// }
/// ```
///
/// 2. Bind to a parent's state:
/// ```swift
/// struct ChildView: View {
///     @StateStep var steps: TabSteps
///
///     var body: some View {
///         // Access and modify steps here
///         Button("Go Home") {
///             steps.selected = .home
///         }
///     }
/// }
///
/// // In parent view:
/// ChildView()
///     .stepEnvironment($parentSteps)
/// ```
///
/// 3. Create from an existing binding:
/// ```swift
/// struct DetailView: View {
///     @ObservedObject var viewModel: ViewModel // Has a steps property
///     @StateStep var steps: DetailSteps
///
///     init(viewModel: ViewModel) {
///         self.viewModel = viewModel
///         _steps = StateStep(viewModel.$steps)
///     }
///
///     var body: some View {
///         // Use steps here
///     }
/// }
/// ```
///
/// - Important: When accessing the wrapper itself, use the underscore prefix: `_steps`
@propertyWrapper
public struct StateStep<Value>: DynamicProperty {

	public var wrappedValue: Value {
		get { projectedValue.wrappedValue }
		nonmutating set {
			projectedValue.wrappedValue = newValue
		}
	}

	@StateOrBinding private var defaultValue: Value

	@Environment(\.[StepKey()]) private var stepBinding

	public var projectedValue: Binding<Value> {
		switch _defaultValue {
		case let .binding(binding): binding
		case let .state(state): stepBinding ?? state.projectedValue
		}
	}

	/// Creates a new state step that owns its state.
	///
	/// This initializer creates a state step that owns and manages its own state, similar to SwiftUI's `@State`.
	///
	/// - Parameter wrappedValue: The initial value for the state.
	public init(wrappedValue: Value) {
		self.init(binding: .state(wrappedValue))
	}

	/// Creates a new state step that binds to external state.
	///
	/// This initializer creates a state step that binds to external state, similar to SwiftUI's `@Binding`.
	/// Use this when you want to integrate with existing state management like `ObservableObject` models.
	///
	/// - Parameter binding: A binding to the external state.
	public init(_ binding: Binding<Value>) {
		self.init(binding: .binding(binding))
	}

	private init(binding: StateOrBinding<Value>) {
		_defaultValue = binding
	}

	struct StepKey: EnvironmentKey, Hashable {

		static var defaultValue: Binding<Value>? { nil }
	}
}

public extension StateStep where Value == EmptyStep {

	/// Creates a new state step with an empty step value.
	///
	/// This is a convenience initializer for cases where you need a placeholder step that doesn't contain any data.
	init() {
		self.init(wrappedValue: EmptyStep())
	}
}

extension EnvironmentValues {

	subscript<T>(stepKey: StateStep<T>.StepKey) -> StateStep<T>.StepKey.Value {
		get { self[StateStep<T>.StepKey.self] }
		set { self[StateStep<T>.StepKey.self] = newValue }
	}
}

public extension View {

	/// Associates a view with a specific step in a step collection and sets up the environment for that step.
	///
	/// This modifier combines `.tag()` and `.stepEnvironment()` to fully configure a view for a specific step.
	/// Use this with tab views, lists, or any other view where selection state is needed.
	///
	/// - Parameter binding: A binding to a step wrapper, typically accessed through `_steps.$stepName`.
	/// - Returns: A view modified with the appropriate tag and environment for this step.
	///
	/// ```swift
	/// TabView(selection: $steps.selected) {
	///     HomeView()
	///         .step(_steps.$home)
	///
	///     ProfileView()
	///         .step(_steps.$profile)
	/// }
	/// ```
	func step<Root: StepsCollection, Value>(
		_ binding: Binding<StepWrapper<Root, Value>>
	) -> some View {
		stepEnvironment(
			binding[dynamicMember: \.wrappedValue]
		)
		.tag(binding.wrappedValue.id)
		.stepTag(binding.wrappedValue.id)
	}

	/// Sets up the environment to provide a binding to the specified value to child views.
	///
	/// This is particularly useful for passing a step binding down the view hierarchy without
	/// needing to explicitly pass it through initializers.
	///
	/// - Parameter binding: A binding to a value that will be made available to child views.
	/// - Returns: A view with the environment set up for the provided binding.
	///
	/// ```swift
	/// NavigationView {
	///     RootView()
	///         .stepEnvironment($steps.$detailFlow)
	/// }
	///
	/// // In a child view:
	/// struct DetailView: View {
	///     @StateStep var detailFlow: DetailSteps
	///     // This will automatically receive the binding from the environment
	/// }
	/// ```
	func stepEnvironment<Value>(_ binding: Binding<Value>) -> some View {
		environment(\.[StateStep<Value>.StepKey()], binding)
	}
}

public extension Binding where Value: StepsCollection, Value.AllSteps: ExpressibleByNilLiteral {

    /// Creates a binding to an optional value that reflects whether a specific step is selected.
    ///
    /// This is useful for integrating with SwiftUI's `isPresented` and similar APIs that use optional bindings.
    /// The binding's value will be non-nil when the step is selected, and nil otherwise.
    ///
    /// - Parameter step: The key path to the step to check.
    /// - Returns: A binding to an optional value that is non-nil when the step is selected.
    ///
    /// ```swift
    /// NavigationLink(isActive: $steps.isSelected(\.detail)) {
    ///     DetailView()
    /// } label: {
    ///     Text("Go to Detail")
    /// }
    /// ```
    func isSelected<T>(_ step: WritableKeyPath<Value, Value.StepID<T>>) -> Binding<T?> {
        Binding<T?> {
            if wrappedValue.isSelected(step) {
                return wrappedValue[keyPath: step].wrappedValue
            } else {
                return nil
            }
        } set: {
            if let value = $0 {
                wrappedValue.select(step, with: value)
            } else if wrappedValue.isSelected(step) {
                wrappedValue.selected = nil
            }
        }
    }

	/// Creates a binding to a Boolean value that reflects whether a specific step is selected.
	///
	/// This is useful for integrating with SwiftUI's `isPresented` and similar APIs that use Boolean bindings.
	///
	/// - Parameter step: The step to check.
	/// - Returns: A binding to a Boolean value that is `true` when the step is selected.
	///
	/// ```swift
	/// Button("Go to Settings") {
	///     $flow.isSelected(.settings).wrappedValue = true
	/// }
	///
	/// // Or with NavigationLink:
	/// NavigationLink(isActive: $flow.isSelected(.details)) {
	///     DetailsView()
	/// } label: {
	///     Text("Show Details")
	/// }
	/// ```
	func isSelected(_ step: Value.AllSteps) -> Binding<Bool> {
		Binding<Bool> {
			wrappedValue.selected == step
		} set: {
			if $0 {
				wrappedValue.selected = step
			} else if wrappedValue.selected == step {
				wrappedValue.selected = nil
			}
		}
	}
}
