import Foundation

public extension StepsCollection {

	typealias StepID<Value> = VDFlow.StepWrapper<Self, Value>
}

@propertyWrapper
public struct StepWrapper<Parent: StepsCollection, Value>: Identifiable {

    public let id: Parent.AllSteps
    public var wrappedValue: Value {
        didSet {
            print("didSet \(id)")
            if
                var newCollection = wrappedValue as? any StepsCollection,
                newCollection._selectionState.needUpdate
            {
                print("didSet \(id) and update \(Parent.self)")
                _selectionState = newCollection._selectionState
                newCollection._selectionState.reset()
                if let value = newCollection as? Value {
                    wrappedValue = value
                }
            }
        }
    }
    @_disfavoredOverload
    public var isSelected: Bool { _selectionState.isSelected }
    public var _selectionState = SelectionState()

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
        _selectionState.select(needUpdate: true)
    }

    public mutating func select(with value: Value) {
        wrappedValue = value
        select()
    }
}

public extension StepWrapper where Parent.AllSteps: ExpressibleByNilLiteral {

    var isSelected: Bool {
        get { _selectionState.isSelected }
        set { 
            if newValue {
                select()
            } else {
                deselect()
            }
        }
    }

    mutating func deselect() {
        _selectionState.deselect(needUpdate: true)
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
