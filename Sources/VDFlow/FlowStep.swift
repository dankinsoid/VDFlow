//
//  File.swift
//  
//
//  Created by Данил Войдилов on 30.04.2021.
//

import Foundation
import SwiftUI

public struct FlowStep: CustomStringConvertible {
    public static let empty = FlowStep(id: NoneID(), data: nil)
	
	public static var current: FlowStep {
        get { (FlowTree.root.recursiveCurrent?.1).map { FlowStep(id: $0, data: nil) } ?? .empty }
		set { set(newValue) }
	}
	
	public static func set(_ new: FlowStep, animated: Bool = true) {
		FlowPath.set([new], animated: animated)
	}
	
	public static func set(_ new: FlowStep, animation: Animation?) {
		FlowPath.set([new], animation: animation)
	}
	
    public var id: AnyHashable
    public var data: Any?
    public var description: String {
        if let value = data, value as? None == nil {
            return "(\(id): \(value))"
        } else {
            return id.description
        }
    }
    
	public func isNode<ID: Hashable>(_ id: ID) -> Bool {
		self.id == AnyHashable(id)
	}
	
	public func isNode<Value: Identifiable>(_ value: Value) -> Bool {
		self.id == AnyHashable(value.id)
	}
	
	public func isNode<Value: Identifiable & Hashable>(_ value: Value) -> Bool {
		self.id == AnyHashable(value.id)
	}
	
	public func through(_ steps: [FlowStep]) -> FlowPath {
		FlowPath(steps + [self])
	}
	
	public func through(_ steps: FlowStep...) -> FlowPath {
		through(steps)
	}
	    
    public static func id<ID: Hashable>(_ id: ID) -> FlowStep {
        FlowStep(id: id, data: nil)
    }
    
    public static func value<Data: Identifiable>(_ data: Data) -> FlowStep {
        FlowStep(id: data.id, data: data)
    }
	
	public static func type<Content>(_ type: Content.Type) -> FlowStep {
		id(String(reflecting: Content.self))
	}
}

struct RootID: Hashable, Codable, Equatable {
	var file: String
	var line: Int
}
