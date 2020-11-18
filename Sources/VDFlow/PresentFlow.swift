//
//  PresentFlow.swift
//  FlowStart
//
//  Created by Daniil on 05.11.2020.
//

import Foundation
import UIKit

public struct PresentFlow<Root: FlowComponent>: BaseFlow {
	
	private let delegate: ArrayFlow<PresentFlowDelegate>
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
	
	public func navigate(to step: FlowStep, content: Root.Content, completion: FlowCompletion) {
		guard let vc = content as? UIViewController else {
			completion.complete(nil)
			return
		}
		delegate.navigate(to: step, flow: self, parent: vc, completion: completion)
	}
	
	public func canNavigate(to point: FlowPoint) -> Bool {
		delegate.canNavigate(to: point)
	}
	
	public func flow(with point: FlowPoint) -> AnyBaseFlow? {
		if root.asFlow == nil, root.isPoint(point) == true {
			return self
		} else if let flow = delegate.flow(with: point) {
			return flow
		} else if canNavigate(to: point) {
			return self
		}
		return nil
	}
	
	public func current(content: Root.Content) -> (AnyFlowComponent, Any)? {
		guard let vc = content as? UIViewController else {
			return nil
		}
		return delegate.current(parent: vc)
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

public struct PresentFlowDelegate: ArrayFlowDelegateProtocol {
	
	public let setType = ArrayFlowSetType.upTo
	public let presentationStyle: UIModalPresentationStyle?
	public let transitionStyle: UIModalTransitionStyle?
	
	public func children(for parent: UIViewController) -> [UIViewController] {
		parent.allPresented
	}
	
	public func currentChild(for parent: UIViewController) -> UIViewController? {
		parent.allPresented.last ?? parent
	}
	
	public func update(id: String, child: Child) {
		child.flowId = id
		if let style = presentationStyle {
			child.modalPresentationStyle = style
		}
		if let style = transitionStyle {
			child.modalTransitionStyle = style
		}
	}
	
	public func set(children: [UIViewController], current: Int, to parent: UIViewController, animated: Bool, completion: OnReadyCompletion<Void>) {
		completion.onReady { completion in
			parent.present(children.prefix(current + 1).filter { $0 !== parent }, animated: animated) {
				completion(())
			}
		}
	}
	
}
