//
//  FlowArrayConvertable.swift
//  FlowStart
//
//  Created by Daniil on 05.11.2020.
//

import Foundation

public protocol FlowArrayConvertable {
	func asFlowArray() -> [AnyFlowComponent]
}

extension Array: FlowArrayConvertable where Element == AnyFlowComponent {
	public func asFlowArray() -> [AnyFlowComponent] {
		self
	}
}

extension Optional: FlowArrayConvertable where Wrapped: FlowArrayConvertable {
	public func asFlowArray() -> [AnyFlowComponent] {
		self?.asFlowArray() ?? []
	}
}
