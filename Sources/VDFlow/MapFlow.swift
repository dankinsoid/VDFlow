//
//  File.swift
//  
//
//  Created by Данил Войдилов on 27.04.2021.
//

import Foundation
import UIKit

public struct MapFlow<Component: FlowComponent, Value>: FlowComponent {
	public let component: Component
	public let map: (Value) -> Component.Value
	public var flowId: Component.ID { component.flowId }
	
	public func create() -> Component.Content {
		component.create()
	}
	
	public func contains(step: FlowStep) -> Bool {
		component.contains(step: step)
	}
	
	public func canNavigate(to step: FlowStep, content: Component.Content) -> Bool {
		component.canNavigate(to: step, content: content)
	}
	
	public func navigate(to step: FlowStep, content: Component.Content, completion: @escaping (Bool) -> Void) {
		var step = step
		step.data = (step.data as? Value).map(map) ?? step.data
		component.navigate(to: step, content: content, completion: completion)
	}
	
	public func update(content: Component.Content, data: Value?) {
		component.update(content: content, data: data.map(map))
	}
	
	public func children(content: Component.Content) -> [(AnyFlowComponent, Any, Bool)] {
		component.children(content: content)
	}
}

extension MapFlow: ViewControllersListComponent where Component.Content: UIViewControllerArrayConvertable {
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
