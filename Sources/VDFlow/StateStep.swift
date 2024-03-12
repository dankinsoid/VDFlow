import SwiftUI

/// A property wrapper type that stores or binds a ``VDFlow/Step``  and invalidates a view whenever the step changes.
///
///     @StateStep var router = StepsStruct()
///     @StateStep(.defaultStep) var router = StepsStruct()
///     let stepState = StateStep(stepBinding)
@dynamicMemberLookup
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
	@Environment(\.unselectStep) private var unselectClosure

	public var projectedValue: Binding<Value> {
		$defaultValue
	}

	public init(wrappedValue: Value) {
		self.init(binding: .state(wrappedValue))
	}

	public init(_ binding: Binding<Value>) {
		self.init(binding: .binding(binding))
	}

	private init(binding: StateOrBinding<Value>) {
		_defaultValue = binding
	}

	public subscript<A>(dynamicMember keyPath: WritableKeyPath<Value, StepWrapper<Value, A>>) -> StepBinding<Value, A> {
		StepBinding<Value, A>(
			root: projectedValue,
			keyPath: keyPath
		)
	}

	public func unselect(stepsCount: Int = 1) {
		guard !unselectClosure.isEmpty else {
			Environment(\.presentationMode).wrappedValue.wrappedValue.dismiss()
			return
		}
		unselectClosure[min(unselectClosure.count - 1, max(0, stepsCount - 1))]()
	}

	struct StepKey: EnvironmentKey, Hashable {

		static var defaultValue: Binding<Value>? { nil }
	}
}

public extension StateStep where Value == EmptyStep {

	init() {
		self.init(wrappedValue: EmptyStep())
	}
}

extension EnvironmentValues {

	subscript<T>(stepKey: StateStep<T>.StepKey) -> StateStep<T>.StepKey.Value {
		get { self[StateStep<T>.StepKey.self] }
		set { self[StateStep<T>.StepKey.self] = newValue }
	}

	var unselectStep: [() -> Void] {
		get { self[UnselectKey.self] }
		set { self[UnselectKey.self] = newValue }
	}
}

private enum UnselectKey: EnvironmentKey {

	static var defaultValue: [() -> Void] { [] }
}

public extension View {

	func step<Root: StepsCollection, Value>(
		_ binding: StepBinding<Root, Value>
	) -> some View {
		step(binding.$root, binding.keyPath)
	}

	func step<Root: StepsCollection, Value>(
		_ binding: Binding<Root>,
		_ keyPath: WritableKeyPath<Root, StepWrapper<Root, Value>>
	) -> some View {
		stepEnvironment(
			binding[dynamicMember: keyPath.appending(path: \.wrappedValue)]
		)
		.transformEnvironment(\.unselectStep) {
			$0.insert({ binding.wrappedValue.selected = nil }, at: 0)
		}
		.tag(binding.wrappedValue[keyPath: keyPath].id)
	}

	func stepEnvironment<Value>(_ binding: Binding<Value>) -> some View {
		environment(\.[StateStep<Value>.StepKey()], binding)
	}
}

public extension Binding where Value: StepsCollection {

	func isSelected(_ step: Value.Steps) -> Binding<Bool> {
		Binding<Bool> {
			wrappedValue.selected == step
		} set: {
			if $0 {
				wrappedValue.selected = step
			} else {
				wrappedValue.selected = nil
			}
		}
	}
}
