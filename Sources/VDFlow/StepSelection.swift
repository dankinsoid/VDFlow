import Foundation

@dynamicMemberLookup
public struct StepSelection<Parent: StepsCollection, Value>: Identifiable {
    
    public var parent: Parent
    public var value: Value {
        get { parent[keyPath: keyPath].wrappedValue }
        set { parent[keyPath: keyPath].wrappedValue = newValue }
    }
    public var id: Parent.AllSteps { parent[keyPath: keyPath].id }

    let keyPath: WritableKeyPath<Parent, StepWrapper<Parent, Value>>
    var wrapper: StepWrapper<Parent, Value> {
        get { parent[keyPath: keyPath] }
        set { parent[keyPath: keyPath] = newValue }
    }
    
    @_disfavoredOverload
    public var isSelected: Bool {
        parent.selected == parent[keyPath: keyPath].id
    }
    
    public mutating func select() {
        parent[keyPath: keyPath].select()
    }
    
    public mutating func select(with value: Value) {
        parent[keyPath: keyPath].select(with: value)
    }
}

extension StepSelection where Parent.AllSteps: ExpressibleByNilLiteral {
    
    public var isSelected: Bool {
        get { parent.selected == parent[keyPath: keyPath].id }
        set { parent.selected = newValue ? parent[keyPath: keyPath].id : nil }
    }
    
    public mutating func deselect() {
        parent.selected = nil
    }
}

extension StepSelection where Value: StepsCollection {

    public subscript<T>(dynamicMember keyPath: WritableKeyPath<Value, StepWrapper<Value, T>>) -> StepSelection<Value, T> {
        get { StepSelection<Value, T>(parent: value, keyPath: keyPath) }
        set { value = newValue.parent }
    }
}

extension StepsCollection {
    
    public subscript<Value>(_ keyPath: WritableKeyPath<Self, StepWrapper<Self, Value>>) -> StepSelection<Self, Value> {
        get { StepSelection(parent: self, keyPath: keyPath) }
        set { self = newValue.parent }
    }
}
