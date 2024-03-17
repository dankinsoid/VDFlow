import Foundation

public struct MutateID: Comparable, Hashable, Codable, Sendable {

    var mutationDate: UInt64?

    public init() {
	}
    
    public init(from decoder: Decoder) throws {
        let date = try UInt64(from: decoder)
        mutationDate = date == 0 ? nil : date
    }

    public func encode(to encoder: Encoder) throws {
        try (mutationDate ?? 0).encode(to: encoder)
    }

	public mutating func _update() {
        mutationDate = DispatchTime.now().uptimeNanoseconds
	}

	public static func < (lhs: MutateID, rhs: MutateID) -> Bool {
		(lhs.mutationDate ?? 0) < (rhs.mutationDate ?? 0)
	}
    
    var optional: MutateID? {
        mutationDate.map { _ in self }
    }
}
