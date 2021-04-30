//
//  FlowGroup.swift
//  FlowStart
//
//  Created by Daniil on 05.11.2020.
//

import Foundation
import UIKit

public struct FlowGroup<Component: FlowComponent>: FlowComponent {
	public typealias Value = Component.Value
	public typealias ID = Component.ID
	
	public let component: Component
	public var flowId: Component.ID { component.flowId }
	
	public init(_ component: Component) { self.component = component }
	
	public init(@FlowBuilder _ component: () -> Component) {
		self.component = component()
	}
	
	public func create() -> Component.Content {
		component.create()
	}
	
	public func update(content: Component.Content, data: Component.Value?) {
		component.update(content: content, data: data)
	}
	
	public func navigate(to step: FlowStep, content: Component.Content, completion: @escaping (Bool) -> Void) {
		component.navigate(to: step, content: content, completion: completion)
	}
	
	public func canNavigate(to step: FlowStep, content: Component.Content) -> Bool {
		component.canNavigate(to: step, content: content)
	}
	
	public func contains(step: FlowStep) -> Bool {
		component.contains(step: step)
	}
	
	public func children(content: Component.Content) -> [(AnyFlowComponent, Any, Bool)] {
		component.children(content: content)
	}
}

extension FlowGroup: ViewControllersListComponent where Component.Content: UIViewControllerArrayConvertable {
	public var count: Int {
		component.asVcList.count
	}
	
	public func index(for step: FlowStep) -> Int? {
		component.asVcList.index(for: step)
	}
	
	public func controllers(current: [UIViewController], upTo: Int?) -> [UIViewController] {
		component.asVcList.controllers(current: current, upTo: upTo)
	}
	
	public func asViewControllers(contentAny: Any) -> [UIViewController] {
		guard let content = contentAny as? Component.Content else { return [] }
		return component.asVcList.asViewControllers(content: content)
	}
	
	public func createContent(from vcs: [UIViewController]) -> Any? {
		component.asVcList.create(from: vcs)
	}
}
