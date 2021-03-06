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
	private let observeId = "navigationFlow"
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
		guard let id = self.id else { return }
		let visitor = ControllersVisitor(current: uiViewController.viewControllers, upTo: id)
		_ = content.iterate(with: visitor)
		guard visitor.index != nil else { return }
	
		var vcs = visitor.new
		if let i = vcs.firstIndex(where: { $0.isDisabledBack }), i > 0 {
			vcs.removeFirst(i - 1)
		}
		vcs.compactMap({ $0 as? ObservableControllerType }).forEach { vc in
			_ = vc.on(.willAppear, id: observeId) {[weak uiViewController, weak vc] _ in
				guard let nc = uiViewController else { return }
				vc?.navigationItem.largeTitleDisplayMode = context.environment.navigationFlowLargeTitleMode
				updateStyle(nc, context: context)
			}
		}
		guard vcs != uiViewController.viewControllers else { return }
		let animated = context.transaction.animation != nil && uiViewController.view?.window != nil
		uiViewController.set(viewControllers: vcs, animated: animated)
	}
	
	private func updateStyle(_ uiViewController: UINavigationController, context: Context) {
		uiViewController.navigationBar.set(backgroundColor: context.environment.navigationFlowBarColor.ui)
		uiViewController.navigationBar.set(shadowColor: context.environment.navigationFlowBarShadowColor.ui)
		var attsLarge = uiViewController.navigationBar.largeTitleTextAttributes ?? [:]
		attsLarge[.font] = context.environment.navigationFlowLargeTitleFont
		attsLarge[.foregroundColor] = context.environment.navigationFlowLargeTitleColor?.ui
		uiViewController.navigationBar.largeTitleTextAttributes = attsLarge
		uiViewController.navigationBar.standardAppearance.largeTitleTextAttributes = attsLarge
		uiViewController.navigationBar.scrollEdgeAppearance?.largeTitleTextAttributes = attsLarge
		uiViewController.navigationBar.compactAppearance?.largeTitleTextAttributes = attsLarge
		var atts = uiViewController.navigationBar.titleTextAttributes ?? [:]
		atts[.font] = context.environment.navigationFlowTitleFont
		atts[.foregroundColor] = context.environment.navigationFlowTitleColor?.ui
		uiViewController.navigationBar.titleTextAttributes = atts
		uiViewController.navigationBar.standardAppearance.titleTextAttributes = atts
		uiViewController.navigationBar.scrollEdgeAppearance?.titleTextAttributes = atts
		uiViewController.navigationBar.compactAppearance?.titleTextAttributes = atts
		uiViewController.navigationBar.prefersLargeTitles = context.environment.navigationFlowLargeTitle
		let backImage = context.environment.navigationFlowBackImage
		uiViewController.navigationBar.backIndicatorImage = backImage
		uiViewController.navigationBar.backIndicatorTransitionMaskImage = backImage
		uiViewController.navigationBar.standardAppearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
		uiViewController.navigationBar.scrollEdgeAppearance?.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
		uiViewController.navigationBar.compactAppearance?.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
		uiViewController.navigationBar.tintColor = context.environment.navigationFlowBarAccentColor.ui
		
		if !context.environment.navigationFlowShowBackText {
			uiViewController.navigationBar.backItem?.title = ""
		}
		if let insets = context.environment.navigationFlowBarPadding {
			uiViewController.navigationBar.layoutMargins = UIEdgeInsets(top: insets.top, left: insets.leading, bottom: insets.bottom, right: insets.trailing)
		}
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

extension UINavigationBar {
	
	func set(backgroundColor: UIColor) {
		isTranslucent = true
		barTintColor = backgroundColor
		self.backgroundColor = backgroundColor
		if #available(iOS 13.0, *) {
			let coloredAppearance = UINavigationBarAppearance()
			coloredAppearance.configureWithOpaqueBackground()
			coloredAppearance.backgroundColor = backgroundColor
			standardAppearance = coloredAppearance
			scrollEdgeAppearance = coloredAppearance
			compactAppearance = coloredAppearance
		}
	}
	
	func set(shadowColor: UIColor) {
		shadowImage = UIImage(color: shadowColor)
		if #available(iOS 13.0, *) {
			standardAppearance.shadowColor = shadowColor
			scrollEdgeAppearance?.shadowColor = shadowColor
			compactAppearance?.shadowColor = shadowColor
		}
	}
}

extension UIColor {
	var alpha: CGFloat {
		cgColor.alpha
	}
}
