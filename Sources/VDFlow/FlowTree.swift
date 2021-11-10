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
  
  var current: (FlowTree, AnyHashable)? { nodes[id.0].map { ($0.1, id.0) } }
  var currentFlow: FlowTree {
    current?.0.nodes.isEmpty == false ? current?.0.currentFlow ?? self : self
  }
  private var nodes: [AnyHashable: (AnyEquatable, FlowTree)] = [:]
  var id: (AnyHashable, AnyEquatable) = (None(), AnyEquatable(None()))
  
  var path: FlowPath {
    FlowPath(
      [FlowStep(id: id.0, _data: id.1)] + (nodes[id.0]?.1.path.steps ?? [])
    )
  }
  
  subscript(_ value: AnyEquatable?, id: AnyHashable) -> (FlowTree, Bool) {
    if let result = nodes[id]?.1 {
      return (result, false)
    }
    let tree = FlowTree()
    nodes[id] = (value ?? AnyEquatable(None()), tree)
    return (tree, true)
  }
  
  func way(by path: FlowPath) -> [(FlowTree, FlowStep)] {
    let steps = path.steps
    guard !steps.isEmpty else { return [] }
    
    if let pare = nodes[steps[0].id] {
      return [(self, steps[0])] + pare.1.way(by: path.dropFirst())
    }
    
    let result = nodes.map {
      ($0.key, $0.value.0, $0.value.1.way(by: path))
    }
      .sorted(by: { $0.2.count < $1.2.count })
      .last
    
    if let next = result, !next.2.isEmpty {
      return [(self, FlowStep(id: next.0, _data: next.1))] + next.2
    } else if wrappedType(of: id.0.base) == wrappedType(of: steps[0].id.base) {
      return [(self, steps[0])]
    } else {
      return []
    }
  }
  
	func set<ID: Equatable>(id: AnyHashable, value: ID?) {
		set(FlowStep(id: id, _data: value.map { AnyEquatable($0) }))
  }
  
  func set(_ step: FlowStep) {
    nodes[step.id]?.0 = step._data ?? AnyEquatable(None())
    self.id = (step.id, step._data ?? AnyEquatable(None()))
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
