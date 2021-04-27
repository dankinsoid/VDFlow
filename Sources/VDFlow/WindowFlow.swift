//
//  WindowFlow.swift
//  FlowStart
//
//  Created by Daniil on 05.11.2020.
//

import Foundation
import UIKit

public struct WindowFlow<Component: FlowComponent>: FlowComponent where Component.Content: UIViewControllerConvertable {
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
			content.rootViewController = FakeVC()
			content.rootViewController?.loadViewIfNeeded()
			content.rootViewController?.view?.backgroundColor = .clear
		}
	}
	
	public func create() -> UIWindow {
		content.makeKeyAndVisible()
		return content
	}
	
	public func navigate(to step: FlowStep, content: UIWindow, completion: @escaping (Bool) -> Void) {
		guard let vc = content.rootViewController, let cont = component.asVcList.create(from: [vc]) else {
			completion(false)
			return
		}
		let animated = step.animated
		if component.canNavigate(to: step, content: cont) {
			multiCompletion(
				[
					{ component.navigate(to: step, content: cont, completion: $0) },
					{ c in set(content: content, rootViewController: cont.asViewController(), animated: animated, completion: { c(true) }) }
				],
				completion: completion
			)
		} else {
			set(content: content, rootViewController: cont.asViewController(), animated: animated) {
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
	
	public func currentNode(content: UIWindow) -> FlowNode? {
		content.rootViewController.flatMap {
			component.asVcList.node(for: $0)
		}
	}
	
	public func flow(for node: FlowNode, content: UIWindow) -> (AnyPrimitiveFlow, Any)? {
		component.asVcList.create(from: content.rootViewController.map { [$0] } ?? []).flatMap {
			component.flow(for: node, content: $0)
		}
	}
}

extension WindowFlow {
	
	public init(_ window: UIWindow, transition: UIView.AnimationOptions = .transitionCrossDissolve, @FlowBuilder _ builder: () -> Component) {
		self = WindowFlow(window, transition: transition, component: builder())
	}
}

fileprivate final class FakeVC: UIViewController {}
