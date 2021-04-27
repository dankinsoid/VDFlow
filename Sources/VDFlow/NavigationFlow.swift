//
//  NavigationFlow.swift
//  FlowStart
//
//  Created by Daniil on 02.11.2020.
//

import Foundation
import UIKit

public struct NavigationFlow<Component: FlowComponent>: FlowComponent where Component.Content: UIViewControllerArrayConvertable {
	
	public let createController: () -> UINavigationController
	public let component: Component
	
	public init(create: @escaping () -> UINavigationController, component: Component) {
		createController = create
		self.component = component
	}
	
	public func create() -> UINavigationController {
		let vc = createController()
		if let first = component.asVcList.create().first {
			vc.setViewControllers([first], animated: false)
		}
		return vc
	}
	
	public func navigate(to step: FlowStep, content: UINavigationController, completion: @escaping (Bool) -> Void) {
		guard let i = component.asVcList.index(for: step) else {
			completion(false)
			return
		}
		let vcs = component.asVcList.controllers(current: content.viewControllers, upTo: i)
		guard let new = component.asVcList.create(from: vcs) else {
			completion(false)
			return
		}
		let animated = step.animated && content.view?.window != nil
//		content.dismissPresented(animated: animated) {[self] in
		if component.canNavigate(to: step, content: new) {
			multiCompletion(
				[
					{ component.navigate(to: step, content: new, completion: $0) },
					{ c in content.set(viewControllers: vcs, animated: animated, completion: { c(true) }) }
				],
				completion: completion
			)
		} else {
			content.set(viewControllers: vcs, animated: animated) {
				component.navigate(to: step, content: new, completion: completion)
			}
		}
//		}
	}
	
	public func contains(step: FlowStep) -> Bool {
		component.contains(step: step)
	}
	
	public func canNavigate(to step: FlowStep, content: UINavigationController) -> Bool {
		content.presentedViewController == nil &&
		component.asVcList.create(from: content.viewControllers).map {
			component.canNavigate(to: step, content: $0)
		} == true
	}
	
	public func current(content: UINavigationController) -> (AnyPrimitiveFlow, Any)? {
		content.topViewController.flatMap {
			component.asVcList.create(from: [$0])
		}.flatMap {
			(component, $0)
		}
	}
	
	public func currentNode(content: UINavigationController) -> FlowNode? {
		content.topViewController.flatMap {
			component.asVcList.node(for: $0)
		}
	}
	
	public func flow(for node: FlowNode, content: UINavigationController) -> (AnyPrimitiveFlow, Any)? {
		component.asVcList.create(from: content.viewControllers).flatMap {
			component.flow(for: node, content: $0)
		}
	}
}

extension UINavigationController {
	
	public func set(viewControllers: [UIViewController], animated: Bool, completion: @escaping () -> Void = {}) {
		if animated, view?.window != nil {
			CATransaction.begin()
			CATransaction.setCompletionBlock(completion)
			setViewControllers(viewControllers, animated: true)
			CATransaction.commit()
		} else {
			setViewControllers(viewControllers, animated: false)
			completion()
		}
	}
}

extension NavigationFlow {
	
	public init(create: @escaping @autoclosure () -> UINavigationController = UINavigationController(), @FlowBuilder _ builder: () -> Component) {
		self = NavigationFlow(create: create, component: builder())
	}
}

extension UIViewController {
	
	var isDisabledBack: Bool {
		get { (objc_getAssociatedObject(self, &disableBackKey) as? Bool) ?? false }
		set { objc_setAssociatedObject(self, &disableBackKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
	}
}

fileprivate var disableBackKey = "disableBackKey"
