//
//  AnyFlow.swift
//  TestProject
//
//  Created by Daniil on 19.11.2020.
//  Copyright © 2020 Daniil. All rights reserved.
//

import Foundation

public struct AnyFlow<Content>: PrimitiveFlow {
	private let _canNavigate: (FlowStep, Content) -> Bool
	private let _navigate: (FlowStep, Content, @escaping (Bool) -> Void) -> Void
	private let _contains: (FlowStep) -> Bool
	private let _currentNode: (Content) -> FlowNode?
	private let _flow: (FlowNode, Content) -> (AnyPrimitiveFlow, Any)?
	
	public init<R: PrimitiveFlow>(_ base: R) where R.Content == Content {
		_canNavigate = base.canNavigate
		_navigate = base.navigate
		_contains = base.contains
		_currentNode = base.currentNode
		_flow = base.flow
	}
	
	public func navigate(to step: FlowStep, content: Content, completion: @escaping (Bool) -> Void) {
		_navigate(step, content, completion)
	}
	
	public func canNavigate(to step: FlowStep, content: Content) -> Bool {
		_canNavigate(step, content)
	}
	
	public func contains(step: FlowStep) -> Bool {
		_contains(step)
	}
	
	public func currentNode(content: Content) -> FlowNode? {
		_currentNode(content)
	}
	
	public func flow(for node: FlowNode, content: Content) -> (AnyPrimitiveFlow, Any)? {
		_flow(node, content)
	}
}

extension PrimitiveFlow {
	public func asAnyFlow() -> AnyFlow<Content> {
		AnyFlow(self)
	}
}
