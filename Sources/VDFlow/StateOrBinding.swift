import SwiftUI

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
@propertyWrapper
enum StateOrBinding<Value>: DynamicProperty {

	case binding(Binding<Value>)
	case state(State<Value>)

	var wrappedValue: Value {
		get {
			switch self {
			case let .binding(binding): return binding.wrappedValue
			case let .state(state): return state.wrappedValue
			}
		}
		nonmutating set {
			switch self {
			case let .binding(binding): binding.wrappedValue = newValue
			case let .state(state): state.wrappedValue = newValue
			}
		}
	}

	var projectedValue: Binding<Value> {
		switch self {
		case let .binding(binding): return binding
		case let .state(state): return state.projectedValue
		}
	}

	init(wrappedValue: Value) {
		self = .state(.init(wrappedValue: wrappedValue))
	}

	static func state(_ wrappedValue: Value) -> StateOrBinding {
		.state(.init(wrappedValue: wrappedValue))
	}
}
