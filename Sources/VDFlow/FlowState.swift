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
public struct FlowState<ID: Hashable>: DynamicProperty {
	
	public var wrappedValue: ID {
		get { node.id }
		nonmutating set { node.id = newValue }
	}
	
	@ObservedObject var node: FlowTree<ID>
	
	public var path: FlowPath {
		get { node.path }
		set { _ = node.go(to: newValue) }
	}
	public var _asState: FlowState<ID> { self }
	
	@available(iOS 13.0.0, *)
	public var projectedValue: Binding<ID> {
		Binding(get: { node.id }, set: { node.id = $0 })
	}
	
	init(_ tree: FlowTree<ID>) {
		self.node = tree
	}
	
	public subscript<H: Hashable>(_ id: ID) -> FlowState<H?> {
		self[id, default: nil]
	}
	
	public subscript<H: Hashable>(_ id: ID, default value: H) -> FlowState<H> {
		FlowState<H>(node[id, init: value])
	}
}

extension FlowState {
	public static func root(_ id: ID) -> FlowState {
		FlowState(FlowStep.tree[FlowStep.tree.id, init: id])
	}
}

@available(iOS 13.0.0, *)
final class Updater: ObservableObject {
	@Published var change = false
}
