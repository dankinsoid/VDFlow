//
//  NavigationFlow.swift
//  FlowStart
//
//  Created by Daniil on 02.11.2020.
//

import Foundation
import UIKit

public struct NavigationFlow: ArrayFlowProtocol {
	
	private let createController: () -> UINavigationController
	public let delegate: ArrayFlow<UINavigationController.ArrayDelegate>
	
	public init(create: @escaping () -> UINavigationController, components: [AnyFlowComponent]) {
		createController = create
		self.delegate = ArrayFlow(
			delegate: .init(),
			components: Array(components.map {
				($0.rootComponent as? NavigationFlow)?.delegate.components ?? [$0]
			}
			.joined())
		)
	}
	
	public func create() -> UINavigationController {
		createController()
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
	
}

extension NavigationFlow {
	
	public init(create: @escaping @autoclosure () -> UINavigationController = UINavigationController(), @FlowBuilder _ builder: () -> FlowArrayConvertable) {
		self = NavigationFlow(create: create, components: builder().asFlowArray())
	}
	
}

extension UINavigationController {
	
	public struct ArrayDelegate: ArrayFlowDelegateProtocol {
		public var setType: ArrayFlowSetType { .upTo }
		
		public func children(for parent: UINavigationController) -> [UIViewController] {
			parent.viewControllers
		}
		
		public func currentChild(for parent: UINavigationController) -> UIViewController? {
			parent.topViewController
		}
		
		public func set(children: [UIViewController], current: Int, to parent: UINavigationController, animated: Bool, completion: OnReadyCompletion<Void>) {
			var array = Array(children.prefix(current + 1))
			if let i = array.lastIndex(where: { $0.isDisabledBack }) {
				array.removeFirst(i)
			}
			if parent.presentedViewController != nil {
				completion.onReady { completion in
					parent.dismissPresented(animated: animated) {
						parent.set(viewControllers: array, animated: animated) {
							completion(())
						}
					}
				}
			} else {
				parent.set(viewControllers: array, animated: animated) {
					completion.complete(())
				}
			}
		}
		
	}
	
}

extension UIViewController {
	
	var isDisabledBack: Bool {
		get { (objc_getAssociatedObject(self, &disableBackKey) as? Bool) ?? false }
		set { objc_setAssociatedObject(self, &disableBackKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
	}
	
}

fileprivate var disableBackKey = "disableBackKey"
