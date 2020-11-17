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

public protocol WrapperComponentProtocol: WrapperAnyComponentProtocol, FlowComponent {
	associatedtype Base: FlowComponent
	var base: Base { get }
}

extension WrapperComponentProtocol {
	public typealias Content = Base.Content
	public typealias Value = Base.Value
}

extension WrapperComponentProtocol {
	public static var baseType: AnyFlowComponent.Type { Base.self }
	
	public var baseAny: AnyFlowComponent { base }
	
	public var id: String {
		base.id
	}
	
	public func createAny() -> Any {
		base.createAny()
	}
	
	public func updateAny(content: Any, data: Any?) {
		base.updateAny(content: content, data: data)
	}
	
}

extension WrapperComponentProtocol where Content == Base.Content {
	
	public func create() -> Content {
		base.create()
	}
	
}

extension WrapperComponentProtocol where Content == Base.Content, Value == Base.Value {
	
	public func update(content: Content, data: Value?) {
		base.update(content: content, data: data)
	}
	
}
