//
//  CustomFlow.swift
//  FlowStart
//
//  Created by Данил Войдилов on 17.11.2020.
//

import Foundation

public struct CustomFlow<Root: FlowComponent, Element>: BaseFlow, WrapperAnyComponentProtocol {
	public let root: Root
	public var baseAny: AnyFlowComponent { root }
	public let nodeId: NodeID<Element>
	private let action: (Root.Content, Element?, @escaping () -> Void) -> Void
	public var contentType: Any.Type { root.contentType }
	
	public init(root: Root, id: NodeID<Element>, _ action: @escaping (Root.Content, Element?, @escaping () -> Void) -> Void) {
		self.root = root
		self.nodeId = id
		self.action = action
	}
	
	public func create() -> Root.Content {
		root.create()
	}
	
	public func current(content: Content) -> (AnyFlowComponent, Any)? {
		root.asFlow?.current(contentAny: content) ?? (root, content)
	}
	
	public func navigate(to step: FlowStep, content: Content, completion: FlowCompletion) {
		if step.node?.id == nodeId.id {
			completion.onReady { completion in
				action(content, step.data as? Element) {
					completion((self, content))
			 	}
			}
			return
		}
		if let flow = root.asFlow {
			flow.navigate(to: step, contentAny: content, completion: completion)
		} else if let node = step.node, root.isNode(node) {
			root.updateAny(content: content, data: step.data)
			completion.complete(root.asFlow.map { ($0, content) } ?? (self, content))
		} else {
			completion.complete(nil)
		}
	}
	
	public func canNavigate(to node: FlowNode) -> Bool {
		isNode(node) || root.canGo(to: node)
	}
	
	public func flow(for node: FlowNode) -> AnyBaseFlow? {
		if isNode(node) {
			return self
		}
		return root.asFlow?.flow(for: node)
	}
	
}
