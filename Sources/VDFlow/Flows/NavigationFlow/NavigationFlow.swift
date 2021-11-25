//
//  NavigationFlow.swift
//  FlowStart
//
//  Created by Daniil on 02.11.2020.
//

#if canImport(UIKit)
import Foundation
import UIKit
import SwiftUI
import IterableView

public struct NavigationFlow<Content: IterableView, Selection: Hashable>: View {
	private let content: [TaggedView<Content.Subview>]
	private let selection: StateOrBinding<Selection>
	@State private var navigationEnvironment = NavigationFlowEnvironment()
	@Environment(\.navigationFlowEnvironment) private var parentEnvironment
	@Environment(\.isInsideNavigationFlow) private var isInside
	@Environment(\.tag) private var tag
	
	public var body: some View {
		Group {
			if isInside {
				NavigationStack(selection, content: content, parent: parentEnvironment)
					.environment(\.navigationFlowEnvironment, navigationEnvironment)
			} else {
				NavigationWrapper(selection, content: content)
					.environment(\.isInsideNavigationFlow, true)
					.environment(\.navigationFlowEnvironment, navigationEnvironment)
					.edgesIgnoringSafeArea(.all)
			}
		}
	}
	
	private init(_ selection: StateOrBinding<Selection>, content: Content) {
		self.content = content.subviews.enumerated().map { TaggedView($0.element, i: $0.offset) }
		self.selection = selection
		print(self.content.map { $0.tag })
	}
	
	public init(_ selection: Binding<Selection>, content: Content) {
		self.init(.binding(selection), content: content)
	}
	
	public init(_ selection: Binding<Selection>, @IterableViewBuilder _ builder: () -> Content) {
		self.init(selection, content: builder())
	}
}

extension NavigationFlow where Selection == Int {
	
	public init(content: Content) {
		self.init(.state(0), content: content)
	}
	
	public init(@IterableViewBuilder _ builder: () -> Content) {
		self.init(content: builder())
	}
}
#endif
