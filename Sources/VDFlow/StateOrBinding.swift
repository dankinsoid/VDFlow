import SwiftUI

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
/// A property wrapper that can represent either a `State` or a `Binding` to a value.
///
/// This type is used internally by VDFlow to handle both state ownership and binding scenarios
/// within the same property wrapper.
@propertyWrapper
enum StateOrBinding<Value>: DynamicProperty {

	/// A binding to an external value.
	case binding(Binding<Value>)
	/// State that is owned by this property wrapper.
	case state(State<Value>)

	/// The underlying value, which can be accessed or modified directly.
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

	/// A binding to the underlying value.
	/// 
	/// The projected value provides a binding, regardless of whether the value is stored as state or binding.
	var projectedValue: Binding<Value> {
		switch self {
		case let .binding(binding): return binding
		case let .state(state): return state.projectedValue
		}
	}

	/// Creates a property wrapper that owns the state of its value.
	///
	/// - Parameter wrappedValue: The initial value.
	init(wrappedValue: Value) {
		self = .state(.init(wrappedValue: wrappedValue))
	}

	/// Creates a property wrapper that owns the state of its value.
	///
	/// - Parameter wrappedValue: The initial value.
	/// - Returns: A StateOrBinding instance that owns its state.
	static func state(_ wrappedValue: Value) -> StateOrBinding {
		.state(.init(wrappedValue: wrappedValue))
	}
}
