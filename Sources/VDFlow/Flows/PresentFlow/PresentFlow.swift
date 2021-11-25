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

public struct PresentFlow<Content: IterableView, Selection: Hashable>: FullScreenUIViewControllerRepresentable {
	public let content: Content
	@Environment(\.presentFlow.presentController) private var present
	@Environment(\.presentFlow.style) private var style
	@StateOrBinding private var id: Selection
	
	init(_ selection: StateOrBinding<Selection>, content: Content) {
		self.content = content
		self._id = selection
	}
	
	public init(_ selection: Binding<Selection>, @IterableViewBuilder _ builder: () -> Content) {
		self.init(.binding(selection), content: builder())
	}
	
	public func makeUIViewController(context: Context) -> PresentViewController {
		let result = PresentViewController()
		let visitor = FirstViewControllerVisitor()
		_ = content.iterate(with: visitor)
		if let first = visitor.vc as? ObservableControllerType {
			result.set([first], animated: false)
		}
		result.onDidShow = {[weak result, _id] in
			let newId = $0.flowId(of: Selection.self) ?? (result?.allPresented.count as? Selection) ?? _id.wrappedValue
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
	
	public init(@IterableViewBuilder _ builder: () -> Content) {
		self.init(.state(0), content: builder())
	}
}
#endif
