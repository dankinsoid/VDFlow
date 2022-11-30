import SwiftUI

@dynamicMemberLookup
public struct StepBinding<Root, Value>: Identifiable {
    
    public var id: UUID { selected.id }
    var selected: Step<Root>.Key { rootBinding.wrappedValue.key(keyPath) }
    var rootBinding: Binding<Step<Root>>
    var keyPath: WritableKeyPath<Root, Step<Value>>
    var binding: Binding<Step<Value>> { rootBinding[dynamicMember: (\Step<Root>.wrappedValue).appending(path: keyPath)] }
    
    public var isSelected: Binding<Bool> {
        rootBinding.isSelected(keyPath)
    }
    
    public subscript<A>(dynamicMember keyPath: WritableKeyPath<Value, Step<A>>) -> StepBinding<Value, A> {
        StepBinding<Value, A>(
            rootBinding: binding,
            keyPath: keyPath
        )
    }
}
