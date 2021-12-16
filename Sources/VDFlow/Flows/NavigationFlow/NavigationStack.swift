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


struct NavigationStack<Content: View, Selection: Hashable>: View, NavigationStackView {
	
	let content: [TaggedView<Content>]
	@Environment(\.tag) private var tag
	@Environment(\.navigationFlowEnvironment) private var navigationEnvironment
	private let parent: NavigationFlowEnvironment
	@StateOrBinding private var selection: Selection
	@State private var previous = Previous()
	
	init(_ selection: StateOrBinding<Selection>, content: [TaggedView<Content>], parent: NavigationFlowEnvironment) {
		self.content = content
		_selection = selection
		self.parent = parent
	}
	
	var body: some View {
		if #available(iOS 15.0, *) {
			Self._printChanges()
		}
		print(tag)
		//		if !content.isEmpty {
		return content[0]
			.onUpdate(action: navigationStackUpdate)
			.preference(
				key: VCKey.self,
				value: .init(
					tags: content.dropFirst().map { $0.tag },
					create: {  array in
						let visitor = ControllersVisitor(current: array, upTo: selection)
						visitor.iterate(content.dropFirst()) { array, tag in
							[]
						}
						return visitor.new
					}
				)
			)
		//		}
	}
	
	func navigationStackUpdate(environment: EnvironmentValues, transaction: Transaction) {
		print("onUpdate", environment.tag)
		let value = Value(selected: selection, tags: content.compactMap { $0.tag.base as? Selection })
		parent.children[environment.tag] = { array in
			let visitor = ControllersVisitor(current: array, upTo: selection)
			visitor.iterate(content.dropFirst()) { array, tag in
				navigationEnvironment.children[tag]?(array) ?? []
			}
			return visitor.new
		}
		let tags = environment.tag
		parent.didShow[tags] = {
			if let id = $0.base as? Selection, id != selection {
				selection = id
			}
			navigationEnvironment.didShow[tags]?($0)
		}
		guard value != previous.value else { return }
		previous.value = value
		parent.update(environment, transaction)
	}
	
	private struct Value: Equatable {
		var selected: Selection
		var tags: [Selection]
	}
	
	private final class Previous {
		var value: Value?
	}
}

protocol NavigationStackView {
	func navigationStackUpdate(environment: EnvironmentValues, transaction: Transaction)
}

extension View {
	func navigationStackUpdate(environment: EnvironmentValues, transaction: Transaction) {
		if let it = self as? NavigationStackView {
			it.navigationStackUpdate(environment: environment, transaction: transaction)
		} else if Body.self != Never.self {
			body.navigationStackUpdate(environment: environment, transaction: transaction)
		}
	}
}
#endif
