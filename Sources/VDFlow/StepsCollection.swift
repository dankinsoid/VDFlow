import Foundation

public protocol StepsCollection {

	associatedtype AllSteps: Hashable & Codable & Sendable
	var selected: AllSteps { get set }
	var _lastMutateID: MutateID? { get }
}

extension StepsCollection {

    public func isSelected<T>(_ step: WritableKeyPath<Self, StepID<T>>) -> Bool {
        selected == self[keyPath: step].id
    }

    public mutating func select<T>(_ step: WritableKeyPath<Self, StepID<T>>) {
        self[keyPath: step].select()
    }

    public mutating func select<T>(_ step: WritableKeyPath<Self, StepID<T>>, with value: T) {
        self[keyPath: step].select(with: value)
    }
}
