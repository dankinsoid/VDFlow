//
//  AnyFlow.swift
//  TestProject
//
//  Created by Daniil on 19.11.2020.
//  Copyright © 2020 Daniil. All rights reserved.
//

import Foundation

public struct AnyFlow: BaseFlow {
	
	private let base: AnyBaseFlow
	public var id: String { base.id }
	public var contentType: Any.Type { base.contentType }
	
	public init(_ base: AnyBaseFlow) {
		self.base = base
	}
	
	public func create() -> Any {
		base.createAny()
	}
	
	public func current(content: Any) -> (AnyFlowComponent, Any)? {
		base.current(contentAny: content)
	}
	
	public func navigate(to step: FlowStep, content: Any, completion: FlowCompletion) {
		base.navigate(to: step, contentAny: content, completion: completion)
	}
	
	public func canNavigate(to point: FlowPoint) -> Bool {
		base.canNavigate(to: point)
	}
	
	public func flow(with point: FlowPoint) -> AnyBaseFlow? {
		base.flow(with: point)
	}
	
	public func update(content: Any, data: Any?) {
		base.updateAny(content: content, data: data)
	}
	
}

extension AnyBaseFlow {
	public func asAny() -> AnyFlow {
		AnyFlow(self)
	}
}

extension Flow {
	public func asAny() -> AnyFlow {
		AnyFlow(self.root)
	}
}
