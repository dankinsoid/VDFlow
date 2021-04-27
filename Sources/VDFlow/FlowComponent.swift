//
//  FlowComponen.swift
//  FlowStart
//
//  Created by Daniil on 05.11.2020.
//

import Foundation
import UIKit

public protocol FlowAnyComponent: AnyPrimitiveFlow {
	func createAny() -> Any
	func updateAny(content: Any, data: Any?)
}

extension PrimitiveFlow where Self: FlowComponent {
	public func canNavigate(to step: FlowStep, content: Content) -> Bool { true }
	public func contains(step: FlowStep) -> Bool { step.isNode(flowId) }
	public func navigate(to step: FlowStep, content: Content, completion: @escaping (Bool) -> Void) {
		update(content: content, data: step.data as? Value)
		completion(true)
	}
	public func currentNode(content: Content) -> FlowNode? { nil }
	public func flow(for node: FlowNode, content: Content) -> (AnyPrimitiveFlow, Any)? { nil }
}

public protocol FlowComponent: PrimitiveFlow, FlowAnyComponent {
	associatedtype Value = Void
	associatedtype ID: Hashable = String
	var flowId: ID { get }
	func create() -> Content
	func update(content: Content, data: Value?)
}

extension FlowComponent where ID == String {
	public var flowId: ID { String(reflecting: Content.self) }
}

extension FlowComponent where Value == Void {
	public func update(content: Content, data: Void?) {}
}

extension FlowAnyComponent where Self: FlowComponent {
	public func createAny() -> Any {
		create()
	}
	public func updateAny(content: Any, data: Any?) {
		guard let cont = content as? Content, let value = data as? Value? else { return }
		update(content: cont, data: value)
	}
}

public protocol ViewControllersListComponent {
	var count: Int { get }
	func index(for step: FlowStep) -> Int?
	func controllers(current: [UIViewController], upTo: Int?) -> [UIViewController]
	func asViewControllers(contentAny: Any) -> [UIViewController]
	func createContent(from vcs: [UIViewController]) -> Any?
}

public struct VCListComponent<Component: FlowComponent> where Component.Content: UIViewControllerArrayConvertable {
	public let component: Component
	private var asVcList: ViewControllersListComponent? { component as? ViewControllersListComponent }
	
	public init(_ component: Component) {
		self.component = component
	}
	
	public func create() -> [UIViewController] {
		asViewControllers(content: component.create())
	}
	
	public var count: Int { asVcList?.count ?? 1 }
	
	public func index(for step: FlowStep) -> Int? {
		asVcList?.index(for: step) ?? (component.contains(step: step) ? 0 : nil)
	}
	
	public func controllers(current: [UIViewController], upTo: Int?) -> [UIViewController] {
		if let result = asVcList?.controllers(current: current, upTo: upTo) {
			return result
		}
		if (upTo ?? 0) < 0 {
			return []
		}
		var result = current.filter({ $0.isFlowId(component.flowId) })
		if result.isEmpty {
			result = create()
		}
		return result
	}
	
	public func create(from vcs: [UIViewController]) -> Component.Content? {
		return (asVcList?.createContent(from: vcs) as? Component.Content) ??
			Component.Content.create(from: vcs.filter({ $0.isFlowId(component.flowId) }))
	}
	
	public func asViewControllers(content: Component.Content) -> [UIViewController] {
		if let vcs = asVcList?.asViewControllers(contentAny: content) {
			return vcs
		}
		let vcs = content.asViewControllers()
		vcs.forEach { $0.setFlowId(component.flowId) }
		return vcs
	}
	
	public func node(for vc: UIViewController) -> FlowNode? {
		vc.flowId(of: Component.ID.self)
	}
}

extension FlowComponent where Content: UIViewControllerArrayConvertable {
	var asVcList: VCListComponent<Self> { VCListComponent(self) }
}
