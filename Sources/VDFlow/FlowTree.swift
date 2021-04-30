//
//  File.swift
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

final class FlowTree<ID: Hashable>: AnyFlowTree, ObservableObject {
	
	var current: (AnyFlowTree, AnyHashable)? { nodes[id]?.isActive == true ? (nodes[id]!, id) : nil }
	var isActive = true
	private var nodes: [ID: AnyFlowTree] = [:]
	@Published var id: ID
	
	var path: FlowPath {
		FlowPath([FlowStep(id: id, data: nil, options: [])] + (nodes[id]?.path.steps ?? []))
	}
	
	init(id: ID) {
		self.id = id
	}
	
	subscript<H: Hashable>(_ id: ID) -> FlowTree<H>? {
		if let result = nodes[id] as? FlowTree<H> {
			result.isActive = true
			result.nodes.forEach { $0.value.isActive = false }
			return result
		}
		return nil
	}
	
	subscript<H: Hashable>(_ id: ID, init value: H) -> FlowTree<H> {
		if let result: FlowTree<H> = self[id] {
			return result
		}
		let tree = FlowTree<H>(id: value)
		nodes[id] = tree
		return tree
	}
	
	func go<P: FlowPathConvertable>(to path: P) -> Bool {
		let steps = path.asPath().steps
		guard !steps.isEmpty else { return true }
		if steps.count == 1, let id = steps[0].id.base as? ID {
			isActive = true
			set(id: id)
			return true
		}
		if let id = steps[0].id.base as? ID,
			 let node = nodes[id],
			 node.go(to: path.asPath().dropFirst()) {
			isActive = true
			set(id: id)
			return true
		}
		for (key, value) in nodes {
			if value.go(to: path) {
				isActive = true
				set(id: key)
				return true
			}
		}
		return false
	}
	
	private func set(id: ID) {
		self.id = id
	}
}
