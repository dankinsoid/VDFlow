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
					completion((self, content))
			 	}
			}
			return
		}
		if let flow = root.asFlow {
			flow.navigate(to: step, contentAny: content, completion: completion)
		} else if let point = step.point, root.isPoint(point) {
			root.updateAny(content: content, data: point.data)
			completion.complete(root.asFlow.map { ($0, content) } ?? (self, content))
		} else {
			completion.complete(nil)
		}
	}
	
	public func canNavigate(to point: FlowPoint) -> Bool {
		if point.id == flowId.id {
			return true
		}
		return root.canGo(to: point)
	}
	
	public func flow(with point: FlowPoint) -> AnyBaseFlow? {
		if point.id == flowId.id {
			return self
		}
		return root.asFlow?.flow(with: point)
	}
	
}