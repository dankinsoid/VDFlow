//
//  Flow.swift
//  FlowStart
//
//  Created by Daniil on 27.10.2020.
//

import Foundation

public protocol Flow: FlowComponent {
	associatedtype Body: FlowComponent
	override associatedtype Content = Body.Content
	override associatedtype Value = Body.Value
	var body: Body { get }
}

extension FlowComponent where Self: Flow, Content == Body.Content {
	public func contains(step: FlowStep) -> Bool {
		body.contains(step: step)
	}
	
	public func canNavigate(to step: FlowStep, content: Content) -> Bool {
		body.canNavigate(to: step, content: content)
	}
	
	public func navigate(to step: FlowStep, content: Content, completion: @escaping (Bool) -> Void) {
		body.navigate(to: step, content: content, completion: completion)
	}
	
	public func children(content: Content) -> [(AnyFlowComponent, Any, Bool)] {
		body.children(content: content)
	}
}

extension FlowComponent where Self: Flow, Content == Body.Content, Value == Body.Value {
	public func create() -> Content {
		body.create()
	}
	
	public func update(content: Content, data: Value?) {
		body.update(content: content, data: data)
	}
}
