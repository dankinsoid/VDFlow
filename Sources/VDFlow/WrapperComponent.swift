//
//  WrapperComponent.swift
//  FlowStart
//
//  Created by Daniil on 02.11.2020.
//

import Foundation

public protocol WrapperAnyComponentProtocol: AnyFlowComponent {
	static var baseType: AnyFlowComponent.Type { get }
	var baseAny: AnyFlowComponent { get }
}

extension WrapperAnyComponentProtocol {
	public func didNavigated() {
		baseAny.didNavigated()
	}
}

public protocol WrapperComponentProtocol: WrapperAnyComponentProtocol, FlowComponent {
	associatedtype Base: FlowComponent
	var base: Base { get }
}

extension WrapperComponentProtocol {
	public typealias Content = Base.Content
	public typealias Value = Base.Value
}

extension WrapperAnyComponentProtocol where Self: WrapperComponentProtocol {
	public static var baseType: AnyFlowComponent.Type { Base.self }
	public var baseAny: AnyFlowComponent { base }
}

extension AnyFlowComponent where Self: WrapperAnyComponentProtocol {
	public var id: String {
		baseAny.id
	}
}

extension FlowComponent where Self: WrapperComponentProtocol {
	
	public func create() -> Content {
		base.create()
	}
	
}

extension FlowComponent where Self: WrapperComponentProtocol {
	
	public func update(content: Content, data: Value?) {
		base.update(content: content, data: data)
	}
	
}
