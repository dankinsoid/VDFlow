//
//  Flow.swift
//  FlowStart
//
//  Created by Daniil on 27.10.2020.
//

import Foundation

public protocol AnyBaseFlow: AnyFlowComponent {
	func canNavigate(to point: FlowPoint) -> Bool
	func flow(with point: FlowPoint) -> AnyBaseFlow?
	func current(contentAny: Any) -> (AnyFlowComponent, Any)?
	func navigate(to step: FlowStep, contentAny: Any, completion: FlowCompletion)
}

public protocol BaseFlow: AnyBaseFlow, FlowComponent where Value == FlowStep {
	func current(content: Content) -> (AnyFlowComponent, Any)?
	func navigate(to step: FlowStep, content: Content, completion: FlowCompletion)
}

extension BaseFlow {
	
	public func update(content: Content, data: Value?) {
		guard let data = data else { return }
		navigate(to: data, content: content, completion: .init {_ in })
	}
	
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

public protocol Flow: FlowArrayConvertable {
	associatedtype Root: BaseFlow
	var root: Root { get }
}

extension Flow {
	
	public func asFlowArray() -> [AnyFlowComponent] {
		[root]
	}
	
}
