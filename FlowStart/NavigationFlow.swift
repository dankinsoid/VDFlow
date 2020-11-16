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
	
	public init(create: @escaping @autoclosure () -> UINavigationController, components: [AnyFlowComponent]) {
		createController = create
		self.delegate = ArrayFlow(
			delegate: .init(),
			components: components.map {
				($0.rootComponent as? NavigationFlow)?.delegate.components ?? [$0]
			}
			.joined()
			.filter { $0.contentType is UIViewController.Type }
		)
	}
	
	public func create() -> UINavigationController {
		createController()
	}
	
	public func willUpdate(content: UINavigationController, data: FlowStep?) {
		
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
		self = NavigationFlow(create: create(), components: builder().asFlowArray())
	}
	
}

extension UINavigationController {
	
	public struct ArrayDelegate: ArrayFlowDelegateProtocol {
		
		public func children(for parent: UINavigationController) -> [UIViewController] {
			parent.viewControllers
		}
		
		public func currentChild(for parent: UINavigationController) -> UIViewController? {
			parent.topViewController
		}
		
		public func set(children: [UIViewController], to parent: UINavigationController, animated: Bool, completion: OnReadyCompletion<Void>) {
			if parent.presentedViewController != nil {
				completion.onReady { completion in
					parent.dismissPresented(animated: animated) {
						parent.set(viewControllers: children, animated: animated) {
							completion(())
						}
					}
				}
			} else {
				parent.set(viewControllers: children, animated: animated) {
					completion.complete(())
				}
			}
		}
		
	}
	
}
