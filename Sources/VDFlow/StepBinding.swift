import SwiftUI

@dynamicMemberLookup
public struct StepBinding<Root, Value>: Identifiable {
    
    public var id: StepID { selected.id }
    var selected: Step<Root>.Key { rootBinding.wrappedValue.key(keyPath) }
    var getter: () -> Step<Root>
    var setter: (Step<Root>) -> Void
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

public extension StepBinding {
    
    init(
    	initial: Step<Root>,
      at keyPath: WritableKeyPath<Root, Step<Value>>
    ) {
        var value = initial
        self.init(
        	getter: {
            value
        	}, setter: {
            value = $0
        	},
        	keyPath: keyPath
        )
    }
}

extension StepBinding {
    
    var rootBinding: Binding<Step<Root>> {
        Binding {
            getter()
        } set: {
            setter($0)
        }
    }
    
    init(
    	rootBinding: Binding<Step<Root>>,
      keyPath: WritableKeyPath<Root, Step<Value>>
    ) {
        self.getter = { rootBinding.wrappedValue }
        self.setter = { rootBinding.wrappedValue = $0 }
        self.keyPath = keyPath
    }
}
