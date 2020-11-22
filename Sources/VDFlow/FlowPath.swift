//
//  FlowNode.swift
//  FlowStart
//
//  Created by Daniil on 02.11.2020.
//

import Foundation

public struct FlowPath {
	public var steps: [FlowStep]
	
	public init(_ steps: [FlowStep]) {
		self.steps = steps
	}
	
	public func through(_ steps: [FlowStep]) -> FlowPath {
		FlowPath(steps + self.steps)
	}
	
	public func through(_ steps: FlowStep...) -> FlowPath {
		through(steps)
	}
	
	public func animated(_ animated: Bool) -> FlowPath {
		FlowPath(steps.map { $0.animated(animated) })
	}
	
	public func dropFirst(_ count: Int = 1) -> FlowPath {
		FlowPath(Array(steps.dropFirst(count)))
	}
	
}

public struct FlowStep {
	
	public static let empty = FlowStep(move: .node(.id("emptyFlowStepID")), data: nil, animated: true)
	
	public static var current: FlowStep {
		get { FlowStorage.shared.currentStep ?? .empty }
		set { FlowStorage.shared.setToNavigate(newValue) }
	}
	
	public var move: Move
	var data: Any?
	public var animated: Bool
	
	public var id: String? {
		if case .node(.id(let id)) = move {
			return id
		}
		return nil
	}
	
	public var node: FlowNode? {
		if case .node(let node) = move {
			return node
		}
		return nil
	}
	
	public var offset: Int? {
		if case .offset(let offset) = move {
			return offset
		}
		return nil
	}
	
	var _id: String {
		switch move {
		case .node(.id(let id)): return id
		case .node(.type(let type)): return String(reflecting: type)
		case .offset(let offset): return "\(offset)"
		}
	}
	
	public func isNode(_ node: FlowNode) -> Bool {
		self.node == node
	}
	
	public func isNode<T>(id: NodeID<T>) -> Bool {
		self.id == id.id
	}
	
	public func valueIf<T>(id: NodeID<T>) -> T? {
		if isNode(id: id), let result = data as? T {
			return result
		}
		return nil
	}
	
	public func valueIf<T: FlowComponent>(type: T.Type) -> T.Value? {
		if isNode(.type(type)), let result = data as? T.Value {
			return result
		}
		return nil
	}
	
	public enum Move {
		case node(FlowNode), offset(Int)
	}
	
	public func through(_ steps: [FlowStep]) -> FlowPath {
		FlowPath(steps + [self])
	}
	
	public func through(_ steps: FlowStep...) -> FlowPath {
		through(steps)
	}
	
	public func animated(_ animated: Bool) -> FlowStep {
		var result = self
		result.animated = animated
		return result
	}
	
	static func move(_ move: Move, animated: Bool = true) -> FlowStep {
		FlowStep(move: move, data: nil, animated: animated)
	}
	
	public static func id<T>(_ id: NodeID<T>, data: T, animated: Bool = true) -> FlowStep {
		FlowStep(move: .node(.id(id.id)), data: data, animated: animated)
	}
	
	public static func id(_ id: NodeID<Void>, animated: Bool = true) -> FlowStep {
		FlowStep(move: .node(.id(id.id)), data: (), animated: animated)
	}
	
	public static func id(_ id: String, animated: Bool = true) -> FlowStep {
		FlowStep.id(NodeID<Void>(id), animated: animated)
	}
	
	public static func id<R: RawRepresentable>(_ id: R, animated: Bool = true) -> FlowStep where R.RawValue == String {
		FlowStep.id(NodeID<Void>(id), animated: animated)
	}
	
	public static func type<T: FlowComponent>(_ type: T.Type, data: T.Value, animated: Bool = true) -> FlowStep {
		FlowStep(move: .node(.type(type)), data: data, animated: animated)
	}
	
	public static func type<T: FlowComponent>(_ type: T.Type, animated: Bool = true) -> FlowStep where T.Value == Void {
		FlowStep(move: .node(.type(type)), data: (), animated: animated)
	}
	
	public static func next(animated: Bool = true) -> FlowStep {
		steps(1, animated: animated)
	}
	
	public static func back(animated: Bool = true) -> FlowStep {
		steps(-1, animated: animated)
	}
	
	public static func steps(_ count: Int, animated: Bool = true) -> FlowStep {
		FlowStep(move: .offset(count), animated: animated)
	}
	
}

public enum FlowNode: Equatable {
	
	case id(String), type(AnyFlowComponent.Type)
	
	public var id: String? {
		if case .id(let id) = self {
			return id
		}
		return nil
	}
	
	public static func == (lhs: FlowNode, rhs: FlowNode) -> Bool {
		switch (lhs, rhs) {
		case (.id(let left), .id(let right)): return left == right
		case (.type(let left), .type(let right)): return left == right
		default: return false
		}
	}
	
}
	
extension AnyFlowComponent {
	
	static var rootType: Any.Type {
		let selfType = Self.self
		if let wrapped = selfType as? WrapperAnyComponentProtocol.Type {
			return wrapped.baseType.rootType
		}
		return selfType
	}
	
	func canGo(to node: FlowNode?) -> Bool {
		guard let node = node else { return false }
		return isNode(node) || asFlow?.canNavigate(to: node) == true
	}
	
	func isNode(_ node: FlowNode?) -> Bool {
		switch node {
		case .id(let id):
			return self.id == id
		case .type(let anyType):
			return Self.rootType == anyType
		case nil:
			return false
		}
	}
	
}
