//
//  FlowPoint.swift
//  FlowStart
//
//  Created by Daniil on 02.11.2020.
//

import Foundation

public struct FlowPath {
	public var points: [FlowPoint]
	
	public init(_ points: [FlowPoint]) {
		self.points = points
	}
	
	public func through(_ points: [FlowPoint]) -> FlowPath {
		FlowPath(points + self.points)
	}
	
	public func through(_ points: FlowPoint...) -> FlowPath {
		through(points)
	}
	
	public func animated(_ animated: Bool) -> FlowPath {
		FlowPath(points.map { $0.animated(animated) })
	}
	
	public func dropFirst(_ count: Int = 1) -> FlowPath {
		FlowPath(Array(points.dropFirst(count)))
	}
	
}

public enum FlowStep {
	case point(FlowPoint), move(FlowMove)
	
	var move: Int? {
		if case .move(let move) = self {
			return move.move
		}
		return nil
	}
	
	var point: FlowPoint? {
		if case .point(let point) = self {
			return point
		}
		return nil
	}
	
	var animated: Bool {
		switch self {
		case .move(let move): 	return move.animated
		case .point(let point):	return point.animated
		}
	}
}

public struct FlowMove {
	var move: Int
	var animated: Bool
	
	public static func next(animated: Bool = true) -> FlowMove {
		steps(1, animated: animated)
	}
	
	public static func back(animated: Bool = true) -> FlowMove {
		steps(-1, animated: animated)
	}
	
	public static func steps(_ count: Int, animated: Bool = true) -> FlowMove {
		FlowMove(move: count, animated: animated)
	}
}

public struct FlowPoint {
	let type: ID
	var animated: Bool
	let data: Any?
	var move: Int?
	
	public var id: String? {
		if case .id(let id) = type {
			return id
		}
		return nil
	}
	
	public func through(_ points: [FlowPoint]) -> FlowPath {
		FlowPath(points + [self])
	}
	
	public func through(_ points: FlowPoint...) -> FlowPath {
		through(points)
	}
	
	public func animated(_ animated: Bool) -> FlowPoint {
		var result = self
		result.animated = animated
		return result
	}
	
	enum ID {
		case id(String), type(AnyFlowComponent.Type)
	}
	
	private init(type: ID, animated: Bool, data: Any?) {
		self.type = type
		self.animated = animated
		self.data = data
	}

//	public func isID<T>(_ id: FlowID<T>) -> Bool {
//	}
	
	public static func id<T>(_ id: FlowID<T>, data: T, animated: Bool = true) -> FlowPoint {
		FlowPoint(type: .id(id.id), animated: animated, data: data)
	}
	
	public static func id(_ id: FlowID<Void>, animated: Bool = true) -> FlowPoint {
		FlowPoint(type: .id(id.id), animated: animated, data: ())
	}
	
	public static func id(_ id: String, animated: Bool = true) -> FlowPoint {
		FlowPoint.id(FlowID<Void>(id), animated: animated)
	}
	
	public static func id<R: RawRepresentable>(_ id: R, animated: Bool = true) -> FlowPoint where R.RawValue == String {
		FlowPoint.id(id.rawValue, animated: animated)
	}
	
	public static func type<T: FlowComponent>(_ type: T.Type, data: T.Value, animated: Bool = true) -> FlowPoint {
		FlowPoint(type: .type(type), animated: animated, data: data)
	}
	
	public static func type<T: FlowComponent>(_ type: T.Type, animated: Bool = true) -> FlowPoint where T.Value == Void {
		FlowPoint(type: .type(type), animated: animated, data: ())
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
	
	func canGo(to point: FlowPoint?) -> Bool {
		guard let point = point else { return false }
		return _ifNavigate(to: point) != nil
	}
	
	func _ifNavigate(to point: FlowPoint) -> AnyFlowComponent? {
		return isPoint(point) ? self : asFlow?.ifNavigate(to: point)
	}
	
	func isPoint(_ point: FlowPoint) -> Bool {
		switch point.type {
		case .id(let id):
			return self.id == id
		case .type(let anyType):
			return Self.rootType == anyType
		}
	}
	
}
