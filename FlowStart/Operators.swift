//
//  Operators.swift
//  FlowStart
//
//  Created by Daniil on 27.10.2020.
//

import UIKit

extension FlowComponent {
	
	public func present(@FlowBuilder _ buldier: () -> FlowArrayConvertable) -> PresentFlow<Self> {
		PresentFlow(root: self, components: buldier().asFlowArray())
	}
	
	public func presentationStyle(_ style: UIModalPresentationStyle) -> PresentationStyleFlow<Self> {
		PresentationStyleFlow(base: self, style: style)
	}
	
	public func identified(by id: FlowID<Value>) -> IdentifiedComponent<Self> {
		IdentifiedComponent(id: id.id, base: self)
	}
	
}

public struct IdentifiedComponent<Base: FlowComponent>: WrapperComponentProtocol {
	public let id: String
	public let base: Base
}

public struct PresentationStyleFlow<Base: FlowComponent>: WrapperComponentProtocol {
	public let base: Base
	public let style: UIModalPresentationStyle
	
	public func create() -> Base.Content {
		let result = base.create()
		(result as? UIViewController)?.modalPresentationStyle = style
		return result
	}
	
}
