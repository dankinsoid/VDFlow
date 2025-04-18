import Foundation

public extension StepsCollection {

	typealias StepID<Value> = VDFlow.StepWrapper<Self, Value>
}

public protocol StepWrapperType {

	mutating func select()
}

@propertyWrapper
public struct StepWrapper<Parent: StepsCollection, Value>: Identifiable, StepWrapperType {

	public let id: Parent.AllSteps
	private var mutateID = MutateID()
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
        StepSystem.observer.stepWillChange(to: id, in: Parent.self, with: wrappedValue)
		mutateID.update()
		StepSystem.observer.stepDidChange(to: id, in: Parent.self, with: wrappedValue)
	}

	public mutating func select(with value: Value) {
		wrappedValue = value
		select()
	}

	public var _lastMutateID: (Parent.AllSteps, MutateID)? {
        let lastNested = (wrappedValue as? any StepsCollection)?._lastMutateID?.optional
        let this = mutateID.optional
        return [lastNested, this]
            .compactMap { $0 }
            .sorted { $0 > $1 }
            .map { (id, $0) }
            .first
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
