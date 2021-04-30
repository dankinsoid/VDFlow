//
//  File.swift
//  
//
//  Created by Данил Войдилов on 24.04.2021.
//

import UIKit

public struct IdentifiedFlow<Component: FlowComponent>: FlowComponent {
	public var flowId: Component.ID
	public var component: Component
	
	public func create() -> Content {
		Content(content: component.create(), id: flowId)
	}
	
	public func contains(step: FlowStep) -> Bool {
		step.isNode(flowId) || component.contains(step: step)
	}
	
	public func canNavigate(to step: FlowStep, content: Content) -> Bool {
		component.canNavigate(to: step, content: content.content)
	}
	
	public func navigate(to step: FlowStep, content: Content, completion: @escaping (Bool) -> Void) {
		component.navigate(to: step, content: content.content, completion: completion)
	}
	
	public func update(content: Content, data: Component.Value?) {
		component.update(content: content.content, data: data)
	}
	
	public func children(content: Content) -> [(AnyFlowComponent, Any, Bool)] {
		component.children(content: content.content)
	}
	
	public struct Content {
		public let content: Component.Content
		public let id: ID
	}
}

extension IdentifiedFlow: ViewControllersListComponent where Component.Content: UIViewControllerArrayConvertable {
	public var count: Int {
		component.asVcList.count
	}
	
	public func index(for step: FlowStep) -> Int? {
		step.isNode(flowId) ? 0 : component.asVcList.index(for: step)
	}
	
	public func controllers(current: [UIViewController], upTo: Int?) -> [UIViewController] {
		if Component.Content.self as? UIViewControllerConvertable.Type == nil {
			return component.asVcList.controllers(current: current, upTo: upTo)
		}
		var vcs = current.filter { $0.isFlowId(flowId) }
		if vcs.isEmpty {
			vcs = create().asViewControllers()
		}
		return vcs
	}
	
	public func asViewControllers(contentAny: Any) -> [UIViewController] {
		guard let content = contentAny as? Content else { return [] }
		let result = component.asVcList.asViewControllers(content: content.content)
		result.forEach { $0.setFlowId(flowId) }
		return result
	}
	
	public func createContent(from vcs: [UIViewController]) -> Any? {
		guard let content = Component.Content.create(from: vcs.filter({ $0.isFlowId(flowId) })) else { return nil }
		return Content(content: content, id: flowId)
	}
}

extension IdentifiedFlow.Content: UIViewControllerArrayConvertable where Component.Content: UIViewControllerArrayConvertable {
	public func asViewControllers() -> [UIViewController] {
		let vcs = content.asViewControllers()
		vcs.forEach { $0.setFlowId(id) }
		return vcs
	}
	
	public static func create(from vcs: [UIViewController]) -> IdentifiedFlow<Component>.Content? {
		guard let id = vcs.compactMap({ $0.flowId(of: Component.ID.self) }).first else { return nil }
		return Component.Content.create(from: vcs).map {
			.init(content: $0, id: id)
		}
	}
}

extension IdentifiedFlow.Content: UIViewControllerConvertable where Component.Content: UIViewControllerConvertable {
	
	public static func create(from vc: UIViewController) -> IdentifiedFlow<Component>.Content? {
		guard let id = vc.flowId(of: Component.ID.self) else { return nil }
		return Component.Content.create(from: vc).map {
			.init(content: $0, id: id)
		}
	}
	
	public func asViewController() -> UIViewController {
		let vc = content.asViewController()
		vc.setFlowId(id)
		return vc
	}
}

private final class Wrapper<T> {
	var value: T
	
	init(_ value: T) {
		self.value = value
	}
}

private var flowIdKey = "flowIdKey"

extension NSObject {
	
	func flowId<ID: Hashable>(of type: ID.Type) -> ID? {
		(objc_getAssociatedObject(self, &flowIdKey) as? Wrapper<ID>)?.value
	}
	
	func isFlowId<ID: Hashable>(_ id: ID) -> Bool {
		(objc_getAssociatedObject(self, &flowIdKey) as? Wrapper<ID>)?.value == id
	}
	
	func setFlowId<ID: Hashable>(_ id: ID) {
		objc_setAssociatedObject(self, &flowIdKey, Wrapper(id), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
	}
}
