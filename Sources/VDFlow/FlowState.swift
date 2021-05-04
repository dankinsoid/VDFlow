//
//  File.swift
//  
//
//  Created by Данил Войдилов on 29.04.2021.
//

import Foundation
import SwiftUI

@available(iOS 13.0.0, *)
@propertyWrapper
public struct FlowState<Value: Equatable>: DynamicProperty {
	
	public var wrappedValue: Value {
		get { node.id }
		nonmutating set { node.id = newValue }
	}
	
	@ObservedObject var node: FlowTree<Value>
	
	public var path: FlowPath {
		get { node.path }
		set { _ = node.go(to: newValue) }
	}
	
	public var projectedValue: Binding<Value> {
		Binding(get: { node.id }, set: { node.id = $0 })
	}
	
	init(_ tree: FlowTree<Value>) {
		self.node = tree
	}
}

extension FlowState where Value: Hashable {
	
	public init(wrappedValue: Value, file: String = #file, line: Int = #line) {
		self = .init(FlowStep.tree[RootID(file: file, line: line), wrappedValue])
	}
	
	public subscript<H: Hashable>(_ id: Value) -> FlowState<H?> {
		self[id, default: nil]
	}
	
	public subscript<H: Hashable>(_ id: Value, default value: H) -> FlowState<H> {
		FlowState<H>(node[id, value])
	}
	
	public subscript<H: Identifiable & Equatable>(_ id: Value, default value: H) -> FlowState<H> {
		FlowState<H>(node[id, value])
	}
	
	public subscript<H: Identifiable & Hashable>(_ id: Value, default value: H) -> FlowState<H> {
		FlowState<H>(node[id, value])
	}
	
	public func bind<H: Hashable>(_ id: Value) -> Binding<H?> {
		self[id, default: nil].projectedValue
	}
	
	public func bind<H: Hashable>(_ id: Value, default value: H) -> Binding<H> {
		FlowState<H>(node[id, value]).projectedValue
	}
	
	public func bind<H: Identifiable & Equatable>(_ id: Value, default value: H) -> Binding<H> {
		FlowState<H>(node[id, value]).projectedValue
	}
	
	public func bind<H: Identifiable & Hashable>(_ id: Value, default value: H) -> Binding<H> {
		FlowState<H>(node[id, value]).projectedValue
	}
}

extension FlowState where Value: Identifiable & Equatable {
	
	public init(wrappedValue: Value, file: String = #file, line: Int = #line) {
		self = .init(FlowStep.tree[RootID(file: file, line: line), wrappedValue])
	}
	
	public subscript<H: Hashable>(_ id: Value) -> FlowState<H?> {
		self[id, default: nil]
	}
	
	public subscript<H: Hashable>(_ id: Value, default value: H) -> FlowState<H> {
		FlowState<H>(node[id, value])
	}
	
	public subscript<H: Identifiable & Equatable>(_ id: Value, default value: H) -> FlowState<H> {
		FlowState<H>(node[id, value])
	}
	
	public subscript<H: Identifiable & Hashable>(_ id: Value, default value: H) -> FlowState<H> {
		FlowState<H>(node[id, value])
	}
	
	public func bind<H: Hashable>(_ id: Value) -> Binding<H?> {
		self[id, default: nil].projectedValue
	}
	
	public func bind<H: Hashable>(_ id: Value, default value: H) -> Binding<H> {
		FlowState<H>(node[id, value]).projectedValue
	}
	
	public func bind<H: Identifiable & Equatable>(_ id: Value, default value: H) -> Binding<H> {
		FlowState<H>(node[id, value]).projectedValue
	}
	
	public func bind<H: Identifiable & Hashable>(_ id: Value, default value: H) -> Binding<H> {
		FlowState<H>(node[id, value]).projectedValue
	}
}

extension FlowState where Value: Identifiable & Hashable {
	
	public init(wrappedValue: Value, file: String = #file, line: Int = #line) {
		self = .init(FlowStep.tree[RootID(file: file, line: line), wrappedValue])
	}
	
	public subscript<H: Hashable>(_ id: Value) -> FlowState<H?> {
		self[id, default: nil]
	}
	
	public subscript<H: Hashable>(_ id: Value, default value: H) -> FlowState<H> {
		FlowState<H>(node[id, value])
	}
	
	public subscript<H: Identifiable & Equatable>(_ id: Value, default value: H) -> FlowState<H> {
		FlowState<H>(node[id, value])
	}
	
	public subscript<H: Identifiable & Hashable>(_ id: Value, default value: H) -> FlowState<H> {
		FlowState<H>(node[id, value])
	}
	
	public func bind<H: Hashable>(_ id: Value) -> Binding<H?> {
		self[id, default: nil].projectedValue
	}
	
	public func bind<H: Hashable>(_ id: Value, default value: H) -> Binding<H> {
		FlowState<H>(node[id, value]).projectedValue
	}
	
	public func bind<H: Identifiable & Equatable>(_ id: Value, default value: H) -> Binding<H> {
		FlowState<H>(node[id, value]).projectedValue
	}
	
	public func bind<H: Identifiable & Hashable>(_ id: Value, default value: H) -> Binding<H> {
		FlowState<H>(node[id, value]).projectedValue
	}
}
