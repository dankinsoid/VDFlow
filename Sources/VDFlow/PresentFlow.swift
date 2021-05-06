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

public struct PresentFlow<Content: IterableView, Selection: Hashable>: FullScreenUIViewControllerRepresentable {
	public let style: PresentFlowStyle?
	public let content: Content
	let present: PresentClosure
	private let observingId = "PresentObserve"
	@Binding private var id: Selection?
	
	init(_ selection: Binding<Selection?>, style: PresentFlowStyle? = nil, present: @escaping PresentClosure = { $0.present($1, animated: $2, completion: $3) }, content: Content) {
		self.style = style
		self.present = present
		self.content = content
		self._id = selection
	}
	
	public init(_ selection: Binding<Selection?>, style: PresentFlowStyle? = nil, @IterableViewBuilder _ builder: () -> Content) {
		self.init(selection, style: style, content: builder())
	}
	
	public static func custom(_ selection: Binding<Selection?>, present: @escaping PresentClosure, @IterableViewBuilder _ builder: () -> Content) -> PresentFlow {
		self.init(selection, present: present, content: builder())
	}
	
	public func makeUIViewController(context: Context) -> UIViewController {
		let visitor = FirstViewControllerVisitor()
		_ = content.iterate(with: visitor)
		let vc = visitor.vc ?? ObservableHostingController(rootView: EmptyView())
		_ = (vc as? ObservableControllerType)?.on(.didAppear, id: UUID()) {[weak vc] _ in
			if let content = vc {
				update(content)
			}
		}
		return vc
	}
	
	public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
		update(uiViewController)
	}
	
	private func update(_ uiViewController: UIViewController) {
		let parent = uiViewController
		print("present", parent.isBeingPresented, parent.allPresented.contains(where: { $0.isBeingPresented }))
		guard let id = self.id, parent.view?.window != nil,
					!parent.allPresented.contains(where: { $0.isBeingPresented }) else {
				//component.asVcList.idsChanged(vcs: parent.allPresented)
			return
		}
		let animated = FlowStep.isAnimated
		if uiViewController.anyFlowId == AnyHashable(id) {
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
		on(.didAppear, id: id) {[weak root] _ in
			let newId = root?.vcForPresent.flowId(of: T.self)
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

public enum PresentFlowStyle {
	case native(UIModalPresentationStyle, UIModalTransitionStyle), delegate(UIViewControllerTransitioningDelegate)
}
