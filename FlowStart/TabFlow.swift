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
	
	public init(create: @escaping @autoclosure () -> UITabBarController, components: [AnyFlowComponent]) {
		createController = create
		self.delegate = ArrayFlow(
			delegate: .init(),
			components: components.map {
				($0.rootComponent as? TabFlow)?.delegate.components ?? [$0]
			}
			.joined()
			.filter { $0.contentType is UIViewController.Type }
		)
	}
	
	public func create() -> UITabBarController {
		createController()
	}
	
}

extension UITabBarController {
	
	public func set(viewControllers: [UIViewController], current: Int, animated: Bool, completion: @escaping () -> Void = {}) {
		setViewControllers(viewControllers, animated: false)
		selectedIndex = current
		completion()
	}
	
}

extension TabFlow {
	
	public init(create: @escaping @autoclosure () -> UITabBarController = UITabBarController(), @FlowBuilder _ builder: () -> FlowArrayConvertable) {
		self = TabFlow(create: create(), components: builder().asFlowArray())
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
