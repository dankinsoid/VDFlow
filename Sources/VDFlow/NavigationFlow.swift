//
//  NavigationFlow.swift
//  FlowStart
//
//  Created by Daniil on 02.11.2020.
//

import Foundation
import UIKit
import SwiftUI

public struct NavigationFlow<Component: FlowComponent, Selection: Hashable>: FlowComponent, FullScreenUIViewControllerRepresentable where Component.Content: UIViewControllerArrayConvertable {
	
	public let createController: () -> UINavigationController
	public let component: Component
	@Binding private var id: Selection?
	
	public init(create: @escaping () -> UINavigationController, _ selection: Binding<Selection?>, component: Component) {
		createController = create
		self.component = component
		_id = selection
	}
	
	public init(create: @escaping @autoclosure () -> UINavigationController = .init(), _ selection: Binding<Selection?>, @FlowBuilder _ builder: () -> Component) {
		self = NavigationFlow(create: create, selection, component: builder())
	}
	
	public func create() -> UINavigationController {
		let vc = createController()
		vc.strongDelegate = Delegate<Selection>(_id)
		if let first = component.asVcList.create().first {
			vc.setViewControllers([first], animated: false)
		}
		vc.on {[weak vc] in
			if let content = vc {
				update(content: content, data: nil)
			}
		} disappear: {
		}
		return vc
	}
	
	public func makeUIViewController(context: Context) -> UINavigationController {
		create()
	}
	
	public func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
		update(content: uiViewController, data: nil)
	}
	
	public func update(content: UINavigationController, data: Void?) {
		print("navigation", id, component.asVcList.idsChanged(vcs: content.viewControllers))
		guard //content.presentedViewController == nil,
				let id = self.id,
				//component.asVcList.idsChanged(vcs: content.viewControllers),
				let i = component.asVcList.index(for: id) else {
			return
		}
		var vcs = component.asVcList.controllers(current: content.viewControllers, upTo: i)
		if let i = vcs.firstIndex(where: { $0.isDisabledBack }), i > 0 {
			vcs.removeFirst(i - 1)
		}
//		if let new = component.asVcList.create(from: vcs) {
//			component.update(content: new, data: nil)
//		}
		guard vcs != content.viewControllers else { return }
		let animated = FlowStep.isAnimated && content.view?.window != nil
		content.dismissPresented(animated: animated) {
			content.set(viewControllers: vcs, animated: animated && vcs.last !== content.topViewController)
		}
	}
}

private final class Delegate<ID: Hashable>: NSObject, UINavigationControllerDelegate {
	@Binding var id: ID?
	
	init(_ id: Binding<ID?>) {
		self._id = id
	}
	
	func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
		let newId = viewController.flowId(of: ID.self)
		if newId != id {
			id = newId
		}
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
