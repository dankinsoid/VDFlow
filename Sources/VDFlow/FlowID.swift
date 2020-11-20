//
//  FlowID.swift
//  FlowStart
//
//  Created by Daniil on 05.11.2020.
//

import Foundation

public struct FlowID<Value>: Hashable, Codable {
	public let id: String
	
	public init(_ id: String = UUID().uuidString) {
		self.id = id
	}
	
	public init<R: RawRepresentable>(_ value: R) where R.RawValue == String {
		self.id = String(reflecting: R.self) + "." + value.rawValue
	}
	
	public func with(_ value: Value, animated: Bool = true) -> FlowPoint {
		FlowPoint.id(self, data: value, animated: animated)
	}
	
}
