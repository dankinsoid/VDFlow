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
	
	var current: (FlowTree, AnyHashable)? { id.flatMap { key in nodes[key.0].map { ($0.1, key.0) } } }
	private var nodes: [AnyHashable: (Any?, FlowTree)] = [:]
	@Published var id: (AnyHashable, Any?)?
	
	var path: FlowPath {
		FlowPath(id.map { key in
			[FlowStep(id: key.0, data: key.1)] + (nodes[key.0]?.1.path.steps ?? [])
		} ?? [])
	}
	
	subscript<ID>(_ value: ID, mapKey: @escaping (ID) -> AnyHashable) -> FlowTree {
		if let result = nodes[mapKey(value)]?.1 {
			return result
		}
		let tree = FlowTree()
		let key = mapKey(value)
		nodes[key] = (value, tree)
		return tree
	}
	
	func go<P: FlowPathConvertable>(to path: P) -> Bool {
		let steps = path.asPath().steps
		guard !steps.isEmpty else { return true }
		if steps.count == 1 {
			set(steps[0])
			return true
		}
		if let pare = nodes[steps[0].id],
			 pare.1.go(to: path.asPath().dropFirst()) {
			set(steps[0])
			return true
		}
		for (key, value) in nodes where value.1.go(to: path) {
			id = (key, value.0)
			return true
		}
		return false
	}
	
	func set<ID>(id: AnyHashable, value: ID?) {
		nodes[id]?.0 = value
		self.id = (id, value)
	}
	
	private func set(_ step: FlowStep) {
		nodes[step.id]?.0 = step.data
		self.id = (step.id, step.data)
	}
}

extension FlowTree {
	var recursiveCurrent: (FlowTree, AnyHashable)? { current?.0.recursiveCurrent ?? current }
}
