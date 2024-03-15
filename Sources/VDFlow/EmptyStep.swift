import Foundation

public struct EmptyStep: Hashable, Codable, CustomStringConvertible, Sendable {

	private var updater = false
	public var description: String { "EmptyStep" }

	public init() {}
}
