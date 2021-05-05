//
//  File.swift
//  
//
//  Created by Данил Войдилов on 29.04.2021.
//

import Foundation
import SwiftUI
import VDKit

@available(iOS 13.0.0, *)
@propertyWrapper
public struct FlowState<Value: Equatable>: DynamicProperty {
	
	public var wrappedValue: Value {
		get { node.id }
		nonmutating set { node.id = newValue }
	}
	
	@Environment(\.flowEnvironment) private var flow: FlowEnvironmentType
	private let create: (FlowEnvironmentType) -> FlowTree<Value>
	var node: FlowTree<Value> { create(flow) }
	
	public var path: FlowPath {
		get { node.path }
		set { _ = node.go(to: newValue) }
	}
	
	public var projectedValue: Binding<Value> { binding }
	
	public var binding: Binding<Value> {
		Binding(get: { node.id }, set: { node.id = $0 })
	}
	
	init(create: @escaping (FlowEnvironmentType) -> FlowTree<Value>) {
		self.create = create
	}
	
	@discardableResult
	public func go<P: FlowPathConvertable>(to path: P) -> Bool {
		node.go(to: path)
	}
}

extension View {
	public func flow<ID: Equatable>(_ state: FlowState<ID>, for id: ID) -> some View {
		FlowView(content: self, flow: .init(tree: state.node, id: id))
	}
}

enum FlowEnvironmentKey: EnvironmentKey {
	static var defaultValue: FlowEnvironmentType { FlowEnvironment(tree: FlowStep.tree, id: RootID()) }
}

extension EnvironmentValues {
	var flowEnvironment: FlowEnvironmentType {
		get { self[FlowEnvironmentKey.self] }
		set { self[FlowEnvironmentKey.self] = newValue }
	}
}

protocol FlowEnvironmentType {
	func createHashable<T: Hashable>(value: T) -> FlowTree<T>
	func createIdentifiable<T: Identifiable & Equatable>(value: T) -> FlowTree<T>
}

struct FlowEnvironment<ID: Equatable>: FlowEnvironmentType {
	let tree: FlowTree<ID>
	var id: ID
	
	func createHashable<T: Hashable>(value: T) -> FlowTree<T> {
		tree[id, value, { $0 }]
	}
	
	func createIdentifiable<T: Identifiable & Equatable>(value: T) -> FlowTree<T> {
		tree[id, value, { $0.id }]
	}
}

struct FlowView<Content: View, Value: Equatable>: View {
	let content: Content
	let flow: FlowEnvironment<Value>
	
	var body: some View {
		content.environment(\.flowEnvironment, flow)
	}
}

extension FlowState where Value: Hashable {

	public init(wrappedValue: Value, file: String = #file, line: Int = #line) {
		let property = LazyProperty<FlowEnvironmentType, FlowTree<Value>> {
			if var root = $0 as? FlowEnvironment<RootID> {
				root.id = .init(file: file, line: line)
				return root.createHashable(value: wrappedValue)
			} else {
				return $0.createHashable(value: wrappedValue)
			}
		}
		self = .init(create: property.value)
	}
}

extension FlowState where Value: Identifiable & Equatable {
	
	public init(wrappedValue: Value, file: String = #file, line: Int = #line) {
		let property = LazyProperty<FlowEnvironmentType, FlowTree<Value>> {
			if var root = $0 as? FlowEnvironment<RootID> {
				root.id = .init(file: file, line: line)
				return root.createIdentifiable(value: wrappedValue)
			} else {
				return $0.createIdentifiable(value: wrappedValue)
			}
		}
		self = .init(create: property.value)
	}
}

extension FlowState where Value: Identifiable & Hashable {
	
	public init(wrappedValue: Value, file: String = #file, line: Int = #line) {
		let property = LazyProperty<FlowEnvironmentType, FlowTree<Value>> {
			if var root = $0 as? FlowEnvironment<RootID> {
				root.id = .init(file: file, line: line)
				return root.createIdentifiable(value: wrappedValue)
			} else {
				return $0.createIdentifiable(value: wrappedValue)
			}
		}
		self = .init(create: property.value)
	}
}

private final class LazyProperty<A, T> {
	private let create: (A) -> T
	private var wrappedValue: T?
	
	func value(_ value: A) -> T {
		if let result = wrappedValue { return result }
		let result = create(value)
		wrappedValue = result
		return result
	}
	
	init(_ create: @escaping (A) -> T) { self.create = create }
}
