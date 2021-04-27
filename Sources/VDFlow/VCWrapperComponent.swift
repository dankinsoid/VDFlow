//
//  File.swift
//  
//
//  Created by Данил Войдилов on 27.04.2021.
//

import Foundation
import UIKit

public struct VCWrapperComponent<Base: FlowComponent>: FlowComponent where Base.Content: UIViewControllerConvertable {
	public typealias Content = Base.Content
	
	public let base: Base
	public var flowId: Base.ID { base.flowId }
	public let wrap: (UIViewController) -> Void
	
	public init(base: Base, wrap: @escaping (UIViewController) -> Void) {
		self.base = base
		self.wrap = wrap
	}
	
	public func create() -> Base.Content {
		let result = base.create()
		wrap(result.asViewController())
		return result
	}
	
	public func update(content: Base.Content, data: Base.Value?) {
		base.update(content: content, data: data)
	}
	
	public func contains(step: FlowStep) -> Bool {
		base.contains(step: step)
	}
	
	public func canNavigate(to step: FlowStep, content: Base.Content) -> Bool {
		base.canNavigate(to: step, content: content)
	}
	
	public func navigate(to step: FlowStep, content: Base.Content, completion: @escaping (Bool) -> Void) {
		base.navigate(to: step, content: content, completion: completion)
	}
	
	public func currentNode(content: Base.Content) -> FlowNode? {
		base.currentNode(content: content)
	}
	
	public func flow(for node: FlowNode, content: Base.Content) -> (AnyPrimitiveFlow, Any)? {
		base.flow(for: node, content: content)
	}
}

extension VCWrapperComponent: ViewControllersListComponent {
	public var count: Int {
		base.asVcList.count
	}
	
	public func index(for step: FlowStep) -> Int? {
		base.asVcList.index(for: step)
	}
	
	public func controllers(current: [UIViewController], upTo: Int?) -> [UIViewController] {
		let result = base.asVcList.controllers(current: current, upTo: upTo)
		result.forEach(wrap)
		return result
	}
	
	public func asViewControllers(contentAny: Any) -> [UIViewController] {
		guard let content = contentAny as? Base.Content else { return [] }
		return base.asVcList.asViewControllers(content: content)
	}
	
	public func createContent(from vcs: [UIViewController]) -> Any? {
		base.asVcList.create(from: vcs)
	}
}
