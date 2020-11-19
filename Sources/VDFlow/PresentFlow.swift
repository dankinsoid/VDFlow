//
//  PresentFlow.swift
//  FlowStart
//
//  Created by Daniil on 05.11.2020.
//

import Foundation
import UIKit

public struct PresentFlow<Root: FlowComponent>: ArrayFlowProtocol where Root.Content: UIViewController {
	
	public let delegate: ArrayFlow<PresentFlowDelegate<Root.Content>>
	public let root: Root
	
	public init(root: Root, presentationStyle: UIModalPresentationStyle? = nil, transitionStyle: UIModalTransitionStyle? = nil, components: [AnyFlowComponent]) {
		self.root = root
		self.delegate = ArrayFlow(
			delegate: .init(
				presentationStyle: presentationStyle,
				transitionStyle: transitionStyle
			),
			root: root,
			components: components.filter { $0.contentType is UIViewController.Type }
		)
	}
	
	public func create() -> Root.Content {
		root.create()
	}
	
}

extension PresentFlow {
	
	public init(root: Root, presentationStyle: UIModalPresentationStyle? = nil, transitionStyle: UIModalTransitionStyle? = nil, @FlowBuilder _ builder: () -> FlowArrayConvertable) {
		self = PresentFlow(root: root, presentationStyle: presentationStyle, transitionStyle: transitionStyle, components: builder().asFlowArray())
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
		let presented = allPresented
		let common = presented.commonPrefix(with: viewControllers)
		let toPresent = Array(viewControllers.dropFirst(common.count))
		if presented.count > common.count {
			presented[common.count].dismissSelf(animated: animated) {
				self.present(vcs: toPresent, animated: animated, completion: completion)
			}
		} else {
			present(vcs: toPresent, animated: animated, completion: completion)
		}
	}
	
	private func present(vcs: [UIViewController], animated: Bool, completion: (() -> Void)?) {
		guard !vcs.isEmpty else {
			completion?()
			return
		}
		vcForPresent.present(vcs[0], animated: animated) {
			self.present(vcs: Array(vcs.dropFirst()), animated: animated, completion: completion)
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
	
	public let setType = ArrayFlowSetType.upTo
	public let presentationStyle: UIModalPresentationStyle?
	public let transitionStyle: UIModalTransitionStyle?
	
	public func children(for parent: Parent) -> [UIViewController] {
		parent.allPresented
	}
	
	public func currentChild(for parent: Parent) -> UIViewController? {
		parent.allPresented.last ?? parent
	}
	
	public func update(id: String, child: UIViewController) {
		child.flowId = id
		if let style = presentationStyle {
			child.modalPresentationStyle = style
		}
		if let style = transitionStyle {
			child.modalTransitionStyle = style
		}
	}
	
	public func set(children: [UIViewController], current: Int, to parent: Parent, animated: Bool, completion: OnReadyCompletion<Void>) {
		completion.onReady { completion in
			parent.present(children.prefix(current + 1).filter { $0 !== parent }, animated: animated) {
				completion(())
			}
		}
	}
	
}
