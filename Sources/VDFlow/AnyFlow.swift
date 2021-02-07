//
//  AnyFlow.swift
//  TestProject
//
//  Created by Daniil on 19.11.2020.
//  Copyright © 2020 Daniil. All rights reserved.
//

import Foundation

public struct AnyFlow<Content>: BaseFlow {
	
	private let baseCreate: () -> Content
	private let base: AnyBaseFlow
	public var id: String { base.id }
	public var contentType: Any.Type { base.contentType }
	
	public init<R: BaseFlow>(_ base: R) where R.Content == Content {
		self.base = base
		baseCreate = base.create
	}
	
	public func create() -> Content {
		baseCreate()
	}
	
	public func current(content: Content) -> (AnyFlowComponent, Any)? {
		base.current(contentAny: content)
	}
	
	public func navigate(to step: FlowStep, content: Content, completion: FlowCompletion) {
		base.navigate(to: step, contentAny: content, completion: completion)
	}
	
	public func canNavigate(to node: FlowNode) -> Bool {
		base.canNavigate(to: node)
	}
	
	public func flow(for node: FlowNode) -> AnyBaseFlow? {
		base.flow(for: node)
	}
	
	public func update(content: Content, data: Any?) {
		base.updateAny(content: content, data: data)
	}
	
}

extension BaseFlow {
	public func asAny() -> AnyFlow<Content> {
		AnyFlow(self)
	}
}
