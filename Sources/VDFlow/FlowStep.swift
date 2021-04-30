//
//  File.swift
//  
//
//  Created by Данил Войдилов on 30.04.2021.
//

import Foundation

public struct FlowStep {
	
	public static let empty = FlowStep(id: NoneID(), data: nil, options: [])
	
	public static var current: FlowStep {
		get { (tree.recursiveCurrent?.1).map { FlowStep(id: $0, data: nil, options: []) } ?? .empty }
		set { _ = tree.go(to: newValue) }//FlowStorage.shared.setToNavigate(newValue) }
	}
	
	static let tree = FlowTree(id: RootID())
	
	public var id: AnyHashable
	public var data: Any?
	public var options: FlowOptions
	
	public var offset: Int {
		get { options.offset }
		set { options.offset = newValue }
	}
	
	public var animated: Bool {
		options.contains(.animated)
	}
	
	public func isNode<ID: Hashable>(_ id: ID) -> Bool {
		self.id == AnyHashable(id)
	}
	
	public func isNode<T, ID: Hashable>(id: NodeID<T, ID>) -> Bool {
		self.id == AnyHashable(id.id)
	}
	
	public func isNode<C: FlowComponent>(of type: C.Type) -> Bool where C.ID == String {
		AnyHashable(String(reflecting: C.Content.self)) == id
	}
	
	public func valueIf<T, ID: Hashable>(id: NodeID<T, ID>) -> T? {
		if isNode(id: id), let result = data as? T {
			return result
		}
		return nil
	}
	
	public func through(_ steps: [FlowStep]) -> FlowPath {
		FlowPath(steps + [self])
	}
	
	public func through(_ steps: FlowStep...) -> FlowPath {
		through(steps)
	}
	
	public func animated(_ animated: Bool) -> FlowStep {
		var result = self
		if animated { result.options.insert(.animated) } else { result.options.remove(.animated) }
		return result
	}
	
	public static func id<T, ID: Hashable>(_ id: NodeID<T, ID>, data: T, options: FlowOptions = .animated) -> FlowStep {
		FlowStep(id: id.id, data: data, options: options)
	}
	
	public static func id<ID: Hashable>(_ id: NodeID<Void, ID>, options: FlowOptions = .animated) -> FlowStep {
		FlowStep(id: id.id, data: (), options: options)
	}
	
	public static func id<ID: Hashable>(_ id: ID, options: FlowOptions = .animated) -> FlowStep {
		.id(NodeID<Void, ID>(id), options: options)
	}
	
	public static func type<T: FlowComponent>(_ type: T.Type, data: T.Value, options: FlowOptions = .animated) -> FlowStep where T.ID == String {
		.id(NodeID(String(reflecting: type)), data: data, options: options)
	}
	
	public static func type<T: FlowComponent>(_ type: T.Type, options: FlowOptions = .animated) -> FlowStep where T.Value == Void, T.ID == String {
		.type(type, data: (), options: options)
	}
	
	public static var next: FlowStep {
		steps(1)
	}
	
	public static var back: FlowStep {
		steps(-1)
	}
	
	public static func steps(_ count: Int) -> FlowStep {
		FlowStep(id: NoneID(), data: nil, options: .offset(Int16(count)))
	}
}

struct RootID: Hashable {}
