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
	
	public func update(content: UINavigationController, data: ()?) {
		guard content.presentedViewController == nil,
				let id = self.id,
				component.asVcList.idsChanged(vcs: content.viewControllers),
				let i = component.asVcList.index(for: id) else {
			return
		}
		var vcs = component.asVcList.controllers(current: content.viewControllers, upTo: i)
//		print(content.topViewController?.anyFlowId, vcs.map { $0.anyFlowId })
		if let i = vcs.firstIndex(where: { $0.isDisabledBack }), i > 0 {
			vcs.removeFirst(i - 1)
		}
//		if let new = component.asVcList.create(from: vcs) {
//			component.update(content: new, data: nil)
//		}
		guard vcs != content.viewControllers else { return }
		let animated = FlowStep.isAnimated && content.view?.window != nil
		content.set(viewControllers: vcs, animated: animated && vcs.last !== content.topViewController)
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

fileprivate var disableBackKey = "disableBackKey"
fileprivate var strongDelegateKey = "strongDelegateKey"
