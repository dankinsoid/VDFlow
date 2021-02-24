//
//  FlowGroup.swift
//  FlowStart
//
//  Created by Daniil on 05.11.2020.
//

import Foundation

public struct FlowGroup: FlowArrayConvertable {
	
	public var flows: [FlowArrayConvertable]
	
	public init(_ flows: [FlowArrayConvertable]) {
		self.flows = flows
	}
	
	public init(@FlowBuilder _ builder: () -> FlowArrayConvertable) {
		flows = [builder()]
	}
	
	public func asFlowArray() -> [AnyFlowComponent] {
		Array(flows.map { $0.asFlowArray() }.joined())
	}
	
}
