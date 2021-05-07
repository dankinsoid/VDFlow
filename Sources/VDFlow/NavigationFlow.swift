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
	
	public init(create: @escaping @autoclosure () -> UINavigationController = .init(), _ selection: Binding<Selection?>, @IterableViewBuilder _ builder: () -> Content) {
		self.init(create: create, selection, content: builder())
	}
	
	public init(delegate: UINavigationControllerDelegate, _ selection: Binding<Selection?>, @IterableViewBuilder _ builder: () -> Content) {
		self.init(create: {
			let vc = UINavigationController()
			vc.delegate = delegate
			return vc
		}, selection, content: builder())
	}
	
	public func makeUIViewController(context: Context) -> UINavigationController {
		let vc = createController()
		vc.strongDelegate = Delegate<Selection>(_id, delegate: vc.delegate)
		let visitor = FirstViewControllerVisitor()
		_ = content.iterate(with: visitor)
		if let first = visitor.vc {
			vc.setViewControllers([first], animated: false)
		}
		vc.on {[weak vc] in
			if let content = vc {
				update(content: content)
			}
		} disappear: {
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
		content.dismissPresented(animated: animated) {
			content.set(viewControllers: vcs, animated: animated)
		}
	}
}

private final class Delegate<ID: Hashable>: NSObject, UINavigationControllerDelegate {
	@Binding var id: ID?
	weak var delegate: UINavigationControllerDelegate?
	
	init(_ id: Binding<ID?>, delegate: UINavigationControllerDelegate?) {
		self._id = id
		self.delegate = delegate
	}
	
	func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
		let newId = viewController.flowId(of: ID.self)
		if newId != id {
			id = newId
		}
	}
	
	func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		delegate?.navigationController?(navigationController, interactionControllerFor: animationController)
	}
	
	func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		delegate?.navigationController?(navigationController, animationControllerFor: operation, from: fromVC, to: toVC)
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

private extension UIViewController {
	
	var appearDelegate: AppearDelegate? {
		get { objc_getAssociatedObject(self, &appearDelegateKey) as? AppearDelegate }
		set {
			objc_setAssociatedObject(self, &appearDelegateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
	}
	
	func setIdOnAppear<T: Hashable>(_ binding: Binding<T?>, root: UIViewController) {
		on {[weak self] in
			let newId = self?.flowId(of: T.self)
			if newId != binding.wrappedValue {
				binding.wrappedValue = newId
			}
		} disappear: {[weak root] in
			let newId = root?.vcForPresent.flowId(of: T.self)
			if newId != binding.wrappedValue {
				binding.wrappedValue = newId
			}
		}
	}
	
	func on(appear: @escaping () -> Void, disappear: @escaping () -> Void ) {
		if let delegate = appearDelegate {
			delegate.appear = appear
			delegate.disappear = disappear
		} else {
			let delegate = AppearDelegate(appear, disappear)
			appearDelegate = delegate
			_ = try? onMethodInvoked(#selector(viewDidAppear)) { _ in
				delegate.appear()
			}
			_ = try? onMethodInvoked(#selector(viewDidDisappear)) { _ in
				delegate.disappear()
			}
		}
	}
}

fileprivate var disableBackKey = "disableBackKey"
fileprivate var strongDelegateKey = "strongDelegateKey"
fileprivate var appearDelegateKey = "appearDelegateKey"

private final class AppearDelegate {
	var appear: () -> Void
	var disappear: () -> Void
	
	init(_ appear: @escaping () -> Void, _ disappear: @escaping () -> Void) {
		self.appear = appear
		self.disappear = disappear
	}
}
