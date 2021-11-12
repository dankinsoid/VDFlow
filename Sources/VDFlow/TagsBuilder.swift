//
//  File.swift
//  
//
//  Created by Данил Войдилов on 12.11.2021.
//

import Foundation
import UniformTypeIdentifiers

extension Step {
	
	@resultBuilder
	public struct TagsBuilder {
		
		@inlinable
		public static func buildBlock(_ components: [(Step) -> Selected]...) -> [(Step) -> Selected] {
			Array(components.joined())
		}
		
		@inlinable
		public static func buildArray(_ components: [[(Step) -> Selected]]) -> [(Step) -> Selected] {
			Array(components.joined())
		}
		
		@inlinable
		public static func buildEither(first component: [(Step) -> Selected]) -> [(Step) -> Selected] {
			component
		}
		
		@inlinable
		public static func buildEither(second component: [(Step) -> Selected]) -> [(Step) -> Selected] {
			component
		}
		
		@inlinable
		public static func buildOptional(_ component: [(Step) -> Selected]?) -> [(Step) -> Selected] {
			component ?? []
		}
		
		@inlinable
		public static func buildLimitedAvailability(_ component: [(Step) -> Selected]) -> [(Step) -> Selected] {
			component
		}
		
		@inlinable
		public static func buildExpression(_ expression: Selected) -> [(Step) -> Selected] {
			[{ _ in expression }]
		}
		
		@inlinable
		public static func buildExpression<T>(_ expression: WritableKeyPath<Base, Step<T>>) -> [(Step) -> Selected] {
			[{ $0.tag(expression) }]
		}
	}
}
