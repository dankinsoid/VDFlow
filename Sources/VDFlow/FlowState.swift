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
public struct FlowState<Value>: DynamicProperty {
	
	public var wrappedValue: Value {
		get { (node.id?.1 as? Value) ?? (node.id?.0.base as? Value) ?? defaultValue }
		nonmutating set {
			let pair = map(newValue)
			node.set(id: pair.0, value: pair.1)
		}
	}
	private let defaultValue: Value
	private let map: (Value) -> (AnyHashable, Value?)
	
	@EnvironmentObject var node: FlowTree
	
	public var path: FlowPath {
		get { node.path }
		set { _ = node.go(to: newValue) }
	}
	
	public var projectedValue: Binding<Value> { binding }
	
	public var binding: Binding<Value> {
		Binding(get: { wrappedValue }, set: { wrappedValue = $0 })
	}
	
	@discardableResult
	public func go<P: FlowPathConvertable>(to path: P) -> Bool {
		node.go(to: path)
	}
}

extension FlowState where Value: Hashable {
	
	public init(wrappedValue: Value) {
		self.defaultValue = wrappedValue
		self.map = { ($0, nil) }
	}
}

extension FlowState where Value: Identifiable {
	
	public init(wrappedValue: Value) {
		self.defaultValue = wrappedValue
		self.map = { ($0.id, $0) }
	}
}

extension FlowState where Value: Identifiable & Hashable {
	
	public init(wrappedValue: Value) {
		self.defaultValue = wrappedValue
		self.map = { ($0.id, $0) }
	}
}

extension View {
	public func flow<ID: Hashable>(_ state: FlowState<ID>, for id: ID) -> some View {
		FlowView(content: self) { $0[id, { $0 }] }
	}
	
	public func flow<ID: Identifiable>(_ state: FlowState<ID>, for id: ID) -> some View {
		FlowView(content: self) { $0[id, { $0.id }] }
	}
	
	public func flow<ID: Identifiable & Hashable>(_ state: FlowState<ID>, for id: ID) -> some View {
		FlowView(content: self) { $0[id, { $0.id }] }
	}
	
	public func rootFlow(file: String = #file, line: Int = #line) -> some View {
		environmentObject(FlowTree.root[RootID(file: file, line: line), { $0 }])
	}
}

struct FlowView<Content: View>: View {
	let content: Content
	var create: (FlowTree) -> FlowTree
	@EnvironmentObject var flow: FlowTree
	
	var body: some View {
		content.environmentObject(create(flow))
	}
}
