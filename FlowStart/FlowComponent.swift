//
//  FlowComponen.swift
//  FlowStart
//
//  Created by Daniil on 05.11.2020.
//

import Foundation

public protocol AnyFlowComponent: FlowArrayConvertable {
	var contentType: Any.Type { get }
	var id: String { get }
	func createAny() -> Any
	func updateAny(content: Any, data: Any?)
}

extension AnyFlowComponent {
	public func asFlowArray() -> [AnyFlowComponent] {
		[self]
	}
}

extension AnyFlowComponent {
	
	public var id: String {
		String(reflecting: Self.self)
	}
	
	var rootComponent: AnyFlowComponent {
		(self as? WrapperAnyComponentProtocol)?.baseAny.rootComponent ?? self
	}
	
	var asFlow: AnyBaseFlow? {
		rootComponent as? AnyBaseFlow
	}
	
	func updateAny(content: Any, step: FlowStep, completion: FlowCompletion) {
		if let point = step.point, isPoint(point) {
			updateAny(content: content, data: point.data)
			completion.complete((self, content))
		} else if let flow = asFlow {
			flow.navigate(to: step, contentAny: content, completion: completion)
		} else {
			completion.complete(nil)
		}
	}
	
}

public protocol FlowComponent: AnyFlowComponent {
	associatedtype Content
	associatedtype Value
	func create() -> Content
	func update(content: Content, data: Value?)
}

extension AnyFlowComponent where Self: FlowComponent {
	
	public var contentType: Any.Type { Content.self }
	
	public func createAny() -> Any {
		create()
	}
	
	public func updateAny(content: Any, data: Any?) {
		guard let view = content as? Content, let data = data as? Value? else { return }
		update(content: view, data: data)
	}
	
}
