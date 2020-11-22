//
//  TabFlow.swift
//  FlowStart
//
//  Created by Daniil on 08.11.2020.
//

import Foundation
import UIKit

public struct TabFlow: ArrayFlowProtocol {
	private let createController: () -> UITabBarController
	public let delegate: ArrayFlow<UITabBarController.ArrayDelegate>
	
	public init(create: @escaping () -> UITabBarController, components: [AnyFlowComponent]) {
		createController = create
		self.delegate = ArrayFlow(
			delegate: .init(),
			components: Array(components.map {
				($0.rootComponent as? TabFlow)?.delegate.components ?? [$0]
			}
			.joined())
		)
	}
	
	public func create() -> UITabBarController {
		createController()
	}
	
}

extension UITabBarController {
	
	public func set(viewControllers: [UIViewController], current: Int, animated: Bool, completion: @escaping () -> Void = {}) {
		let action: () -> Void = {
			UIView.performWithoutAnimation {
				self.setViewControllers(viewControllers, animated: false)
			 	self.selectedIndex = current
			}
			completion()
		}
		guard current >= 0, current < viewControllers.count else {
			action()
			return
		}
		let to = viewControllers[current]
		if animated, view?.window != nil, let from = selectedViewController, from !== to,
			 let transition = delegate?.tabBarController?(self, animationControllerForTransitionFrom: from, to: to) {
			let context = TabBarContextTransitioning(completion: action, from: from, to: to)
			transition.animateTransition(using: context)
		} else {
			action()
		}
	}
	
}

extension TabFlow {
	
	public init(create: @escaping @autoclosure () -> UITabBarController = FlowTabBarController(), @FlowBuilder _ builder: () -> FlowArrayConvertable) {
		self = TabFlow(create: create, components: builder().asFlowArray())
	}
	
}

extension UITabBarController {
	
	public struct ArrayDelegate: ArrayFlowDelegateProtocol {
		
		public var setType: ArrayFlowSetType { .all }
		
		public func children(for parent: UITabBarController) -> [UIViewController] {
			parent.viewControllers ?? []
		}
		
		public func currentChild(for parent: UITabBarController) -> UIViewController? {
			parent.selectedViewController
		}
		
		public func set(children: [UIViewController], current: Int, to parent: UITabBarController, animated: Bool, completion: OnReadyCompletion<Void>) {
			if parent.presentedViewController != nil {
				completion.onReady { completion in
					multiCompletion(
						[
							{ parent.set(viewControllers: children, current: current, animated: animated, completion: $0) },
							{ parent.dismissPresented(animated: animated, completion: $0) }
						]
					) {
						completion(())
					}
				}
			} else {
				parent.set(viewControllers: children, current: current, animated: animated) {
					completion.complete(())
				}
			}
		}
	}
	
}

open class FlowTabBarController: UITabBarController, UITabBarControllerDelegate {
	
	required public init?(coder: NSCoder) {
		super.init(coder: coder)
		delegate = self
	}
	
	override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		delegate = self
	}
	
	public init() {
		super.init(nibName: nil, bundle: nil)
		delegate = self
	}
	
	open func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		guard fromVC !== toVC else { return nil }
		return TabBarTransitioning(tabBarController: tabBarController, from: fromVC, to: toVC)
	}
	
}

open class TabBarTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
	
	open weak var tabBarController: UITabBarController?
	open var fromRight = true
	
	public override init() {
		super.init()
	}
	
	public init(tabBarController: UITabBarController, from fromVC: UIViewController, to toVC: UIViewController) {
		super.init()
		self.tabBarController = tabBarController
		let from = tabBarController.viewControllers?.firstIndex(of: fromVC) ?? 0
		let to = tabBarController.viewControllers?.firstIndex(of: toVC) ?? (from + 1)
		fromRight = from < to
	}
	
	open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		guard	let fromVC = transitionContext.viewController(forKey: .from),
					let fromView = transitionContext.view(forKey: .from),
					let toView: UIView = transitionContext.view(forKey: .to) else {
			transitionContext.completeTransition(false)
			return
		}
		let frame = transitionContext.initialFrame(for: fromVC)
		var fromFrameEnd = frame
		var toFrameStart = frame
		fromFrameEnd.origin.x = fromRight ? frame.origin.x - frame.width : frame.origin.x + frame.width
		toFrameStart.origin.x = fromRight ? frame.origin.x + frame.width : frame.origin.x - frame.width
		toView.frame = toFrameStart
		transitionContext.containerView.addSubview(toView)
		
		UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0, options: .curveEaseInOut, animations: {
			fromView.frame = fromFrameEnd
			toView.frame = frame
		}, completion: { success in
			transitionContext.completeTransition(success)
		})
	}

	open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		0.25
	}
	
}

fileprivate final class TabBarContextTransitioning: NSObject, UIViewControllerContextTransitioning {
	let containerView: UIView
	var isAnimated = true
	var isInteractive = false
	var transitionWasCancelled = false
	var presentationStyle = UIModalPresentationStyle.fullScreen
	var targetTransform = CGAffineTransform.identity
	let completion: () -> Void
	let from: UIViewController
	let to: UIViewController
	let defaultFrame: CGRect
	
	init(completion: @escaping () -> Void, from: UIViewController, to: UIViewController) {
		self.completion = completion
		containerView = from.view?.superview ?? UIView()
		self.from = from
		self.to = to
		defaultFrame = from.view.frame
	}
	
	func updateInteractiveTransition(_ percentComplete: CGFloat) {}
	func finishInteractiveTransition() {
		completion()
	}
	func cancelInteractiveTransition() {
		transitionWasCancelled = true
	}
	func pauseInteractiveTransition() {}
	
	func completeTransition(_ didComplete: Bool) {
		completion()
	}
	
	func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? {
		switch key {
		case .from:	return from
		case .to:		return to
		default:		return nil
		}
	}
	
	func view(forKey key: UITransitionContextViewKey) -> UIView? {
		switch key {
		case .from:
			from.loadViewIfNeeded()
			return from.view
		case .to:
			to.loadViewIfNeeded()
			return to.view
		default:
			return nil
		}
	}
	
	func initialFrame(for vc: UIViewController) -> CGRect {
		defaultFrame
	}
	
	func finalFrame(for vc: UIViewController) -> CGRect {
		defaultFrame
	}
	
}
