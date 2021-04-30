//
//  CustomFlow.swift
//  FlowStart
//
//  Created by Данил Войдилов on 17.11.2020.
//

import Foundation
import UIKit

public struct CustomFlow<Root: FlowComponent, Element, I: Hashable>: FlowComponent {
	public let root: Root
	public var flowId: I
	
	private let action: (Root.Content, Element?, @escaping (Bool) -> Void) -> Void
	
	public init(root: Root, id: NodeID<Element, I>, _ action : @escaping (Root.Content, Element?, @escaping (Bool) -> Void) -> Void) {
		self.root = root
		self.flowId = id.id
		self.action = action
	}
	
	public func create() -> Root.Content {
		root.create()
	}
	
	public func navigate(to step: FlowStep, content: Root.Content, completion: @escaping (Bool) -> Void) {
		if root.contains(step: step) {
			root.navigate(to: step, content: content, completion: completion)
		} else if step.isNode(flowId) {
			action(content, step.data as? Element, completion)
		} else {
			completion(false)
		}
	}
	
	public func canNavigate(to step: FlowStep, content: Root.Content) -> Bool {
		if root.contains(step: step) {
			return root.canNavigate(to: step, content: content)
		} else {
			return true
		}
	}
	
	public func contains(step: FlowStep) -> Bool {
		step.isNode(flowId) || root.contains(step: step)
	}
	
	public func update(content: Root.Content, data: Root.Value?) {
		root.update(content: content, data: data)
	}
	
	public func children(content: Root.Content) -> [(AnyFlowComponent, Any, Bool)] {
		[(root, content, true)]
	}
}

extension CustomFlow: ViewControllersListComponent where Root: ViewControllersListComponent {
	public var count: Int { root.count }
	
	public func index(for step: FlowStep) -> Int? {
		root.index(for: step)
	}
	
	public func controllers(current: [UIViewController], upTo: Int?) -> [UIViewController] {
		root.controllers(current: current, upTo: upTo)
	}
	
	public func asViewControllers(contentAny: Any) -> [UIViewController] {
		root.asViewControllers(contentAny: contentAny)
	}
	
	public func createContent(from vcs: [UIViewController]) -> Any? {
		root.createContent(from: vcs)
	}
}
