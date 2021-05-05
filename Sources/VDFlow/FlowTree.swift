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
	func go<P: FlowPathConvertable>(to path: P) -> Bool
}

extension AnyFlowTree {
	var recursiveCurrent: (AnyFlowTree, AnyHashable)? { current?.0.recursiveCurrent ?? current }
}

final class FlowTree<Value: Equatable>: AnyFlowTree, ObservableObject {
	
	var current: (AnyFlowTree, AnyHashable)? { nodes[key].map { ($0.1, key) } }
	private var nodes: [AnyHashable: (Value, AnyFlowTree)] = [:]
	@Published var id: Value
	private var key: AnyHashable { mapKey(id) }
	private let mapKey: (Value) -> AnyHashable
	
	var path: FlowPath {
		FlowPath(
			[FlowStep(id: key, data: (id == key.base as? Value) ? nil : id)] + (nodes[key]?.1.path.steps ?? [])
		)
	}
	
	init(id: Value, mapKey: @escaping (Value) -> AnyHashable) {
		self.id = id
		self.mapKey = mapKey
	}
	
	private subscript<H: Equatable>(_ value: Value) -> FlowTree<H>? {
		guard let result = nodes[mapKey(value)]?.1 as? FlowTree<H> else { return nil }
		return result
	}
	
	subscript<H: Equatable>(_ value: Value, init: H, mapKey: @escaping (H) -> AnyHashable) -> FlowTree<H> {
		if let result: FlowTree<H> = self[value] {
			return result
		}
		let tree = FlowTree<H>(id: `init`, mapKey: mapKey)
		nodes[self.mapKey(value)] = (value, tree)
		return tree
	}
	
	func go<P: FlowPathConvertable>(to path: P) -> Bool {
		let steps = path.asPath().steps
		guard !steps.isEmpty else { return true }
		if steps.count == 1, let id = (steps[0].id.base as? Value) ?? (steps[0].data as? Value) {
			set(id: id)
			return true
		}
		if let pare = nodes[steps[0].id],
			 pare.1.go(to: path.asPath().dropFirst()) {
			set(id: (steps[0].id.base as? Value) ?? (steps[0].data as? Value) ?? pare.0)
			return true
		}
		for (_, value) in nodes where value.1.go(to: path) {
			set(id: value.0)
			return true
		}
		return false
	}
	
	private func set(id: Value) {
		guard id != self.id else { return }
		self.id = id
	}
}
