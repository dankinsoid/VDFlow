import Foundation

final class MutateID: Equatable, Hashable, Codable, ExpressibleByIntegerLiteral, Comparable {
    
	var value: UInt64
	
	init() {
		value = 0
	}
	
	init(integerLiteral value: UInt64) {
		self.value = value
	}
	
	required init(from decoder: Decoder) throws {
		value = try UInt64(from: decoder)
	}
	
	func encode(to encoder: Encoder) throws {
		try value.encode(to: encoder)
	}
	
	func hash(into hasher: inout Hasher) {
		value.hash(into: &hasher)
	}
	
	func update() {
		value = DispatchTime.now().uptimeNanoseconds
	}
	
	static func ==(lhs: MutateID, rhs: MutateID) -> Bool {
		lhs.value == rhs.value
	}

	static func < (lhs: MutateID, rhs: MutateID) -> Bool {
		lhs.value < rhs.value
	}
}
