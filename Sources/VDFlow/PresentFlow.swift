//
//  PresentFlow.swift
//  FlowStart
//
//  Created by Daniil on 05.11.2020.
//

import Foundation
import UIKit

public typealias PresentClosure = (UIViewController, UIViewController, Bool, @escaping () -> Void) -> Void

public protocol UIViewControllerConvertable {
	func asViewController() -> UIViewController?
}

public struct PresentFlow<Root: FlowComponent>: ArrayFlowProtocol where Root.Content: UIViewControllerConvertable {
	
	public let delegate: ArrayFlow<PresentFlowDelegate<Root.Content>>
	public let root: Root
	
	public init(root: Root, presentationStyle: UIModalPresentationStyle? = nil, transitionStyle: UIModalTransitionStyle? = nil, dismissPresented: Bool = true, present: @escaping PresentClosure = { $0.present($1, animated: $2, completion: $3) }, components: [AnyFlowComponent]) {
		self.root = root
		self.delegate = ArrayFlow(
			delegate: .init(
				presentationStyle: presentationStyle,
				transitionStyle: transitionStyle,
				present: present,
				dismiss: dismissPresented
			),
			root: root,
			components: components
		)
	}
	
	public func create() -> Root.Content {
		root.create()
	}
	
}

extension PresentFlow {
	
	public init(root: Root, presentationStyle: UIModalPresentationStyle? = nil, transitionStyle: UIModalTransitionStyle? = nil, dismissPresented: Bool = true, present: @escaping PresentClosure = { $0.present($1, animated: $2, completion: $3) }, @FlowBuilder _ builder: () -> FlowArrayConvertable) {
		self = PresentFlow(root: root, presentationStyle: presentationStyle, transitionStyle: transitionStyle, dismissPresented: dismissPresented, present: present, components: builder().asFlowArray())
	}
	
}

extension UIViewController {
	
	var vcForPresent: UIViewController {
		presentedViewController?.vcForPresent ?? self
	}
	
	public var allPresented: [UIViewController] {
		presentedViewController.map { [$0] + $0.allPresented } ?? []
	}
	
	public func present(_ viewControllers: [UIViewController], animated: Bool, completion: (() -> Void)? = nil) {
		present(viewControllers, dismiss: true, animated: animated, presentClosure: { $0.present($1, animated: $2, completion: $3) }, completion: completion)
	}
	
	fileprivate func present(_ viewControllers: [UIViewController], dismiss: Bool, animated: Bool, presentClosure: @escaping PresentClosure, completion: (() -> Void)? = nil) {
		let presented = allPresented
		let common = presented.commonPrefix(with: viewControllers)
		let toPresent = Array(viewControllers.dropFirst(common.count))
		if dismiss, presented.count > common.count {
			presented[common.count].dismissSelf(animated: animated) {
				self.present(vcs: toPresent, animated: animated, presentClosure: presentClosure, completion: completion)
			}
		} else {
			present(vcs: toPresent, animated: animated, presentClosure: presentClosure, completion: completion)
		}
	}
	
	private func present(vcs: [UIViewController], animated: Bool, presentClosure: @escaping PresentClosure, completion: (() -> Void)?) {
		guard !vcs.isEmpty else {
			completion?()
			return
		}
		presentClosure(vcForPresent, vcs[0], animated) {
			self.present(vcs: Array(vcs.dropFirst()), animated: animated, presentClosure: presentClosure, completion: completion)
		}
	}
	
	public func dismissSelf(animated: Bool, completion: (() -> Void)?) {
		guard presentedViewController == nil else {
			if !animated {
				dismiss(animated: animated) {
					self.dismiss(animated: animated, completion: completion)
				}
				return
			}
			presentedViewController?.dismissSelf(animated: animated, completion: completion)
			return
		}
		dismiss(animated: animated, completion: completion)
	}
	
	public func dismissPresented(animated: Bool, completion: (() -> Void)?) {
		guard presentedViewController != nil else {
			completion?()
			return
		}
		guard animated else {
			dismiss(animated: animated, completion: completion)
			return
		}
		vcForPresent.dismiss(animated: animated) {
			self.dismissPresented(animated: animated, completion: completion)
		}
	}
	
}

extension Array where Element: Equatable {
	
	func commonPrefix(with array: [Element]) -> [Element] {
		var i = 0
		while i < count, i < array.count, self[i] == array[i] {
			i += 1
		}
		return Array(prefix(i))
	}
	
}

public struct PresentFlowDelegate<Parent: UIViewControllerConvertable>: ArrayFlowDelegateProtocol {
	
	public let setType = ArrayFlowSetType.upTo(min: 0)
	public let presentationStyle: UIModalPresentationStyle?
	public let transitionStyle: UIModalTransitionStyle?
	public let present: PresentClosure
	public let dismiss: Bool
	
	public func children(for parent: Parent) -> [UIViewController] {
		parent.asViewController()?.allPresented ?? []
	}
	
	public func currentChild(for parent: Parent) -> UIViewController? {
		parent.asViewController()?.allPresented.last ?? parent.asViewController()
	}
	
	public func update(id: String, child: UIViewController) {
		child.nodeId = id
		if let style = presentationStyle {
			child.modalPresentationStyle = style
		}
		if let style = transitionStyle {
			child.modalTransitionStyle = style
		}
	}
	
	public func set(children: [UIViewController], current: Int, to parent: Parent, animated: Bool, completion: OnReadyCompletion<Void>) {
		completion.onReady { completion in
			parent.asViewController()?.present(children.prefix(current + 1).filter { $0 !== parent.asViewController() }, dismiss: dismiss, animated: animated, presentClosure: present) {
				completion(())
			}
		}
	}
	
}

extension UIViewController: UIViewControllerConvertable {
	public func asViewController() -> UIViewController? {
		self
	}
}

extension UIWindow: UIViewControllerConvertable {
	public func asViewController() -> UIViewController? {
		rootViewController
	}
}
