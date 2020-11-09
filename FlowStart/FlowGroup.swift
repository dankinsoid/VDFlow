//
//  FlowGroup.swift
//  FlowStart
//
//  Created by Daniil on 05.11.2020.
//

import Foundation

public struct FlowGroup: FlowArrayConvertable {
	
	public var flows: [AnyFlowComponent]
	
	public init(_ flows: [AnyFlowComponent]) {
		self.flows = flows
	}
	
	public init(@FlowBuilder _ buldier: () -> FlowArrayConvertable) {
		flows = buldier().asFlowArray()
	}
	
	public func asFlowArray() -> [AnyFlowComponent] {
		flows
	}
	
}
