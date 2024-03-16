import Foundation

public extension StepsCollection {

	typealias StepID<Value> = VDFlow.StepWrapper<Self, Value>
}

@propertyWrapper
public struct StepWrapper<Parent: StepsCollection, Value>: Identifiable {

    public let id: Parent.AllSteps
    public var _mutateID = MutateID()
	public var wrappedValue: Value
	public var projectedValue: StepWrapper {
		get { self }
		set { self = newValue }
	}

	public init(
		wrappedValue: Value,
		_ id: Parent.AllSteps
	) {
		self.wrappedValue = wrappedValue
		self.id = id
	}

    public mutating func select() {
        _mutateID._update()
    }

    public mutating func deselect() {
        _mutateID.mutationDate = nil
    }

    public mutating func select(with value: Value) {
        wrappedValue = value
        select()
    }

    public var _lastMutateID: (Parent.AllSteps, MutateID)? {
        ((wrappedValue as? any StepsCollection)?._lastMutateID?.optional ?? _mutateID.optional).map { (id, $0) }
    }
}

public extension StepWrapper where Value == EmptyStep {

	init(_ id: Parent.AllSteps) {
		self.init(wrappedValue: EmptyStep(), id)
	}
}

public extension StepWrapper {

	init<T>(_ id: Parent.AllSteps) where T? == Value {
		self.init(wrappedValue: nil, id)
	}
}

extension StepWrapper: Sendable where Value: Sendable {}
extension StepWrapper: Equatable where Value: Equatable {}
extension StepWrapper: Hashable where Value: Hashable {}
extension StepWrapper: Decodable where Value: Decodable {}
extension StepWrapper: Encodable where Value: Encodable {}
