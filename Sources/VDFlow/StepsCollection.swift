import Foundation

public protocol StepsCollection where Steps.RawValue == String {

	associatedtype Steps: RawRepresentable & CaseIterable & Hashable & Codable & Sendable
	var selected: Steps? { get set }
}

public extension StepsCollection {

	@discardableResult
	mutating func move(_ offset: Int = 1) -> Bool {
		let steps = Steps.allCases
		guard
			let selected,
			let i = steps.firstIndex(of: selected),
			steps.indices.contains(steps.index(i, offsetBy: offset))
		else {
			return false
		}
		self.selected = steps[steps.index(i, offsetBy: offset)]
		return true
	}
}
