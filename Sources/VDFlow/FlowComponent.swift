//
//  File.swift
//  
//
//  Created by Данил Войдилов on 28.04.2021.
//

import Foundation

public protocol AnyFlowComponent {
	var flowIdAny: AnyHashable { get }
	func contains(step: FlowStep) -> Bool
	func canNavigate(to step: FlowStep, contentAny: Any) -> Bool
	func navigate(to step: FlowStep, contentAny: Any, completion: @escaping (Bool) -> Void)
	func children(contentAny: Any) -> [(AnyFlowComponent, Any, Bool)]
	
	func createAny() -> Any
	func updateAny(content: Any, data: Any?)
}

public protocol FlowComponent: AnyFlowComponent {
	associatedtype Content
	associatedtype ID: Hashable = String
	var flowId: ID { get }
	func canNavigate(to step: FlowStep, content: Content) -> Bool
	func navigate(to step: FlowStep, content: Content, completion: @escaping (Bool) -> Void)
	func children(content: Content) -> [(AnyFlowComponent, Any, Bool)]
	
	associatedtype Value = Void
	func create() -> Content
	func update(content: Content, data: Value?)
}


extension FlowComponent {
	public func canNavigate(to step: FlowStep, content: Content) -> Bool { true }
	public func contains(step: FlowStep) -> Bool { step.isNode(flowId) }
	public func navigate(to step: FlowStep, content: Content, completion: @escaping (Bool) -> Void) {
		update(content: content, data: step.data as? Value)
		completion(true)
	}
	public func currentNode(content: Content) -> AnyHashable? { nil }
	public func flow(for node: AnyHashable, content: Content) -> (AnyFlowComponent, Any)? { nil }
	public func children(content: Content) -> [(AnyFlowComponent, Any, Bool)] { [] }
}

extension FlowComponent where Value == Void {
	public func update(content: Content, data: Void?) {}
}

extension FlowComponent where ID == String {
	public var flowId: ID { String(reflecting: Content.self) }
}

extension AnyFlowComponent where Self: FlowComponent {
	public var flowIdAny: AnyHashable { flowId }
	
	public func canNavigate(to step: FlowStep, contentAny: Any) -> Bool {
		guard let content = contentAny as? Content else { return false }
		return canNavigate(to: step, content: content)
	}
	public func navigate(to step: FlowStep, contentAny: Any, completion: @escaping (Bool) -> Void) {
		guard let content = contentAny as? Content else { return completion(false) }
		navigate(to: step, content: content, completion: completion)
	}
	public func children(contentAny: Any) -> [(AnyFlowComponent, Any, Bool)] {
		guard let content = contentAny as? Content else { return [] }
		return children(content: content)
	}
	public func createAny() -> Any {
		create()
	}
	public func updateAny(content: Any, data: Any?) {
		guard let cont = content as? Content, let value = data as? Value? else { return }
		update(content: cont, data: value)
	}
}

extension AnyFlowComponent {
	public func current(contentAny: Any) -> (AnyFlowComponent, Any)? {
		let current = children(contentAny: contentAny).first(where: { $0.2 })
		return current.map { ($0.0, $0.1) }
	}
}

extension FlowComponent {
	public func current(content: Content) -> (AnyFlowComponent, Any)? {
		let current = children(content: content).first(where: { $0.2 })
		return current.map { ($0.0, $0.1) }
	}
}
