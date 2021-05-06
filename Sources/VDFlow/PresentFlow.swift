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

public struct PresentFlow<Root: View, Content: IterableView, Selection: Hashable>: FullScreenUIViewControllerRepresentable {
	public let root: Root
	public let style: PresentFlowStyle?
	public let content: Content
	let present: PresentClosure
	private let observingId = "PresentObserve"
	@Binding private var id: Selection?
	
	public init(root: Root, selection: Binding<Selection?>, style: PresentFlowStyle? = nil, present: @escaping PresentClosure = { $0.present($1, animated: $2, completion: $3) }, content: Content) {
		self.root = root
		self.style = style
		self.present = present
		self.content = content
		self._id = selection
	}
	
	public init(root: Root, selection: Binding<Selection?>, style: PresentFlowStyle? = nil, present: @escaping PresentClosure = { $0.present($1, animated: $2, completion: $3) }, @IterableViewBuilder _ builder: () -> Content) {
		self.init(root: root, selection: selection, style: style, present: present, content: builder())
	}
	
	public func create() -> ObservableHostingController<Root> {
		let vc = ObservableHostingController(rootView: root)
		vc.on(.didAppear) {[weak vc] in
			if let content = vc {
				update(content)
			}
		}
		return vc
	}
	
	public func makeUIViewController(context: Context) -> ObservableHostingController<Root> {
		create()
	}
	
	public func updateUIViewController(_ uiViewController: ObservableHostingController<Root>, context: Context) {
		update(uiViewController)
	}
	
	private func update(_ uiViewController: ObservableHostingController<Root>) {
		print("present", id)
		let parent = uiViewController
		guard let id = self.id, parent.view?.window != nil else {
				//component.asVcList.idsChanged(vcs: parent.allPresented)
			return
		}
		let animated = FlowStep.isAnimated
		if root.viewTag == AnyHashable(id) {
			parent.dismissPresented(animated: animated) {}
			return
		}
		let visitor = ControllersVisitor(current: parent.allPresented, upTo: id)
		_ = self.content.iterate(with: visitor)
		guard visitor.index != nil else { return }
		
		let vcs = visitor.new
		vcs.forEach {
			($0 as? ObservableControllerType)?.cancel(observer: observingId, on: .didAppear)
			($0 as? ObservableControllerType)?.cancel(observer: observingId, on: .didDisappear)
		}
		if let vc = vcs.last {
			update(child: vc)
		}
		set(vcs, to: parent, animated: animated) {
			vcs.forEach { ($0 as? ObservableControllerType)?.setIdOnAppear(_id, id: observingId, root: parent) }
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

private extension ObservableControllerType {
	
	func setIdOnAppear<T: Hashable>(_ binding: Binding<T?>, id: AnyHashable, root: UIViewController) {
		on(.didAppear, id: id) {[weak self] _ in
			let newId = self?.flowId(of: T.self)
			if newId != binding.wrappedValue {
				binding.wrappedValue = newId
			}
		}
		on(.didDisappear, id: id) {[weak root] _ in
			let newId = root?.vcForPresent.flowId(of: T.self)
			if newId != binding.wrappedValue {
				binding.wrappedValue = newId
			}
		}
	}
}

extension View {
	
	public func present<Content: IterableView, Selection: Hashable>(selection: Binding<Selection?>, style: PresentFlowStyle? = nil, @IterableViewBuilder _ builder: () -> Content) -> PresentFlow<Self, Content, Selection> {
		PresentFlow(root: self, selection: selection, style: style, content: builder())
	}
	
	public func customPresent<Content: IterableView, Selection: Hashable>(selection: Binding<Selection?>, present: @escaping PresentClosure, @IterableViewBuilder _ builder: () -> Content) -> PresentFlow<Self, Content, Selection> {
		PresentFlow(root: self, selection: selection, present: present, content: builder())
	}
}

public enum PresentFlowStyle {
	case native(UIModalPresentationStyle, UIModalTransitionStyle), delegate(UIViewControllerTransitioningDelegate)
}
