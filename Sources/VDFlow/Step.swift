import Foundation

extension StepsCollection {
    
    public typealias Step<Value> = StepWrapper<Self, Value>
}

@propertyWrapper
public struct StepWrapper<Parent: StepsCollection, Value>: Identifiable {

    public let id: Parent.Steps
    public var wrappedValue: Value
    public var projectedValue: Parent.Steps {
        id
    }
    
    public init(
        wrappedValue: Value,
        _ id: Parent.Steps
    ) {
        self.wrappedValue = wrappedValue
        self.id = id
    }
}

extension StepWrapper where Value == EmptyStep {
    
    public init(_ id: Parent.Steps) {
        self.init(wrappedValue: EmptyStep(), id)
    }
}

extension StepWrapper {
    
    public init<T>(_ id: Parent.Steps) where T? == Value {
        self.init(wrappedValue: nil, id)
    }
}

extension StepWrapper: Equatable where Value: Equatable {}
extension StepWrapper: Hashable where Value: Hashable {}
extension StepWrapper: Decodable where Value: Decodable {}
extension StepWrapper: Encodable where Value: Encodable {}

