//
//  WrapperComponent.swift
//  FlowStart
//
//  Created by Daniil on 02.11.2020.
//

import Foundation

public protocol WrapperAnyComponentProtocol: AnyFlowComponent {
	var baseAny: AnyFlowComponent { get }
}

extension AnyFlowComponent where Self: WrapperAnyComponentProtocol {
	public func didNavigated() {
		baseAny.didNavigated()
	}
}

public protocol WrapperComponentProtocol: WrapperAnyComponentProtocol, FlowComponent {
	associatedtype Base: FlowComponent
	override associatedtype Content = Base.Content
	override associatedtype Value = Base.Value
	var base: Base { get }
}

extension WrapperAnyComponentProtocol where Self: WrapperComponentProtocol {
	public var baseAny: AnyFlowComponent { base }
}

extension AnyFlowComponent where Self: WrapperAnyComponentProtocol {
	public var id: String {
		baseAny.id
	}
}

extension FlowComponent where Self: WrapperComponentProtocol, Content == Base.Content {
	
	public func create() -> Content {
		base.create()
	}
	
}

extension FlowComponent where Self: WrapperComponentProtocol, Content == Base.Content, Value == Base.Value {
	
	public func update(content: Content, data: Value?) {
		base.update(content: content, data: data)
	}
	
}
