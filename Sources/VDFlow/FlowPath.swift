//
//  FlowNode.swift
//  FlowStart
//
//  Created by Daniil on 02.11.2020.
//

import Foundation

public struct FlowPath: ExpressibleByArrayLiteral {
	public var steps: [FlowStep]
	
	public init(arrayLiteral elements: FlowStep...) {
		steps = elements
	}
	
	public init<C: Collection>(_ steps: C) where C.Element == FlowStep {
		self.steps = Array(steps)
	}
	
	public func through<C: Collection>(_ steps: C) -> FlowPath where C.Element == FlowStep {
		FlowPath(steps + Array(self.steps))
	}
	
	public func through(_ steps: FlowStep...) -> FlowPath {
		through(steps)
	}
	
	public func animated(_ animated: Bool) -> FlowPath {
		FlowPath(steps.map { $0.animated(animated) })
	}
	
	public func dropFirst(_ count: Int = 1) -> FlowPath {
		FlowPath(steps.dropFirst(count))
	}
	
	public var asStep: FlowStep? { steps.count == 1 ? steps[0] : nil }
}

public struct FlowStep {
	
	public static let empty = FlowStep(id: NoneID(), data: nil, options: [])
	
	public static var current: FlowStep {
		get { FlowStorage.shared.currentStep ?? .empty }
		set { FlowStorage.shared.setToNavigate(newValue) }
	}
	
	public var id: FlowNode
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
		self.id.base as? ID == id
	}
	
	public func isNode<T, ID: Hashable>(id: NodeID<T, ID>) -> Bool {
		self.id.base as? ID == id.id
	}
	
	public func isNode<C: FlowComponent>(of type: C.Type) -> Bool where C.ID == String {
		String(reflecting: C.Content.self) == id.base as? String
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

public struct NoneID: Hashable { public init() {} }
public typealias FlowNode = AnyHashable
	
public protocol FlowPathConvertable {
	func asPath() -> FlowPath
}

extension FlowPathConvertable {
	public var finalStep: FlowStep? {
		asPath().steps.last
	}
}

extension FlowPath: FlowPathConvertable {
	public func asPath() -> FlowPath { self }
}

extension FlowStep: FlowPathConvertable {
	public func asPath() -> FlowPath { FlowPath([self]) }
}

extension NodeID: FlowPathConvertable {
	public func asPath() -> FlowPath { FlowStep(id: id, data: nil, options: []).asPath() }
}

extension FlowPathConvertable {
	public var node: FlowNode? { finalStep?.node }
}
