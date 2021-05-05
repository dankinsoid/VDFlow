//
//  PresentFlow.swift
//  FlowStart
//
//  Created by Daniil on 05.11.2020.
//

import Foundation
import UIKit
import SwiftUI
import VDKit

public typealias PresentClosure = (UIViewController, UIViewController, Bool, @escaping () -> Void) -> Void

public struct PresentFlow<Root: FlowComponent, Component: FlowComponent, Selection: Hashable>: FlowComponent, FullScreenUIViewControllerRepresentable where Component.Content: UIViewControllerArrayConvertable, Root.Content: UIViewControllerConvertable {
	public let root: Root
	public let style: PresentFlowStyle?
	public let component: Component
	let present: PresentClosure
	public var flowId: Root.ID { root.flowId }
	@Binding private var id: Selection?
	
	public init(root: Root, selection: Binding<Selection?>, style: PresentFlowStyle? = nil, present: @escaping PresentClosure = { $0.present($1, animated: $2, completion: $3) }, component: Component) {
		self.root = root
		self.style = style
		self.present = present
		self.component = component
		self._id = selection
	}
	
	public init(root: Root, selection: Binding<Selection?>, style: PresentFlowStyle? = nil, present: @escaping PresentClosure = { $0.present($1, animated: $2, completion: $3) }, @FlowBuilder _ builder: () -> Component) {
		self = PresentFlow(root: root, selection: selection, style: style, present: present, component: builder())
	}
	
	public func create() -> Root.Content {
		let result = root.create()
		let vc = result.asViewController()
		vc.on {[weak vc] in
			if let content = vc {
				update(content)
			}
		} disappear: {
		}
		return result
	}
	
	public func makeUIViewController(context: Context) -> UIViewController {
		create().asViewController()
	}
	
	public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
		update(uiViewController)
	}
	
	public func update(content: Root.Content, data: Void?) {
		update(content.asViewController())
	}
	
	private func update(_ uiViewController: UIViewController) {
		print("present", id)
		let parent = uiViewController
		guard let id = self.id, parent.view?.window != nil else {
				//component.asVcList.idsChanged(vcs: parent.allPresented)
			return
		}
		let animated = FlowStep.isAnimated
		guard let i = component.asVcList.index(for: id) else {
			if AnyHashable(root.flowId) == AnyHashable(id) {
				parent.dismissPresented(animated: animated) { }
				return
			}
			return
		}
		let vcs = component.asVcList.controllers(current: parent.allPresented, upTo: i)
//		if let new = component.asVcList.create(from: vcs) {
//			component.update(content: new, data: nil)
//		}
		vcs.forEach { $0.on(appear: {}, disappear: {}) }
		if let vc = vcs.last {
			update(child: vc)
		}
		set(vcs, to: parent, animated: animated) {
			vcs.forEach { $0.setIdOnAppear(_id, root: parent) }
		}
	}
	
	private func set(_ children: [UIViewController], to parent: UIViewController, animated: Bool, completion: @escaping () -> Void) {
		parent.present(children.filter { $0 !== parent }, dismiss: true, animated: animated, presentClosure: present) {
			completion()
		}
	}
	
	private func update(child: UIViewController) {
		switch style {
		case .native(let presentation, let transition):
			child.modalPresentationStyle = presentation
			child.modalTransitionStyle = transition
		case .delegate(let delegate):
			child.transitioningDelegate = delegate
		case .none:
			break
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

private extension UIViewController {
	
	private var appearDelegate: AppearDelegate? {
		get { objc_getAssociatedObject(self, &strongDelegateKey) as? AppearDelegate }
		set {
			objc_setAssociatedObject(self, &strongDelegateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
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

fileprivate var strongDelegateKey = "strongDelegateKey"

private final class AppearDelegate {
	var appear: () -> Void
	var disappear: () -> Void
	
	init(_ appear: @escaping () -> Void, _ disappear: @escaping () -> Void) {
		self.appear = appear
		self.disappear = disappear
	}
}

extension FlowComponent where Content: UIViewControllerConvertable {
	
	public func present<Component: FlowComponent, Selection: Hashable>(selection: Binding<Selection?>, style: PresentFlowStyle? = nil, @FlowBuilder _ builder: () -> Component) -> PresentFlow<Self, Component, Selection> where Component.Content: UIViewControllerArrayConvertable {
		PresentFlow(root: self, selection: selection, style: style, component: builder())
	}
	
	public func customPresent<Component: FlowComponent, Selection: Hashable>(selection: Binding<Selection?>, present: @escaping PresentClosure, @FlowBuilder _ builder: () -> Component) -> PresentFlow<Self, Component, Selection> where Component.Content: UIViewControllerArrayConvertable {
		PresentFlow(root: self, selection: selection, present: present, component: builder())
	}
}

public enum PresentFlowStyle {
	case native(UIModalPresentationStyle, UIModalTransitionStyle), delegate(UIViewControllerTransitioningDelegate)
}
