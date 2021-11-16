//
//  File.swift
//  
//
//  Created by Данил Войдилов on 11.11.2021.
//

import Foundation
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
	
	public var projectedValue: Binding<Step<Value>> {
		switch _defaultValue {
		case .binding(let binding): return binding
		case .state(let state): return stepBinding ?? state.projectedValue
		}
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
	
	public subscript<T>(dynamicMember keyPath: WritableKeyPath<Value, Step<T>>) -> StepBinding<T> {
		stepBinding(keyPath)
	}
	
	public func stepBinding<T>(_ keyPath: WritableKeyPath<Value, Step<T>>) -> StepBinding<T> {
		StepBinding(
			selected: step.key(keyPath),
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
	
	@dynamicMemberLookup
	public struct StepBinding<T>: Identifiable {
		public var id: UUID { selected.id }
		var selected: Step<Value>.Key
		var rootBinding: Binding<Step<Value>>
		var keyPath: WritableKeyPath<Value, Step<T>>
		var binding: Binding<Step<T>> { rootBinding[dynamicMember: (\Step<Value>.wrappedValue).appending(path: keyPath)] }
		
		public subscript<A>(dynamicMember keyPath: WritableKeyPath<T, Step<A>>) -> StateStep<T>.StepBinding<A> {
			StateStep<T>.StepBinding<A>(
				selected: binding.wrappedValue.key(keyPath),
				rootBinding: binding,
				keyPath: keyPath
			)
		}
	}
	
	struct StepKey: EnvironmentKey, Hashable {
		static var defaultValue: Binding<Step<Value>>? { nil }
	}
}

extension StateStep where Value: MutableCollection, Value.Index: Hashable {
	
	public func allStepBindings<T>() -> [StepBinding<T>] where Value.Element == Step<T> {
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
}

extension View {
	
	public func step<Root, Value>(_ stepBinding: StateStep<Root>.StepBinding<Value>) -> some View {
		stepEnvironment(stepBinding.binding)
			.tag(stepBinding)
	}
	
	public func step<Root, Value>(_ binding: Binding<Step<Root>>, _ keyPath: WritableKeyPath<Root, Step<Value>>) -> some View {
		stepEnvironment(binding[dynamicMember: (\Step<Root>.wrappedValue).appending(path: keyPath)])
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
	public func tag<Root, Value>(_ stepBinding: StateStep<Root>.StepBinding<Value>) -> some View {
		tag(stepBinding.selected)
	}
}
