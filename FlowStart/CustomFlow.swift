//
//  CustomFlow.swift
//  FlowStart
//
//  Created by Данил Войдилов on 17.11.2020.
//

import Foundation

public struct CustomFlow<Root: FlowComponent, Element>: BaseFlow {
	
	public let root: Root
	public let flowId: FlowID<Element>
	public var id: String { flowId.id }
	private let action: (Root.Content, Element?, @escaping () -> Void) -> Void
	
	public init(root: Root, id: FlowID<Element>, _ action: @escaping (Root.Content, Element?, @escaping () -> Void) -> Void) {
		self.root = root
		self.flowId = id
		self.action = action
	}
	
	public func create() -> Root.Content {
		root.create()
	}
	
	public func current(content: Content) -> (AnyFlowComponent, Any)? {
		root.asFlow?.current(contentAny: content) ?? (root, content)
	}
	
	public func navigate(to step: FlowStep, content: Content, completion: FlowCompletion) {
		if step.point?.id == flowId.id {
			completion.onReady { completion in
				action(content, step.point?.data as? Element) {
				 completion(nil)
			 }
			}
			return
		}
		root.asFlow?.navigate(to: step, contentAny: content, completion: completion)
	}
	
	public func ifNavigate(to point: FlowPoint) -> AnyFlowComponent? {
		if point.id == flowId.id {
			return self
		}
		return root._ifNavigate(to: point)
	}
	
}
