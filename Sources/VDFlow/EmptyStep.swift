import Foundation

public struct EmptyStep: Hashable, Codable, CustomStringConvertible {

	private var updater = false
	public var description: String { "EmptyStep" }

	public init() {}

	public mutating func select() {
		updater.toggle()
	}
}
