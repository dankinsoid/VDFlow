//
//  FlowMapComponent.swift
//  VDKitFix
//
//  Created by Данил Войдилов on 19.11.2020.
//

import Foundation

public struct MapFlowComponent<Base: FlowComponent, Value>: FlowComponent, WrapperAnyComponentProtocol {
	public var baseAny: AnyFlowComponent { base }
	public let base: Base
	public var id: String { base.id }
	public var contentType: Any.Type { base.contentType }
	let map: (Value) -> Base.Value
	
	public func create() -> Base.Content {
		base.create()
	}
	
	public func update(content: Base.Content, data: Value?) {
		base.update(content: content, data: data.map(map))
	}
	
}
