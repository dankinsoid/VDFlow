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
		vc.setFlowId(flowId)
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
	
	public func children(content: UINavigationController) -> [(AnyFlowComponent, Any, Bool)] {
		guard !content.viewControllers.isEmpty else {
			return []
		}
	
		let commonContent = component.asVcList.create(from: content.viewControllers.dropLast())
		let currentContent = component.asVcList.create(from: content.topViewController.map { [$0] } ?? [])
		
		var common = commonContent.map(component.children)
		var current = currentContent.map(component.children)
		common?.indices.forEach {
			common?[$0].2 = false
		}
		current?.indices.forEach {
			current?[$0].2 = true
		}
		return common.map { c in current.map { c + $0 } ?? c } ?? []
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
