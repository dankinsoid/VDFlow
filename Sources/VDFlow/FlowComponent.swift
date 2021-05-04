//
//  File.swift
//  
//
//  Created by Данил Войдилов on 28.04.2021.
//

import Foundation

public protocol AnyFlowComponent {
	var flowIdAny: AnyHashable { get }
	func createAny() -> Any
	func updateAny(content: Any, data: Any?)
}

public protocol FlowComponent: AnyFlowComponent {
	associatedtype Content
	associatedtype ID: Hashable = String
	associatedtype Value = Void
	var flowId: ID { get }
	
	func create() -> Content
	func update(content: Content, data: Value?)
}

extension FlowComponent where Value == Void {
	public func update(content: Content, data: Void?) {}
}

extension FlowComponent where ID == String {
	public var flowId: ID { String(reflecting: Content.self) }
}

extension AnyFlowComponent where Self: FlowComponent {
	public var flowIdAny: AnyHashable { flowId }
	
	public func createAny() -> Any {
		create()
	}
	public func updateAny(content: Any, data: Any?) {
		guard let cont = content as? Content, let value = data as? Value? else { return }
		update(content: cont, data: value)
	}
}
