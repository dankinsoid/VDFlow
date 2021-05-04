//
//  File.swift
//  
//
//  Created by Данил Войдилов on 24.04.2021.
//

import UIKit

public struct IdentifiedFlow<Component: FlowComponent, ID: Hashable>: FlowComponent {
	public var flowId: ID
	public var component: Component
	
	public func create() -> Component.Content {
	  component.create()
	}
	
	public func update(content: Component.Content, data: Component.Value?) {
		component.update(content: content, data: data)
	}
}

extension FlowComponent {
	public func flowId<ID: Hashable>(_ id: ID) -> IdentifiedFlow<Self, ID> {
		IdentifiedFlow(flowId: id, component: self)
	}
}
