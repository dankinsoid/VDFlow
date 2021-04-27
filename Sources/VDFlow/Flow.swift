//
//  Flow.swift
//  FlowStart
//
//  Created by Daniil on 27.10.2020.
//

import Foundation

public protocol AnyPrimitiveFlow {
	func contains(step: FlowStep) -> Bool
	func canNavigate(to step: FlowStep, contentAny: Any) -> Bool
	func navigate(to step: FlowStep, contentAny: Any, completion: @escaping (Bool) -> Void)
	func currentNode(contentAny: Any) -> FlowNode?
	func flow(for node: FlowNode, contentAny: Any) -> (AnyPrimitiveFlow, Any)?
}

public protocol PrimitiveFlow: AnyPrimitiveFlow {
	associatedtype Content
	func canNavigate(to step: FlowStep, content: Content) -> Bool
	func navigate(to step: FlowStep, content: Content, completion: @escaping (Bool) -> Void)
	func currentNode(content: Content) -> FlowNode?
	func flow(for node: FlowNode, content: Content) -> (AnyPrimitiveFlow, Any)?
}

extension AnyPrimitiveFlow where Self: PrimitiveFlow {
	public func canNavigate(to step: FlowStep, contentAny: Any) -> Bool {
		guard let content = contentAny as? Content else { return false }
		return canNavigate(to: step, content: content)
	}
	public func navigate(to step: FlowStep, contentAny: Any, completion: @escaping (Bool) -> Void) {
		guard let content = contentAny as? Content else { return completion(false) }
		navigate(to: step, content: content, completion: completion)
	}
	public func currentNode(contentAny: Any) -> FlowNode? {
		guard let content = contentAny as? Content else { return nil }
		return currentNode(content: content)
	}
	public func flow(for node: FlowNode, contentAny: Any) -> (AnyPrimitiveFlow, Any)? {
		guard let content = contentAny as? Content else { return nil }
		return flow(for: node, content: content)
	}
}

extension AnyPrimitiveFlow {
	public func current(contentAny: Any) -> (AnyPrimitiveFlow, Any)? {
		currentNode(contentAny: contentAny).flatMap {
			flow(for: $0, contentAny: contentAny)
		}
	}
}

extension PrimitiveFlow {
	public func current(content: Content) -> (AnyPrimitiveFlow, Any)? {
		currentNode(content: content).flatMap {
			flow(for: $0, content: content)
		}
	}
}

public protocol Flow: FlowComponent {
	associatedtype Root: FlowComponent
	override associatedtype Content = Root.Content
	override associatedtype Value = Root.Value
	var root: Root { get }
}

extension PrimitiveFlow where Self: Flow, Content == Root.Content {
	public func contains(step: FlowStep) -> Bool {
		root.contains(step: step)
	}
	
	public func canNavigate(to step: FlowStep, content: Content) -> Bool {
		root.canNavigate(to: step, content: content)
	}
	
	public func navigate(to step: FlowStep, content: Content, completion: @escaping (Bool) -> Void) {
		root.navigate(to: step, content: content, completion: completion)
	}
}

extension FlowComponent where Self: Flow, Content == Root.Content, Value == Root.Value {
	public func create() -> Content {
		root.create()
	}
	
	public func update(content: Content, data: Value?) {
		root.update(content: content, data: data)
	}
}
