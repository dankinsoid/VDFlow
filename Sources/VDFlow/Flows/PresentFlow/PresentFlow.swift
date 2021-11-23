//
//  PresentFlow.swift
//  FlowStart
//
//  Created by Daniil on 05.11.2020.
//

#if canImport(UIKit)
import Foundation
import UIKit
import SwiftUI
import IterableView

public typealias PresentClosure = (UIViewController, UIViewController, Bool, @escaping () -> Void) -> Void

public struct PresentFlow<Content: IterableView, Selection: Hashable>: FullScreenUIViewControllerRepresentable {
	public let style: PresentFlowStyle?
	public let content: Content
	private let present: PresentClosure
	@StateOrBinding private var id: Selection
	
	init(_ selection: StateOrBinding<Selection>, style: PresentFlowStyle? = nil, present: @escaping PresentClosure = { $0.present($1, animated: $2, completion: $3) }, content: Content) {
		self.style = style
		self.present = present
		self.content = content
		self._id = selection
	}
	
	public init(_ selection: Binding<Selection>, style: PresentFlowStyle? = nil, @IterableViewBuilder _ builder: () -> Content) {
		self.init(.binding(selection), style: style, content: builder())
	}
	
	public static func custom(_ selection: Binding<Selection>, present: @escaping PresentClosure, @IterableViewBuilder _ builder: () -> Content) -> PresentFlow {
		self.init(.binding(selection), present: present, content: builder())
	}
	
	public func makeUIViewController(context: Context) -> PresentViewController {
		let result = PresentViewController()
		let visitor = FirstViewControllerVisitor()
		_ = content.iterate(with: visitor)
		if let first = visitor.vc as? ObservableControllerType {
			result.set([first], animated: false)
		}
		result.onDidShow = {[weak result _id] in
			let newId = ($0.anyFlowId?.base as? Selection) ?? (result?.allPresented.count as? Selection) ?? _id.wrappedValue
			if newId != _id.wrappedValue {
				_id.wrappedValue = newId
			}
		}
//		result.onAppear = update
		result.style = style
		result.presentClosure = present
		return result
	}
	
	public func updateUIViewController(_ uiViewController: PresentViewController, context: Context) {
		let visitor = ControllersVisitor(current: uiViewController.viewControllers, upTo: id)
		_ = self.content.iterate(with: visitor)
		guard visitor.index != nil else { return }
		uiViewController.set(visitor.new.compactMap { $0 as? ObservableControllerType }, animated: context.transaction.animation != nil)
	}
}

extension PresentFlow where Selection == Int {
	
	public init(style: PresentFlowStyle? = nil, @IterableViewBuilder _ builder: () -> Content) {
		self.init(.state(0), style: style, content: builder())
	}
	
	public static func custom(present: @escaping PresentClosure, @IterableViewBuilder _ builder: () -> Content) -> PresentFlow {
		self.init(.state(0), present: present, content: builder())
	}
}

public enum PresentFlowStyle {
	case native(UIModalPresentationStyle, UIModalTransitionStyle), delegate(UIViewControllerTransitioningDelegate)
}
#endif
