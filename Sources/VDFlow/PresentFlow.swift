//
//  PresentFlow.swift
//  FlowStart
//
//  Created by Daniil on 05.11.2020.
//

import Foundation
import UIKit

public typealias PresentClosure = (UIViewController, UIViewController, Bool, @escaping () -> Void) -> Void

public struct PresentFlow<Root: FlowComponent, Component: FlowComponent>: FlowComponent where Component.Content: UIViewControllerArrayConvertable, Root.Content: UIViewControllerConvertable {
	public let root: Root
	public let presentationStyle: UIModalPresentationStyle?
	public let transitionStyle: UIModalTransitionStyle?
	public let dismissPresented: Bool
	public let component: Component
	let present: PresentClosure
	
	public init(root: Root, presentationStyle: UIModalPresentationStyle? = nil, transitionStyle: UIModalTransitionStyle? = nil, dismissPresented: Bool = true, present: @escaping PresentClosure = { $0.present($1, animated: $2, completion: $3) }, component: Component) {
		self.root = root
		self.presentationStyle = presentationStyle
		self.transitionStyle = transitionStyle
		self.present = present
		self.dismissPresented = dismissPresented
		self.component = component
	}
	
	public func create() -> Root.Content {
		root.create()
	}
	
	public func navigate(to step: FlowStep, content: Root.Content, completion: @escaping (Bool) -> Void) {
		let parent = content.asViewController()
		let animated = step.animated && parent.view?.window != nil
		guard let i = component.asVcList.index(for: step) else {
			if root.contains(step: step) {
				parent.dismissPresented(animated: animated) {
					root.navigate(to: step, content: content, completion: completion)
				}
				return
			}
			completion(false)
			return
		}
		let vcs = component.asVcList.controllers(current: parent.allPresented, upTo: i)
		guard let vc = vcs.last, let new = component.asVcList.create(from: vcs) else {
			completion(false)
			return
		}
		update(child: vc)
		if component.canNavigate(to: step, contentAny: vc) {
			multiCompletion(
				[
					{ component.navigate(to: step, content: new, completion: $0) },
					{ c in set(vcs, to: content, animated: animated, completion: { c(true) }) }
				],
				completion: completion
			)
		} else {
			set(vcs, to: content, animated: animated) {
				component.navigate(to: step, content: new, completion: completion)
			}
		}
	}
	
	private func set(_ children: [UIViewController], to parent: Root.Content, animated: Bool, completion: @escaping () -> Void) {
		let vc = parent.asViewController()
		vc.present(children.filter { $0 !== vc }, dismiss: dismissPresented, animated: animated, presentClosure: present) {
			completion()
		}
	}
	
	private func update(child: UIViewController) {
		if let style = presentationStyle {
			child.modalPresentationStyle = style
		}
		if let style = transitionStyle {
			child.modalTransitionStyle = style
		}
	}
	
	public func contains(step: FlowStep) -> Bool {
		root.contains(step: step) || component.contains(step: step)
	}
	
	public func canNavigate(to step: FlowStep, content: Root.Content) -> Bool {
		content.asViewController().view?.window != nil &&
			(
				root.canNavigate(to: step, content: content) ||
				component.asVcList.create(from: content.asViewController().allPresented).map {
					component.canNavigate(to: step, content: $0)
				} == true
			)
	}
	
	public func current(content: Root.Content) -> (AnyPrimitiveFlow, Any)? {
		content.asViewController().allPresented.last.flatMap {
			component.asVcList.create(from: [$0])
		}.flatMap {
			component.current(content: $0)
		} ?? root.current(content: content)
	}
	
	public func currentNode(content: Root.Content) -> FlowNode? {
		content.asViewController().allPresented.last.flatMap {
			component.asVcList.node(for: $0)
		} ?? AnyHashable(root.flowId)
	}
	
	public func flow(for node: FlowNode, content: Root.Content) -> (AnyPrimitiveFlow, Any)? {
		component.asVcList.create(from: content.asViewController().allPresented).flatMap {
			component.flow(for: node, content: $0)
		} ?? (root.contains(step: .init(id: node, data: nil, options: [])) ? (root, content) : nil)
	}
}

extension PresentFlow {
	
	public init(root: Root, presentationStyle: UIModalPresentationStyle? = nil, transitionStyle: UIModalTransitionStyle? = nil, dismissPresented: Bool = true, present: @escaping PresentClosure = { $0.present($1, animated: $2, completion: $3) }, @FlowBuilder _ builder: () -> Component) {
		self = PresentFlow(root: root, presentationStyle: presentationStyle, transitionStyle: transitionStyle, dismissPresented: dismissPresented, present: present, component: builder())
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
