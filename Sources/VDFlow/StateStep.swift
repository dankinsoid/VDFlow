//
//  File.swift
//  
//
//  Created by Данил Войдилов on 11.11.2021.
//

import Foundation
import SwiftUI

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
	@StateOrBinding private var defaultValue: Step<Value>
	@Environment(\.[StepKey()]) private var stepBinding
	public var projectedValue: Binding<Step<Value>> {
		if case .binding(let binding) = _defaultValue {
			return binding
		}
		return stepBinding ?? $defaultValue
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
			binding: projectedValue[dynamicMember: (\Step<Value>.wrappedValue).appending(path: keyPath)]
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
	public struct StepBinding<T> {
		var selected: Step<Value>.Key
		var binding: Binding<Step<T>>
		
		public subscript<A>(dynamicMember keyPath: WritableKeyPath<T, Step<A>>) -> StateStep<T>.StepBinding<A> {
			StateStep<T>.StepBinding<A>(
				selected: binding.wrappedValue.key(keyPath),
				binding: binding[dynamicMember: (\Step<T>.wrappedValue).appending(path: keyPath)]
			)
		}
	}
	
	struct StepKey: EnvironmentKey, Hashable {
		static var defaultValue: Binding<Step<Value>>? { nil }
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
	
	public func tag<Root, Value>(_ stepBinding: StateStep<Root>.StepBinding<Value>) -> some View {
		tag(stepBinding.selected)
	}
}
