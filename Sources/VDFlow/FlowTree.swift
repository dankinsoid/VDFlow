//
//  FlowTree.swift
//  
//
//  Created by Данил Войдилов on 29.04.2021.
//

import Foundation
import SwiftUI

final class FlowTree {
	
	static let root = FlowTree()
	
	var current: (FlowTree, AnyHashable)? { nodes[id].map { ($0, id) } }
	private var nodes: [AnyHashable: FlowTree] = [:]
	var id: AnyHashable = None()
	
	var path: FlowPath {
		FlowPath(
			[FlowStep(id: id)] + (nodes[id]?.path.steps ?? [])
		)
	}
	
	subscript(_ id: AnyHashable) -> (FlowTree, Bool) {
		if let result = nodes[id] {
			return (result, false)
		}
		let tree = FlowTree()
		nodes[id] = tree
		return (tree, true)
	}
	
	func way(by path: FlowPath) -> [(FlowTree, FlowStep)] {
		let steps = path.steps
		guard !steps.isEmpty else { return [] }
		
		if let pare = nodes[steps[0].id] {
			return [(self, steps[0])] + pare.way(by: path.dropFirst())
		}
		
		let result = nodes.map {
			($0.key, $0.value.way(by: path))
		}
		.sorted(by: { $0.1.count < $1.1.count })
		.last
		
		if let next = result, !next.1.isEmpty {
			return [(self, FlowStep(id: next.0))] + next.1
		} else if wrappedType(of: id.base) == wrappedType(of: steps[0].id.base) {
			return [(self, steps[0])]
		} else {
			return []
		}
	}
	
	func set(id: AnyHashable) {
		set(FlowStep(id: id))
	}
	
	func set(_ step: FlowStep) {
		self.id = step.id
	}
}

extension FlowTree {
	var recursiveCurrent: (FlowTree, AnyHashable)? {
		if current?.0.nodes.isEmpty == true {
			return nil
		}
		return current?.0.recursiveCurrent ?? current
	}
}

struct None: Hashable {}

private func wrappedType<T>(of any: T) -> Any.Type {
	(type(of: any) as? WrapperType.Type)?.recursiveType ?? type(of: any)
}

private protocol WrapperType {
	static var wrappedType: Any.Type { get }
}

extension WrapperType {
	static var recursiveType: Any.Type {
		(wrappedType as? WrapperType.Type)?.recursiveType ?? wrappedType
	}
}

extension Optional: WrapperType {
	static var wrappedType: Any.Type { Wrapped.self }
}
