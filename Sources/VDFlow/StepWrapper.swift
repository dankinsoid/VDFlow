import Foundation

public extension StepsCollection {

	typealias StepID<Value> = VDFlow.StepWrapper<Self, Value>
}

@propertyWrapper
public struct StepWrapper<Parent: StepsCollection, Value>: Identifiable {

	public let id: Parent.Steps
	public var wrappedValue: Value
	public var projectedValue: StepWrapper {
		get { self }
		set { self = newValue }
	}

	public init(
		wrappedValue: Value,
		_ id: Parent.Steps
	) {
		self.wrappedValue = wrappedValue
		self.id = id
	}
}

public extension StepWrapper where Value == EmptyStep {

	init(_ id: Parent.Steps) {
		self.init(wrappedValue: EmptyStep(), id)
	}
}

public extension StepWrapper {

	init<T>(_ id: Parent.Steps) where T? == Value {
		self.init(wrappedValue: nil, id)
	}
}

extension StepWrapper: Sendable where Value: Sendable {}
extension StepWrapper: Equatable where Value: Equatable {}
extension StepWrapper: Hashable where Value: Hashable {}
extension StepWrapper: Decodable where Value: Decodable {}
extension StepWrapper: Encodable where Value: Encodable {}
