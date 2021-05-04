//
//  Flow.swift
//  FlowStart
//
//  Created by Daniil on 27.10.2020.
//

import Foundation

public protocol Flow: FlowComponent where Content == Body.Content, Value == Body.Value, ID == Body.ID {
	associatedtype Body: FlowComponent
	override associatedtype Content = Body.Content
	override associatedtype Value = Body.Value
	override associatedtype ID = Body.ID
	var body: Body { get }
}

extension FlowComponent where Self: Flow {
	public var flowId: ID { body.flowId }
	
	public func create() -> Content {
		body.create()
	}
	
	public func update(content: Content, data: Value?) {
		body.update(content: content, data: data)
	}
}
