//
//  AnyFlow.swift
//  TestProject
//
//  Created by Daniil on 19.11.2020.
//  Copyright © 2020 Daniil. All rights reserved.
//

import Foundation

public struct AnyFlow: FlowComponent {
	public let base: AnyFlowComponent
	public var flowId: AnyHashable { base.flowIdAny }
	
	public init<R: FlowComponent>(_ base: R) {
		self.base = base
	}
	
	public init(base: AnyFlowComponent) {
		self.base = base
	}
	
	public func navigate(to step: FlowStep, content: Any, completion: @escaping (Bool) -> Void) {
		base.navigate(to: step, contentAny: content, completion: completion)
	}
	
	public func canNavigate(to step: FlowStep, content: Any) -> Bool {
		base.canNavigate(to: step, contentAny: content)
	}
	
	public func contains(step: FlowStep) -> Bool {
		base.contains(step: step)
	}
	
	public func children(content: Any) -> [(AnyFlowComponent, Any, Bool)] {
		base.children(contentAny: content)
	}
	
	public func create() -> Any {
		base.createAny()
	}
	
	public func update(content: Any, data: Any?) {
		base.updateAny(content: content, data: data)
	}
}

extension FlowComponent {
	public func asAny() -> AnyFlow {
		AnyFlow(self)
	}
}
