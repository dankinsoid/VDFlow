import SwiftUI

/// A property wrapper type that stores or binds a ``VDFlow/Step``  and invalidates a view whenever the step changes.
///
///     @StateStep var router = StepsStruct()
///     let stepState = StateStep(stepBinding)
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

	public init(wrappedValue: Value) {
		self.init(binding: .state(wrappedValue))
	}

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

// public extension StateStep where Value: StepsCollection {
//
//    subscript<A>(dynamicMember keyPath: WritableKeyPath<Value, StepWrapper<Value, A>>) -> Binding<StepSelection<Value, A>> {
//        Binding {
//            wrappedValue[keyPath]
//        } set: {
//            wrappedValue[keyPath] = $0
//        }
//    }
// }

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
}

public extension View {

	func step<Root: StepsCollection, Value>(
		_ binding: Binding<StepWrapper<Root, Value>>
	) -> some View {
		stepEnvironment(
			binding[dynamicMember: \.wrappedValue]
		)
		.tag(binding.wrappedValue.id)
		.stepTag(binding.wrappedValue.id)
	}

	func stepEnvironment<Value>(_ binding: Binding<Value>) -> some View {
		environment(\.[StateStep<Value>.StepKey()], binding)
	}
}

public extension Binding where Value: StepsCollection, Value.AllSteps: ExpressibleByNilLiteral {

	func isSelected(_ step: Value.AllSteps) -> Binding<Bool> {
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
