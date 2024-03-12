//import SwiftUI
//
//@dynamicMemberLookup
//public struct StepBinding<Root: StepsCollection, Value> {
//
//    var selected: Root.Steps? { rootBinding.wrappedValue.selected }
//    var getter: () -> Root.Step<Value>
//    var setter: (Root.Step<Value>) -> Void
//    var keyPath: WritableKeyPath<Root, Root.Step<Value>>
//    var binding: Binding<Root.Step<Value>> {
//        rootBinding[dynamicMember: (\Step<Root>.wrappedValue).appending(path: keyPath)]
//    }
//
//    public var isSelected: Binding<Bool> {
//        rootBinding.isSelected(keyPath)
//    }
//
//    public subscript<A: StepsCollection>(dynamicMember keyPath: WritableKeyPath<Root, Step<A>>) -> StepBinding<A> {
//        StepBinding<A>(
//            rootBinding: binding,
//            keyPath: keyPath
//        )
//    }
//}
//
//public extension StepBinding {
//    
//    init(
//        initial: Step<Root>,
//        at keyPath: WritableKeyPath<Root, Step<Value>>
//    ) {
//        var value = initial
//        self.init(
//            getter: {
//                value
//            }, setter: {
//                value = $0
//            },
//            keyPath: keyPath
//        )
//    }
//}
//
//extension StepBinding {
//    
//    var rootBinding: Binding<Step<Root>> {
//        Binding {
//            getter()
//        } set: {
//            setter($0)
//        }
//    }
//    
//    init(
//        rootBinding: Binding<Step<Root>>,
//        keyPath: WritableKeyPath<Root, Step<Value>>
//    ) {
//        self.getter = { rootBinding.wrappedValue }
//        self.setter = { rootBinding.wrappedValue = $0 }
//        self.keyPath = keyPath
//    }
//}
