//
//  Flow.swift
//  FlowStart
//
//  Created by Daniil on 27.10.2020.
//

import Foundation

public protocol AnyBaseFlow: AnyFlowComponent {
	func canNavigate(to step: FlowNode) -> Bool
	func flow(for step: FlowNode) -> AnyBaseFlow?
	func current(contentAny: Any) -> (AnyFlowComponent, Any)?
	func navigate(to step: FlowStep, contentAny: Any, completion: FlowCompletion)
}

public protocol BaseFlow: AnyBaseFlow, FlowComponent {
	func current(content: Content) -> (AnyFlowComponent, Any)?
	func navigate(to step: FlowStep, content: Content, completion: FlowCompletion)
}

extension BaseFlow {
	public func update(content: Content, data: Value?) {}
}

extension AnyBaseFlow where Self: BaseFlow {
	
	public func current(contentAny: Any) -> (AnyFlowComponent, Any)? {
		guard let content = contentAny as? Content else {
			return nil
		}
		return current(content: content)
	}
	
	public func navigate(to step: FlowStep, contentAny: Any, completion: FlowCompletion) {
		guard let content = contentAny as? Content else {
			completion.complete(nil)
			return
		}
		navigate(to: step, content: content, completion: completion)
	}
	
}

public protocol Flow: FlowComponent {
	associatedtype Root: BaseFlow
	override associatedtype Content = Root.Content
	override associatedtype Value = Root.Value
	var root: Root { get }
}

extension Flow where Content == Root.Content {
	public func create() -> Root.Content {
		root.create()
	}
}

extension Flow where Content == Root.Content, Value == Root.Value {
	public func update(content: Root.Content, data: Root.Value?) {
		root.update(content: content, data: data)
	}
}

extension Flow {
		
	public func asFlowArray() -> [AnyFlowComponent] {
		[root]
	}
	
}
