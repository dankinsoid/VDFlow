//
//  File.swift
//  
//
//  Created by Данил Войдилов on 11.11.2021.
//

import Foundation
import SwiftUI
import VDSwiftUICommon
import VDBuilders

@dynamicMemberLookup
@propertyWrapper
public struct StateStep<Value: Equatable>: DynamicProperty {
	public var wrappedValue: Value {
		get { projectedValue.wrappedValue.wrappedValue }
		nonmutating set {
			let binding = projectedValue
			if binding.wrappedValue.wrappedValue != newValue {
				binding.wrappedValue.wrappedValue = newValue
			}
		}
	}
	public var step: Step<Value> {
		get { projectedValue.wrappedValue }
		nonmutating set {
			let binding = projectedValue
			if binding.wrappedValue != newValue {
				binding.wrappedValue = newValue
			}
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
	
	public subscript<T>(dynamicMember keyPath: WritableKeyPath<Value, Step<T>>) -> Tag<T> {
		Tag(selected: step.tag(keyPath), binding: (stepBinding ?? $defaultValue)[dynamicMember: (\Step<Value>.wrappedValue).appending(path: keyPath)])
	}
	
	public func select<T>(_ keyPath: WritableKeyPath<Value, Step<T>>) {
		step.select(keyPath)
	}
	
	public func tag<T>(_ keyPath: WritableKeyPath<Value, Step<T>>) -> Step<Value>.Selected {
		step.tag(keyPath)
	}
	
	@discardableResult
	public func move(_ offset: Int = 1, in steps: [Step<Value>.Selected]) -> Bool {
		step.move(offset, in: steps)
	}
	
	@discardableResult
	public func move(_ offset: Int = 1, @Step<Value>.TagsBuilder in steps: () -> [(Step<Value>) -> Step<Value>.Selected]) -> Bool {
		step.move(offset, in: steps)
	}
	
	public struct Tag<T> {
		var selected: Step<Value>.Selected
		var binding: Binding<Step<T>>
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
	
	public func step<Root: Equatable, Value: Equatable>(_ tag: StateStep<Root>.Tag<Value>) -> some View {
		stepEnvironment(tag.binding).tag(tag.selected)
	}
	
	public func step<Root: Equatable, Value: Equatable>(_ binding: Binding<Step<Root>>, _ keyPath: WritableKeyPath<Root, Step<Value>>) -> some View {
		stepEnvironment(binding[dynamicMember: (\Step<Root>.wrappedValue).appending(path: keyPath)]).tag(binding.wrappedValue.tag(keyPath))
	}
	
	public func stepEnvironment<Value: Equatable>(_ binding: Binding<Step<Value>>) -> some View {
		environment(\.[StateStep<Value>.StepKey()], binding)
	}
}
