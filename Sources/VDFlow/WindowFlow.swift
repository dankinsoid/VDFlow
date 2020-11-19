//
//  WindowFlow.swift
//  FlowStart
//
//  Created by Daniil on 05.11.2020.
//

import Foundation
import UIKit

public struct WindowFlow: ArrayFlowProtocol {
	public typealias Content = UIWindow
	public typealias Value = FlowStep
	public let delegate: ArrayFlow<Delegate>
	private let content: UIWindow
	
	public init(_ window: UIWindow, transition: UIView.AnimationOptions = .transitionCrossDissolve, components: [AnyFlowComponent]) {
		self.content = window
		self.delegate = ArrayFlow(
			delegate: Delegate(transition: transition),
			components: components
		)
	}
	
	public func create() -> UIWindow {
		content.makeKeyAndVisible()
		return content
	}
	
	public struct Delegate: ArrayFlowDelegateProtocol {
		public let setType = ArrayFlowSetType.one
		public var transition: UIView.AnimationOptions = .transitionCrossDissolve
		
		public func children(for parent: UIWindow) -> [UIViewController] {
			parent.rootViewController.map { [$0] } ?? []
		}
		
		public func currentChild(for parent: UIWindow) -> UIViewController? {
			parent.rootViewController
		}
		
		public func set(children: [UIViewController], current: Int, to parent: UIWindow, animated: Bool, completion: OnReadyCompletion<Void>) {
			guard current >= 0 && current < children.count else {
				completion.complete(())
				return
			}
			let vc = children[current]
			set(content: parent, rootViewController: vc, animated: animated) {
				completion.complete(())
			}
		}
		
		private func set(content: UIWindow, rootViewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
		 guard rootViewController !== content.rootViewController else {
			 completion?()
			 return
		 }
		 if animated && content.rootViewController != nil {
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
		
	}
	
}

extension WindowFlow {
	
	public init(_ window: UIWindow, transition: UIView.AnimationOptions = .transitionCrossDissolve, @FlowBuilder _ builder: () -> FlowArrayConvertable) {
		self = WindowFlow(window, transition: transition, components: builder().asFlowArray())
	}
	
}
