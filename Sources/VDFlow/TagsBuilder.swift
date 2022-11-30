import Foundation

extension Step {
	
	@resultBuilder
	public enum TagsBuilder {
		
		@inlinable
		public static func buildBlock(_ components: [(Step) -> Key]...) -> [(Step) -> Key] {
			Array(components.joined())
		}
		
		@inlinable
		public static func buildArray(_ components: [[(Step) -> Key]]) -> [(Step) -> Key] {
			Array(components.joined())
		}
		
		@inlinable
		public static func buildEither(first component: [(Step) -> Key]) -> [(Step) -> Key] {
			component
		}
		
		@inlinable
		public static func buildEither(second component: [(Step) -> Key]) -> [(Step) -> Key] {
			component
		}
		
		@inlinable
		public static func buildOptional(_ component: [(Step) -> Key]?) -> [(Step) -> Key] {
			component ?? []
		}
		
		@inlinable
		public static func buildLimitedAvailability(_ component: [(Step) -> Key]) -> [(Step) -> Key] {
			component
		}
		
		@inlinable
		public static func buildExpression(_ expression: Key) -> [(Step) -> Key] {
			[{ _ in expression }]
		}
		
		@inlinable
		public static func buildExpression<T>(_ expression: WritableKeyPath<Base, Step<T>>) -> [(Step) -> Key] {
			[{ $0.key(expression) }]
		}
	}
}
