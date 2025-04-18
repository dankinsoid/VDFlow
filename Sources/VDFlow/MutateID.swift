import Foundation

/// A structure that represents a unique identifier for a mutation operation.
///
/// This type is used to track changes to navigation state and determine when mutations occur.
/// It uses the system's uptime nanoseconds to create a unique, chronologically sortable identifier.
public struct MutateID: Comparable, Hashable, Codable, Sendable {

	/// The timestamp of the mutation, represented as uptime nanoseconds.
	/// 
	/// A `nil` value indicates that no mutation has occurred yet.
	var mutationDate: UInt64?

	/// Creates a new mutation ID with no timestamp.
	public init() {}

	/// Creates a mutation ID by decoding it from a decoder.
	/// 
	/// - Parameter decoder: The decoder to read data from.
	/// - Throws: An error if decoding fails.
	public init(from decoder: Decoder) throws {
		let date = try UInt64(from: decoder)
		mutationDate = date == 0 ? nil : date
	}

	/// Encodes the mutation ID to an encoder.
	/// 
	/// - Parameter encoder: The encoder to write data to.
	/// - Throws: An error if encoding fails.
	public func encode(to encoder: Encoder) throws {
		try (mutationDate ?? 0).encode(to: encoder)
	}

	/// Updates the mutation ID with the current timestamp.
	/// 
	/// This method sets the `mutationDate` to the current system uptime in nanoseconds.
	mutating func update() {
		mutationDate = DispatchTime.now().uptimeNanoseconds
	}

	/// Compares two mutation IDs chronologically.
	/// 
	/// - Parameters:
	///   - lhs: The left-hand side mutation ID.
	///   - rhs: The right-hand side mutation ID.
	/// - Returns: `true` if the left ID occurred before the right ID.
	public static func < (lhs: MutateID, rhs: MutateID) -> Bool {
		(lhs.mutationDate ?? 0) < (rhs.mutationDate ?? 0)
	}

	/// Converts this mutation ID to an optional, returning `nil` if no mutation has occurred.
	/// 
	/// - Returns: This mutation ID if it has a timestamp, otherwise `nil`.
	var optional: MutateID? {
		mutationDate.map { _ in self }
	}
}
