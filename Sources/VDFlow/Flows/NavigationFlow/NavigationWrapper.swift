//
//  File.swift
//  
//
//  Created by Данил Войдилов on 24.11.2021.
//

#if canImport(UIKit)
import Foundation
import UIKit
import SwiftUI
import IterableView

struct NavigationWrapper<Content: View, Selection: Hashable>: UIViewControllerRepresentable {
	
	@Environment(\.navigationFlow.createController) private var createController
	let content: [TaggedView<Content>]
	@StateOrBinding private var selection: Selection
	@Environment(\.navigationFlowEnvironment) private var environment
	
	init(_ selection: StateOrBinding<Selection>, content: [TaggedView<Content>]) {
		self.content = content
		_selection = selection
	}
	
	func makeUIViewController(context: Context) -> UINavigationController {
		let vc = createController()
		if let _: (UINavigationController, UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? = vc.delegate?.navigationController {
			vc.strongDelegate = FullDelegate<Selection>($selection, delegate: vc.delegate)
		} else if let _: (UINavigationController, UINavigationController.Operation, UIViewController, UIViewController) -> UIViewControllerAnimatedTransitioning? = vc.delegate?.navigationController {
			vc.strongDelegate = FullDelegate<Selection>($selection, delegate: vc.delegate)
		} else {
			vc.strongDelegate = NavigationDelegate<Selection>($selection, delegate: vc.delegate)
		}
		if let first = content.first {
			let host = ObservableHostingController(rootView: first)
			host.setFlowId(first.tag)
			vc.setViewControllers([host], animated: false)
		}
		return vc
	}
	
	func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
		environment.update = {[weak uiViewController] in
			guard let vc = uiViewController else { return }
			updateUIViewController(vc, environment: $0, transaction: $1, ifBinding: false)
		}
		updateUIViewController(uiViewController, environment: context.environment, transaction: context.transaction, ifBinding: true)
	}
	
	private func updateUIViewController(_ uiViewController: UINavigationController, environment: EnvironmentValues, transaction: Transaction, ifBinding: Bool) {
		uiViewController.update(environment: environment.navigationFlow)
		(uiViewController.strongDelegate as? NavigationDelegate<Selection>)?.environmnet = environment.navigationFlow
		if ifBinding {
			guard case .binding = _selection else { return }
		}
		let visitor = ControllersVisitor(current: uiViewController.viewControllers, upTo: selection)
		visitor.iterate(content) { array, tag in
			self.environment.children[tag]?(array) ?? []
		}
		var vcs = visitor.new
		if let i = vcs.firstIndex(where: { $0.isDisabledBack }), i > 0 {
			vcs.removeFirst(i - 1)
		}
		guard visitor.index != nil, vcs != uiViewController.viewControllers else { return }
		let animated = transaction.animation != nil && uiViewController.view?.window != nil
		if (uiViewController.strongDelegate as? NavigationDelegate<Selection>)?.isAnimaing != true, uiViewController.interactivePopGestureRecognizer?.state != .changed {
			uiViewController.set(viewControllers: vcs, animated: animated)
		}
	}
}

class NavigationDelegate<Selection: Hashable>: NSObject, UINavigationControllerDelegate {
	@Binding var selection: Selection
	var isAnimaing = false
	var environmnet = EnvironmentValues.NavigationFlow()
	weak var delegate: UINavigationControllerDelegate?
	
	init(_ selection: Binding<Selection>, delegate: UINavigationControllerDelegate?) {
		self._selection = selection
		self.delegate = delegate
	}
	
	func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
		isAnimaing = false
		if Selection.self == Int.self, viewController.anyFlowId == nil {
			viewController.setFlowId(AnyHashable(navigationController.viewControllers.count - 1))
		}
		let newSelection = viewController.flowId(of: Selection.self) ?? selection
		if newSelection != selection {
			selection = newSelection
		}
	}
	
	func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
		if animated, navigationController.interactivePopGestureRecognizer?.state == .possible {
			isAnimaing = true
		}
		navigationController.update(environment: environmnet)
		delegate?.navigationController?(navigationController, willShow: viewController, animated: animated)
	}
	
	func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
		delegate?.navigationControllerSupportedInterfaceOrientations?(navigationController) ?? .all
	}
	
	func navigationControllerPreferredInterfaceOrientationForPresentation(_ navigationController: UINavigationController) -> UIInterfaceOrientation {
		delegate?.navigationControllerPreferredInterfaceOrientationForPresentation?(navigationController) ?? .portrait
	}
}

private final class FullDelegate<ID: Hashable>: NavigationDelegate<ID> {
	
	func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		delegate?.navigationController?(navigationController, interactionControllerFor: animationController)
	}
	
	func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		delegate?.navigationController?(navigationController, animationControllerFor: operation, from: fromVC, to: toVC)
	}
}
#endif
