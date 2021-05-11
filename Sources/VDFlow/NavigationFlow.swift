//
//  NavigationFlow.swift
//  FlowStart
//
//  Created by Daniil on 02.11.2020.
//

import Foundation
import UIKit
import SwiftUI
import VDKit

public struct NavigationFlow<Content: IterableView, Selection: Hashable>: FullScreenUIViewControllerRepresentable {
	
	public let createController: () -> UINavigationController
	public let content: Content
	@Binding private var id: Selection?
	
	public init(create: @escaping () -> UINavigationController, _ selection: Binding<Selection?>, content: Content) {
		createController = create
		self.content = content
		_id = selection
	}
	
	public init(create: @escaping @autoclosure () -> UINavigationController = NavigationFlowController(), _ selection: Binding<Selection?>, @IterableViewBuilder _ builder: () -> Content) {
		self.init(create: create, selection, content: builder())
	}
	
	public init(delegate: UINavigationControllerDelegate, _ selection: Binding<Selection?>, @IterableViewBuilder _ builder: () -> Content) {
		self.init(create: {
			let vc = NavigationFlowController()
			vc.delegate = delegate
			return vc
		}, selection, content: builder())
	}
	
	public func makeUIViewController(context: Context) -> UINavigationController {
		let vc = createController()
		if let _: (UINavigationController, UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? = vc.delegate?.navigationController {
			vc.strongDelegate = FullDelegate<Selection>(_id, delegate: vc.delegate)
		} else if let _: (UINavigationController, UINavigationController.Operation, UIViewController, UIViewController) -> UIViewControllerAnimatedTransitioning? = vc.delegate?.navigationController {
			vc.strongDelegate = FullDelegate<Selection>(_id, delegate: vc.delegate)
		} else {
			vc.strongDelegate = Delegate<Selection>(_id, delegate: vc.delegate)
		}
		let visitor = FirstViewControllerVisitor()
		_ = content.iterate(with: visitor)
		if let first = visitor.vc {
			vc.setViewControllers([first], animated: false)
		}
		return vc
	}
	
	public func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
		update(content: uiViewController)
	}
	
	private func update(content: UINavigationController) {
		guard let id = self.id else { return }
		let visitor = ControllersVisitor(current: content.viewControllers, upTo: id)
		_ = self.content.iterate(with: visitor)
		guard visitor.index != nil else { return }
	
		var vcs = visitor.new
		if let i = vcs.firstIndex(where: { $0.isDisabledBack }), i > 0 {
			vcs.removeFirst(i - 1)
		}
		guard vcs != content.viewControllers else { return }
		let animated = FlowStep.isAnimated && content.view?.window != nil
//		content.dismissPresented(animated: animated) {
			content.set(viewControllers: vcs, animated: animated)
//		}
	}
}

private class Delegate<ID: Hashable>: NSObject, UINavigationControllerDelegate {
	@Binding var id: ID?
	weak var delegate: UINavigationControllerDelegate?
	
	init(_ id: Binding<ID?>, delegate: UINavigationControllerDelegate?) {
		self._id = id
		self.delegate = delegate
	}
	
	func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
		let newId = viewController.anyFlowId?.base as? ID
		if newId != id {
			id = newId
		}
	}
	
	func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
		delegate?.navigationController?(navigationController, willShow: viewController, animated: animated)
	}
	
	func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
		delegate?.navigationControllerSupportedInterfaceOrientations?(navigationController) ?? .all
	}
	
	func navigationControllerPreferredInterfaceOrientationForPresentation(_ navigationController: UINavigationController) -> UIInterfaceOrientation {
		delegate?.navigationControllerPreferredInterfaceOrientationForPresentation?(navigationController) ?? .portrait
	}
}

private final class FullDelegate<ID: Hashable>: Delegate<ID> {
	
	func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		delegate?.navigationController?(navigationController, interactionControllerFor: animationController)
	}
	
	func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		delegate?.navigationController?(navigationController, animationControllerFor: operation, from: fromVC, to: toVC)
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
	
	var strongDelegate: UINavigationControllerDelegate? {
		get { objc_getAssociatedObject(self, &strongDelegateKey) as? UINavigationControllerDelegate }
		set {
			delegate = newValue
			objc_setAssociatedObject(self, &strongDelegateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
	}
}

extension UIViewController {
	var isDisabledBack: Bool {
		get { (objc_getAssociatedObject(self, &disableBackKey) as? Bool) ?? false }
		set { objc_setAssociatedObject(self, &disableBackKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
	}
}

fileprivate var disableBackKey = "disableBackKey"
fileprivate var strongDelegateKey = "strongDelegateKey"

public final class NavigationFlowController: UINavigationController {
	
	public override var childForStatusBarStyle: UIViewController? { topViewController }
	
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	public init() {
		super.init(navigationBarClass: NavigationFlowBar.self, toolbarClass: nil)
	}
}

public final class NavigationFlowBar: UINavigationBar {
	
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		afterInit()
	}
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		afterInit()
	}
	
	private func afterInit() {
		self.setBackgroundImage(UIImage(), for: .default)
		self.shadowImage = UIImage()
		self.isTranslucent = true
		self.backgroundColor = .clear
		if #available(iOS 13.0, *) {
			self.standardAppearance.backgroundColor = .clear
			self.standardAppearance.backgroundEffect = .none
			self.standardAppearance.shadowColor = .clear
		}
	}
}
