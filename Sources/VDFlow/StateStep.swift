import SwiftUI

/// A property wrapper type that stores or binds a ``VDFlow/Step``  and invalidates a view whenever the step changes.
///
///     @StateStep var router = StepsStruct()
///     @StateStep(\.defaultStep) var router = StepsStruct()
///     let stepState = StateStep(stepBinding)
@dynamicMemberLookup
@propertyWrapper
public struct StateStep<Value>: DynamicProperty {
	
	public var wrappedValue: Value {
		get { projectedValue.wrappedValue.wrappedValue }
		nonmutating set {
			projectedValue.wrappedValue.wrappedValue = newValue
		}
	}
	
	public var step: Step<Value> {
		get { projectedValue.wrappedValue }
		nonmutating set {
			projectedValue.wrappedValue = newValue
		}
	}
	
	public var selected: Step<Value>.Key {
		get { step.selected }
		nonmutating set { step.selected = newValue }
	}
	
	@StateOrBinding private var defaultValue: Step<Value>
	
	@Environment(\.[StepKey()]) private var stepBinding
	@Environment(\.unselectStep) private var unselectClosure
	
	public var projectedValue: Binding<Step<Value>> {
		switch _defaultValue {
		case .binding(let binding): return binding
		case .state(let state): return stepBinding ?? state.projectedValue
		}
	}
    
	public var allKeys: [Step<Value>.Key] {
    step.allKeys
	}
	
	public init<T>(wrappedValue: Value, _ selected: WritableKeyPath<Value, Step<T>>) {
		self.init(binding: .state(Step(wrappedValue, selected: selected)))
	}
	
	public init(wrappedValue: Value) {
		self.init(binding: .state(Step(wrappedValue)))
	}
	
	public init(_ binding: Binding<Step<Value>>) {
		self.init(binding: .binding(binding))
	}
	
	private init(binding: StateOrBinding<Step<Value>>) {
		_defaultValue = binding
	}
	
	public subscript<T>(dynamicMember keyPath: WritableKeyPath<Value, Step<T>>) -> StepBinding<Value, T> {
		stepBinding(keyPath)
	}
	
	public func stepBinding<T>(_ keyPath: WritableKeyPath<Value, Step<T>>) -> StepBinding<Value, T> {
		StepBinding(
			rootBinding: projectedValue,
			keyPath: keyPath
		)
	}
	
	public func select<T>(_ keyPath: WritableKeyPath<Value, Step<T>>) {
		step.select(keyPath)
	}
	
	public func key<T>(_ keyPath: WritableKeyPath<Value, Step<T>>) -> Step<Value>.Key {
		step.key(keyPath)
	}
	
	@discardableResult
	public func move(_ offset: Int = 1, in steps: [Step<Value>.Key]) -> Bool {
		step.move(offset, in: steps)
	}
	
	@discardableResult
	public func move(_ offset: Int = 1, @Step<Value>.TagsBuilder in steps: () -> [(Step<Value>) -> Step<Value>.Key]) -> Bool {
		step.move(offset, in: steps)
	}
	
	public func unselect(stepsCount: Int = 1) {
		guard !unselectClosure.isEmpty else {
			Environment(\.presentationMode).wrappedValue.wrappedValue.dismiss()
			return
		}
		unselectClosure[min(unselectClosure.count - 1, max(0, stepsCount - 1))]()
	}
	
	struct StepKey: EnvironmentKey, Hashable {
		static var defaultValue: Binding<Step<Value>>? { nil }
	}
}

extension StateStep where Value == EmptyStep {
    
	public init() {
		self.init(wrappedValue: EmptyStep())
	}
}

extension StateStep where Value: MutableCollection, Value.Index: Hashable {
	
	public func allStepBindings<T>() -> [StepBinding<Value, T>] where Value.Element == Step<T> {
		wrappedValue.indices.map {
			stepBinding(\.[$0])
		}
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

extension View {
	
	public func step<Root, Value>(_ stepBinding: StepBinding<Root, Value>) -> some View {
		step(stepBinding.rootBinding, stepBinding.keyPath)
	}
	
	public func step<Root, Value>(_ binding: Binding<Step<Root>>, _ keyPath: WritableKeyPath<Root, Step<Value>>) -> some View {
		stepEnvironment(binding[dynamicMember: (\Step<Root>.wrappedValue).appending(path: keyPath)])
			.transformEnvironment(\.unselectStep) {
				$0.insert({ binding.wrappedValue.selected = .none }, at: 0)
			}
			.tag(binding.wrappedValue.key(keyPath))
	}
	
	public func stepEnvironment<Value>(_ binding: Binding<Step<Value>>) -> some View {
		environment(\.[StateStep<Value>.StepKey()], binding)
	}
	
	/// Sets the unique tag value of this view.
	///
	///     struct FlowerPicker: View {
	///
	///         @StateStep private var selectedFlower = FlowerSteps()
	///
	///	            var body: some View {
	///                 Picker("Flower", selection: $selectedFlower.selected) {
	///                     Text("Rose")
	///                         .tag(_selectedFlower.rose)
	///                     Text("Lily")
	///                         .tag(_selectedFlower.lily)
	///                     Text("Dandelion")
	///                         .tag(_selectedFlower.stepBinding(\.dandelion))
	///             }
	///         }
	///     }
	///
	/// - Parameter stepBinding: A `StepBinding` value to create the view's tag.
	///
	/// - Returns: A view with the specified tag set.
	public func tag<Root, Value>(_ stepBinding: StepBinding<Root, Value>) -> some View {
		tag(stepBinding.selected)
	}
}

public extension Binding {
    
    func isSelected<Root, T>(_ keyPath: WritableKeyPath<Root, Step<T>>) -> Binding<Bool> where Value == Step<Root> {
        Binding<Bool> {
            wrappedValue.isSelected(keyPath)
        } set: {
            if $0 {
                wrappedValue.select(keyPath)
            } else {
                wrappedValue.unselect(keyPath)
            }
        }
    }
    
    func stepBinding<Root, T>(_ keyPath: WritableKeyPath<Root, Step<T>>) -> StepBinding<Root, T> where Value == Step<Root> {
        StepBinding(
            rootBinding: self,
            keyPath: keyPath
        )
    }
}
