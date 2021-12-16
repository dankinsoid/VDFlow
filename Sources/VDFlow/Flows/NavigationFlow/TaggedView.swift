//
//  SwiftUIView.swift
//  
//
//  Created by Данил Войдилов on 25.11.2021.
//

#if canImport(UIKit)
import SwiftUI
import UIKit

struct TaggedView<Content: View>: View, TaggedViewType {
	let content: Content
	let tag: AnyHashable
	let tags: NavigationTag
	var onChange: (VCKey.Value) -> Void = { _ in }
	
	init(_ content: Content, i: Int) {
		self.content = content
		tag = content.viewTag ?? AnyHashable(i)
		self.tags = Environment(\.tag).wrappedValue
	}
	
	var body: some View {
		content
			.transformEnvironment(\.tag) {
				$0.tags.append(tag)
			}
			.onPreferenceChange(VCKey.self) {
				onChange($0)
			}
	}
}

enum VCKey: PreferenceKey {
	static let defaultValue = Value()
	
	static func reduce(value: inout Value, nextValue: () -> Value) {
		let next = nextValue()
		value.tags += next.tags
		let create = value.create
		value.create = {
			create($0) + next.create($0)
		}
	}
	
	struct Value: Equatable {
		var count: Int { tags.count }
		var tags: [AnyHashable] = []
		var create: ([UIViewController]) -> [UIViewController] = { _ in [] }
		
		static func ==(lhs: VCKey.Value, rhs: VCKey.Value) -> Bool {
			lhs.tags == rhs.tags
		}
	}
}
#endif
