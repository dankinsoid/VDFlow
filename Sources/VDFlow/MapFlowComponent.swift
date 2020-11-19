//
//  FlowMapComponent.swift
//  VDKitFix
//
//  Created by Данил Войдилов on 19.11.2020.
//

import Foundation

public struct MapFlowComponent<Base: FlowComponent, To>: WrapperComponentProtocol {
	public let base: Base
	let map: (To) -> Base.Value
	
	public func create() -> Base.Content {
		base.create()
	}
	
	public func update(content: Base.Content, data: To?) {
		base.update(content: content, data: data.map(map))
	}
	
}
