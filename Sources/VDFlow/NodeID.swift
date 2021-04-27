//
//  NodeID.swift
//  FlowStart
//
//  Created by Daniil on 05.11.2020.
//

import Foundation

public struct NodeID<Value, ID: Hashable>: Hashable {
	public let id: ID
	
	public init(_ id: ID) {
		self.id = id
	}
	
	public func with(_ value: Value, options: FlowOptions = .animated) -> FlowStep {
		.id(self, data: value, options: options)
	}
	
	public subscript(_ value: Value, options: FlowOptions = .animated) -> FlowStep {
		with(value, options: options)
	}
}
