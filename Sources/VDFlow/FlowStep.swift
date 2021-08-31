//
//  File.swift
//  
//
//  Created by Данил Войдилов on 30.04.2021.
//

import Foundation
import SwiftUI

public struct FlowStep: CustomStringConvertible, Equatable {
    public static let empty = FlowStep.id(NoneID())
	
	public static var current: FlowStep {
		get { (FlowTree.root.recursiveCurrent?.1).map { FlowStep(id: $0) } ?? .empty }
		set { set(newValue) }
	}
	
	public static func set(_ new: FlowStep, animated: Bool = true) {
		FlowPath.set([new], animated: animated)
	}
	
	public static func set(_ new: FlowStep, animation: Animation?) {
		FlowPath.set([new], animation: animation)
	}
	
	public var id: AnyHashable
    
    public var description: String {
		id.description
	}
    
    init(id: AnyHashable) {
        self.id = id
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
    
//    public func encode(to encoder: Encoder) throws {
//        if let encodable = id.base as? Encodable {
//            try encodable.encode(to: encoder)
//        } else {
//            throw EncodingError.invalidValue(id.base, .init(codingPath: encoder.codingPath, debugDescription: "Non codable"))
//        }
//    }
	
	public static func id<ID: Hashable>(_ id: ID) -> FlowStep {
        FlowStep(id: id)
    }
	
	public static func type<Content>(_ type: Content.Type) -> FlowStep {
		id(String(reflecting: Content.self))
	}
}

struct RootID: Hashable, Codable, Equatable {
	var file: String
	var line: Int
}
