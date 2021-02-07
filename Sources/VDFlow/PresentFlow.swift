//
//  PresentFlow.swift
//  FlowStart
//
//  Created by Daniil on 05.11.2020.
//

import Foundation
import UIKit

public typealias PresentClosure = (UIViewController, UIViewController, Bool, @escaping () -> Void) -> Void

public struct PresentFlow<Root: FlowComponent>: ArrayFlowProtocol where Root.Content: UIViewController {
	
	public let delegate: ArrayFlow<PresentFlowDelegate<Root.Content>>
	public let root: Root
	
	public init(root: Root, presentationStyle: UIModalPresentationStyle? = nil, transitionStyle: UIModalTransitionStyle? = nil, present: @escaping PresentClosure = { $0.present($1, animated: $2, completion: $3) }, components: [AnyFlowComponent]) {
		self.root = root
		self.delegate = ArrayFlow(
			delegate: .init(
				presentationStyle: presentationStyle,
				transitionStyle: transitionStyle,
				present: present
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
	
	public init(root: Root, presentationStyle: UIModalPresentationStyle? = nil, transitionStyle: UIModalTransitionStyle? = nil, present: @escaping PresentClosure = { $0.present($1, animated: $2, completion: $3) }, @FlowBuilder _ builder: () -> FlowArrayConvertable) {
		self = PresentFlow(root: root, presentationStyle: presentationStyle, transitionStyle: transitionStyle, present: present, components: builder().asFlowArray())
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
		present(viewControllers, animated: animated, presentClosure: { $0.present($1, animated: $2, completion: $3) }, completion: completion)
	}
	
	fileprivate func present(_ viewControllers: [UIViewController], animated: Bool, presentClosure: @escaping PresentClosure, completion: (() -> Void)? = nil) {
		let presented = allPresented
		let common = presented.commonPrefix(with: viewControllers)
		let toPresent = Array(viewControllers.dropFirst(common.count))
		if presented.count > common.count {
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
		vcForPresent.present(vcs[0], animated: animated) {
			self.present(vcs: Array(vcs.dropFirst()), animated: animated, presentClosure: presentClosure, completion: completion)
		}
	}
	
	private func set(controllers: [UIViewController], completion: (() -> Void)?) {
		dismissPresented(animated: false) {
			self.present(controllers: controllers, completion: completion)
		}
	}
	
	private func present(controllers: [UIViewController], completion: (() -> Void)?) {
		guard let vc = controllers.first else {
			completion?()
			return
		}
		vcForPresent.present(vc, animated: false) {
			self.present(controllers: Array(controllers.dropFirst()), completion: completion)
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

public struct PresentFlowDelegate<Parent: UIViewController>: ArrayFlowDelegateProtocol {
	
	public let setType = ArrayFlowSetType.upTo(min: 0)
	public let presentationStyle: UIModalPresentationStyle?
	public let transitionStyle: UIModalTransitionStyle?
	public let present: PresentClosure
	
	public func children(for parent: Parent) -> [UIViewController] {
		parent.allPresented
	}
	
	public func currentChild(for parent: Parent) -> UIViewController? {
		parent.allPresented.last ?? parent
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
			parent.present(children.prefix(current + 1).filter { $0 !== parent }, animated: animated, presentClosure: present) {
				completion(())
			}
		}
	}
	
}
