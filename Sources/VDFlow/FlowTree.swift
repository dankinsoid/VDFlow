//
//  FlowTree.swift
//  
//
//  Created by Данил Войдилов on 29.04.2021.
//

import Foundation
import SwiftUI

protocol AnyFlowTree {
	var path: FlowPath { get }
	var current: (AnyFlowTree, AnyHashable)? { get }
	var isActive: Bool { get nonmutating set }
	func go<P: FlowPathConvertable>(to path: P) -> Bool
}

extension AnyFlowTree {
	var recursiveCurrent: (AnyFlowTree, AnyHashable)? { current?.0.recursiveCurrent ?? current }
}

final class FlowTree<Value: Equatable>: AnyFlowTree, ObservableObject {
	
	var current: (AnyFlowTree, AnyHashable)? { nodes[key]?.1.isActive == true ? (nodes[key]!.1, key) : nil }
	var isActive = true
	private var nodes: [AnyHashable: (Value, AnyFlowTree)] = [:]
	@Published var id: Value
	private var key: AnyHashable { mapKey(id) }
	private let mapKey: (Value) -> AnyHashable
	
	var path: FlowPath {
		FlowPath([FlowStep(id: key, data: id)] + (nodes[key]?.1.path.steps ?? []))
	}
	
	init(id: Value, mapKey: @escaping (Value) -> AnyHashable) {
		self.id = id
		self.mapKey = mapKey
	}
	
	subscript<H: Equatable>(_ value: Value, map: (Value) -> AnyHashable) -> FlowTree<H>? {
		guard let result = nodes[map(value)]?.1 as? FlowTree<H> else { return nil }
		result.isActive = true
		result.nodes.forEach { $0.value.1.isActive = false }
		return result
	}
	
	subscript<H: Equatable>(_ value: Value, init: H, map: @escaping (Value) -> AnyHashable, mapKey: @escaping (H) -> AnyHashable) -> FlowTree<H> {
		if let result: FlowTree<H> = self[value, map] {
			return result
		}
		let tree = FlowTree<H>(id: `init`, mapKey: mapKey)
		nodes[map(value)] = (value, tree)
		return tree
	}
	
	func go<P: FlowPathConvertable>(to path: P) -> Bool {
		let steps = path.asPath().steps
		guard !steps.isEmpty else { return true }
		if steps.count == 1, let id = steps[0].id.base as? Value {
			set(id: id)
			return true
		}
		if let pare = nodes[steps[0].id],
			 pare.1.go(to: path.asPath().dropFirst()) {
			set(id: (steps[0].data as? Value) ?? pare.0)
			return true
		}
		for (_, value) in nodes where value.1.go(to: path) {
			set(id: value.0)
			return true
		}
		return false
	}
	
	private func set(id: Value) {
		isActive = true
		guard id != self.id else { return }
		self.id = id
	}
}

extension FlowTree where Value: Identifiable & Equatable {
	
	subscript<H: Hashable>(_ value: Value, init: H) -> FlowTree<H> {
		self[value, `init`, { $0.id }, { $0 }]
	}
	
	subscript<H: Identifiable & Equatable>(_ value: Value, init: H) -> FlowTree<H> {
		self[value, `init`, { $0.id }, { $0.id }]
	}
	
	subscript<H: Hashable & Identifiable>(_ value: Value, init: H) -> FlowTree<H> {
		self[value, `init`, { $0.id }, { $0.id }]
	}
}

extension FlowTree where Value: Hashable {
	
	subscript<H: Hashable>(_ value: Value, init: H) -> FlowTree<H> {
		self[value, `init`, { $0 }, { $0 }]
	}
	
	subscript<H: Identifiable & Equatable>(_ value: Value, init: H) -> FlowTree<H> {
		self[value, `init`, { $0 }, { $0.id }]
	}
	
	subscript<H: Hashable & Identifiable>(_ value: Value, init: H) -> FlowTree<H> {
		self[value, `init`, { $0 }, { $0.id }]
	}
}

extension FlowTree where Value: Hashable & Identifiable {
	
	subscript<H: Hashable>(_ value: Value, init: H) -> FlowTree<H> {
		self[value, `init`, { $0.id }, { $0 }]
	}
	
	subscript<H: Identifiable & Equatable>(_ value: Value, init: H) -> FlowTree<H> {
		self[value, `init`, { $0.id }, { $0.id }]
	}
	
	subscript<H: Hashable & Identifiable>(_ value: Value, init: H) -> FlowTree<H> {
		self[value, `init`, { $0.id }, { $0.id }]
	}
}
