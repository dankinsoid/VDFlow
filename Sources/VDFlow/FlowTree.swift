//
//  FlowTree.swift
//  
//
//  Created by Данил Войдилов on 29.04.2021.
//

import Foundation
import SwiftUI

final class FlowTree: ObservableObject {
	
	static let root = FlowTree()
	
	var current: (FlowTree, AnyHashable)? { nodes[id.0].map { ($0.1, id.0) } }
	private var nodes: [AnyHashable: (Any, FlowTree)] = [:]
	@Published var id: (AnyHashable, Any) = (None(), None())
	
	var path: FlowPath {
		FlowPath(
			[FlowStep(id: id.0, data: id.1)] + (nodes[id.0]?.1.path.steps ?? [])
		)
	}
	
	subscript(_ value: Any?, id: AnyHashable) -> FlowTree {
		if let result = nodes[id]?.1 {
			return result
		}
		let tree = FlowTree()
		nodes[id] = (value ?? None(), tree)
		return tree
	}
	
	func go<P: FlowPathConvertable>(to path: P) -> Bool {
		let steps = path.asPath().steps
		guard !steps.isEmpty else { return true }
		if let pare = nodes[steps[0].id],
			 pare.1.go(to: path.asPath().dropFirst()) {
			set(steps[0])
			return true
		}
		for (key, value) in nodes where value.1.go(to: path) {
			id = (key, value.0)
			return true
		}
		if steps.count == 1 {
			set(steps[0])
			return true
		}
		return false
	}
	
	func set<ID>(id: AnyHashable, value: ID) {
		nodes[id]?.0 = value
		self.id = (id, value)
	}
	
	private func set(_ step: FlowStep) {
		nodes[step.id]?.0 = step.data ?? None()
		self.id = (step.id, step.data ?? None())
	}
}

extension FlowTree {
	var recursiveCurrent: (FlowTree, AnyHashable)? { current?.0.recursiveCurrent ?? current }
}

struct None: Hashable {}
