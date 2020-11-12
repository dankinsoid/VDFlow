//
//  WindowFlow.swift
//  FlowStart
//
//  Created by Daniil on 05.11.2020.
//

import Foundation
import UIKit

public struct WindowFlow: BaseFlow {
	
	public typealias Content = UIWindow
	public typealias Value = FlowStep
	private let content: UIWindow
	private let root: AnyFlowComponent
	
	public init(_ window: UIWindow, root: AnyFlowComponent) {
		self.content = window
		self.root = root
	}
	
	public init(_ window: UIWindow, root: () -> AnyFlowComponent) {
		self.content = window
		self.root = root()
	}
	
	public func create() -> UIWindow {
		content.makeKeyAndVisible()
		return content
	}
	
	public func navigate(to step: FlowStep, content: UIWindow, completion: @escaping ((AnyFlowComponent, Any)?) -> Void) {
		let vc = controller(content: content)
		guard step.point != nil else {
			if let flow = root.asFlow {
				flow.navigate(to: step, contentAny: vc, completion: completion)
			} else {
				completion((self, content))
			}
			return
		}
		root.updateAny(content: vc, step: step, prepare: { c in
			self.set(content: content, rootViewController: vc, animated: step.animated, completion: c)
		}, completion: completion)
	}
	
	private func controller(content: UIWindow) -> UIViewController {
		if let vc = content.rootViewController, let id = vc.view?.accessibilityIdentifier,
			 id == root.id {
			return vc
		}
		let vc = (root.createAny() as? UIViewController) ?? UIViewController()
		vc.loadViewIfNeeded()
		vc.view.accessibilityIdentifier = root.id
		return vc
	}
	
	public func current(content: UIWindow) -> (AnyFlowComponent, Any)? {
		guard let vc = content.rootViewController else { return nil }
		return (root, vc)
	}
	
	public func ifNavigate(to point: FlowPoint) -> AnyFlowComponent? {
		root.asFlow?.ifNavigate(to: point)
	}
	
	private func set(content: UIWindow, rootViewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
		guard rootViewController !== content.rootViewController else {
			completion?()
			return
		}
		if animated && content.rootViewController != nil {
			UIView.transition(with: content, duration: 0.5, options: .transitionCrossDissolve, animations: {
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
	
}
