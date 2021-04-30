//
//  File.swift
//  
//
//  Created by Данил Войдилов on 27.04.2021.
//

import Foundation
import UIKit

public struct OptionalFlow<Component: FlowComponent>: FlowComponent {
	
	public typealias Value = Component.Value
	public typealias ID = Component.ID?
	
	public let component: Component?
	public var flowId: Component.ID? { component?.flowId }
	
	public init(_ component: Component?) {
		self.component = component
	}
	
	public func create() -> Content {
		.init(content: component?.create())
	}
	
	public func update(content: Content, data: Component.Value?) {
		content.content.map { component?.update(content: $0, data: data) }
	}
	
	public func navigate(to step: FlowStep, content: Content, completion: @escaping (Bool) -> Void) {
		guard let cont = content.content, let comp = component else {
			completion(false)
			return
		}
		comp.navigate(to: step, content: cont, completion: completion)
	}
	
	public func canNavigate(to step: FlowStep, content: Content) -> Bool {
		guard let cont = content.content else { return false }
		return component?.canNavigate(to: step, content: cont) == true
	}
	
	public func contains(step: FlowStep) -> Bool {
		component?.contains(step: step) == true
	}
	
	public func children(content: Content) -> [(AnyFlowComponent, Any, Bool)] {
		content.content.flatMap { component?.children(content: $0) } ?? []
	}
	
	public struct Content {
		public let content: Component.Content?
	}
}

extension OptionalFlow: ViewControllersListComponent where Component.Content: UIViewControllerArrayConvertable {
	public var count: Int {
		component?.asVcList.count ?? 0
	}
	
	public func index(for step: FlowStep) -> Int? {
		component?.asVcList.index(for: step)
	}
	
	public func controllers(current: [UIViewController], upTo: Int?) -> [UIViewController] {
		component?.asVcList.controllers(current: current, upTo: upTo) ?? []
	}
	
	public func asViewControllers(contentAny: Any) -> [UIViewController] {
		guard let content = contentAny as? Content else { return [] }
		return content.content.flatMap { component?.asVcList.asViewControllers(content: $0) } ?? []
	}
	
	public func createContent(from vcs: [UIViewController]) -> Any? {
		Content(content: component?.asVcList.create(from: vcs))
	}
}

extension OptionalFlow.Content: UIViewControllerArrayConvertable where Component.Content: UIViewControllerArrayConvertable {
	
	public static func create(from vcs: [UIViewController]) -> OptionalFlow.Content? {
		OptionalFlow.Content(content: Component.Content.create(from: vcs))
	}
	
	public func asViewControllers() -> [UIViewController] {
		content?.asViewControllers() ?? []
	}
}
