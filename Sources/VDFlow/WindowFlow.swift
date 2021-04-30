//
//  WindowFlow.swift
//  FlowStart
//
//  Created by Daniil on 05.11.2020.
//

import Foundation
import UIKit

public struct WindowFlow<Component: FlowComponent>: FlowComponent where Component.Content: UIViewControllerArrayConvertable {
	public typealias Content = UIWindow
	public let component: Component
	public var transition: UIView.AnimationOptions
	private let content: UIWindow
	
	public init(_ window: UIWindow, transition: UIView.AnimationOptions = .transitionCrossDissolve, component: Component) {
		self.content = window
		self.transition = transition
		self.component = component
		afterInit()
	}
	
	private func afterInit() {
		if content.rootViewController == nil {
			content.rootViewController = component.create().asViewControllers().first ?? FakeVC()
			content.rootViewController?.loadViewIfNeeded()
		}
	}
	
	public func create() -> UIWindow {
		content.makeKeyAndVisible()
		content.setFlowId(flowId)
		return content
	}
	
	public func navigate(to step: FlowStep, content: UIWindow, completion: @escaping (Bool) -> Void) {
		guard let i = component.asVcList.index(for: step),
					let vc = component.asVcList.controllers(current: content.rootViewController.map { [$0] } ?? [], upTo: i).last,
					let cont = component.asVcList.create(from: [vc]) else {
			completion(false)
			return
		}
		let animated = step.animated
		if component.canNavigate(to: step, content: cont) {
			multiCompletion(
				[
					{ component.navigate(to: step, content: cont, completion: $0) },
					{ c in set(content: content, rootViewController: vc, animated: animated, completion: { c(true) }) }
				],
				completion: completion
			)
		} else {
			set(content: content, rootViewController: vc, animated: animated) {
				component.navigate(to: step, content: cont, completion: completion)
			}
		}
	}
	
	private func set(content: UIWindow, rootViewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
		guard rootViewController !== content.rootViewController else {
			completion?()
			return
		}
		if animated && content.rootViewController != nil && content.rootViewController as? FakeVC == nil {
			UIView.transition(with: content, duration: 0.5, options: transition, animations: {
				let oldState: Bool = UIView.areAnimationsEnabled
				UIView.setAnimationsEnabled(false)
				content.rootViewController = rootViewController
				UIView.setAnimationsEnabled(oldState)
			}, completion: { _ in
				completion?()
			})
		} else {
			content.rootViewController = rootViewController
			completion?()
		}
	}
	
	public func contains(step: FlowStep) -> Bool {
		component.contains(step: step)
	}
	
	public func canNavigate(to step: FlowStep, content: UIWindow) -> Bool {
		guard let vc = content.rootViewController, let cont = component.asVcList.create(from: [vc]) else { return false }
		return component.canNavigate(to: step, content: cont)
	}
	
	public func update(content: UIWindow, data: Component.Value?) {
		guard let vc = content.rootViewController, let cont = component.asVcList.create(from: [vc]) else { return }
		component.update(content: cont, data: data)
	}
	
	public func children(content: UIWindow) -> [(AnyFlowComponent, Any, Bool)] {
		guard let root = content.rootViewController, let commonContent = component.asVcList.create(from: [root]) else {
			return []
		}
		var common = component.children(content: commonContent)
		common.indices.forEach {
			common[$0].2 = true
		}
		return common
	}
}

extension WindowFlow {
	
	public init(_ window: UIWindow, transition: UIView.AnimationOptions = .transitionCrossDissolve, @FlowBuilder _ builder: () -> Component) {
		self = WindowFlow(window, transition: transition, component: builder())
	}
}

fileprivate final class FakeVC: UIViewController {}
