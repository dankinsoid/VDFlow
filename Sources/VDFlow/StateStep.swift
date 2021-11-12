//
//  File.swift
//  
//
//  Created by Данил Войдилов on 11.11.2021.
//

import Foundation
import SwiftUI
import VDSwiftUICommon

@dynamicMemberLookup
@propertyWrapper
public struct StateStep<Value: Equatable>: DynamicProperty {
	public var wrappedValue: Value {
		get { stepBinding?.wrappedValue.wrappedValue ?? defaultValue.wrappedValue }
		nonmutating set {
			let binding = stepBinding ?? $defaultValue
			if binding.wrappedValue.wrappedValue != newValue {
				binding.wrappedValue.wrappedValue = newValue
			}
		}
	}
	public var projectedValue: Binding<Step<Value>> {
		stepBinding ?? $defaultValue
	}
	public var step: Step<Value> {
		get { stepBinding?.wrappedValue ?? defaultValue }
		nonmutating set {
			let binding = stepBinding ?? $defaultValue
			if binding.wrappedValue != newValue {
				binding.wrappedValue = newValue
			}
		}
	}
	@StateOrBinding private var defaultValue: Step<Value>
	@Environment(\.[StepKey()]) private var stepBinding
	
	
	public init<T>(wrappedValue: Value, _ selected: WritableKeyPath<Value, Step<T>>) {
		_defaultValue = .state(Step(wrappedValue, selected: selected))
	}
	
	public init(wrappedValue: Value) {
		_defaultValue = .state(Step(wrappedValue))
	}
	
	public init(_ binding: Binding<Step<Value>>) {
		_defaultValue = .binding(binding)
	}
	
	public subscript<T>(dynamicMember keyPath: WritableKeyPath<Value, Step<T>>) -> Tag<T> {
		Tag(selected: step.tag(keyPath), binding: (stepBinding ?? $defaultValue)[dynamicMember: (\Step<Value>.wrappedValue).appending(path: keyPath)])
	}
	
	public func select<T>(_ keyPath: WritableKeyPath<Value, Step<T>>) {
		step.select(keyPath)
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
