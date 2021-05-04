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
}

extension FlowGroup: ViewControllersListComponent where Component.Content: UIViewControllerArrayConvertable {
	public var count: Int {
		component.asVcList.count
	}
	
	public var ids: [AnyHashable] { component.asVcList.allIds }
	
	public func index(for id: AnyHashable) -> Int? {
		component.asVcList.index(for: id)
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
