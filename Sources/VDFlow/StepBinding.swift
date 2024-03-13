import SwiftUI

@dynamicMemberLookup
public struct StepBinding<Root: StepsCollection, Value> {

	@Binding var root: Root
	public var step: Root.Steps {
		root[keyPath: keyPath.appending(path: \.id)]
	}

	public var keyPath: WritableKeyPath<Root, StepWrapper<Root, Value>>

	var binding: Binding<Value> {
		$root[dynamicMember: keyPath.appending(path: \.wrappedValue)]
	}

	init(
		root: Binding<Root>,
		keyPath: WritableKeyPath<Root, StepWrapper<Root, Value>>
	) {
		self._root = root
		self.keyPath = keyPath
	}

	public var isSelected: Binding<Bool> {
		$root.isSelected(step)
	}

    public func isSelected(_ value: Value) -> Binding<Bool> {
        Binding {
            $root.isSelected(step).wrappedValue
        } set: {
            if $0 {
                $root.wrappedValue[keyPath: keyPath].wrappedValue = value
            } else {
                $root.wrappedValue.selected = nil
            }
        }
    }

    public func callAsFunction(_ value: Value) -> StepBinding {
        StepBinding(
            root: Binding {
                root
            } set: {
                var new = $0
                new[keyPath: keyPath].wrappedValue = value
                root = new
            },
            keyPath: keyPath
        )
    }
}

extension Binding where Value: StepsCollection {

    subscript<A>(dynamicMember keyPath: WritableKeyPath<Value, StepWrapper<Value, A>>) -> StepBinding<Value, A> {
        StepBinding(
            root: self,
            keyPath: keyPath
        )
    }
}

public extension StepBinding where Value: StepsCollection {

	subscript<A>(dynamicMember keyPath: WritableKeyPath<Value, StepWrapper<Value, A>>) -> StepBinding<Value, A> {
		StepBinding<Value, A>(
			root: binding,
			keyPath: keyPath
		)
	}
}
