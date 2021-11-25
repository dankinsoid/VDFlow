//
//  File.swift
//  
//
//  Created by Данил Войдилов on 24.11.2021.
//

#if canImport(UIKit)
import Foundation
import UIKit
import SwiftUI
import IterableView

struct NavigationStack<Content: View, Selection: Hashable>: View {
	
	let content: [TaggedView<Content>]
	@Environment(\.tag) private var tag
	@Environment(\.navigationFlowEnvironment) private var environment
	private let parent: NavigationFlowEnvironment
	@StateOrBinding private var selection: Selection
	@State private var previous = Previous()
	
	init(_ selection: StateOrBinding<Selection>, content: [TaggedView<Content>], parent: NavigationFlowEnvironment) {
		self.content = content
		_selection = selection
		self.parent = parent
	}
	
	var body: some View {
		print(tag)
//		if !content.isEmpty {
			return (content.first(where: { $0.tag == tag }) ?? content[0])
				.onUpdate {
					print($0.tag)
					let value = Value(selected: selection, tags: content.compactMap { $0.tag.base as? Selection })
					parent.children[$0.tag] = { array in
						let visitor = ControllersVisitor(current: array, upTo: selection)
						visitor.iterate(content.dropFirst()) { array, tag in
							self.environment.children[tag]?(array) ?? []
						}
						return visitor.new
					}
					guard value != previous.value else { return }
					previous.value = value
					parent.update($0, $1)
				}
//		}
	}
	
	private struct Value: Equatable {
		var selected: Selection
		var tags: [Selection]
	}
	
	private final class Previous {
		var value: Value?
	}
}
#endif
