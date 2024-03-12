import Foundation

public struct MutateID: Equatable, Hashable, Codable {

	var value: UInt64

	init() {
		value = 0
	}

	public init(from decoder: Decoder) throws {
		value = try UInt64(from: decoder)
	}

	public func encode(to encoder: Encoder) throws {
		try value.encode(to: encoder)
	}

	mutating func update() {
		value = DispatchTime.now().uptimeNanoseconds
	}

	public static func < (lhs: MutateID, rhs: MutateID) -> Bool {
		lhs.value < rhs.value
	}
}
