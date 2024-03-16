import SwiftUI

public typealias StepBinding<Root: StepsCollection, Value> = Binding<StepSelection<Root, Value>>

//extension StepBinding {
//
//    public func callAsFunction(_ value: Value) -> Self {
//        Binding {
//            wrappedValue
//        } set: {
//            var new = $0
//            new.value = value
//            wrappedValue.va = new
//        }
//    }
//}

//extension StepBinding where Root.AllSteps: ExpressibleByNilLiteral {
//
//    public func isSelected(_ value: Value) -> Binding<Bool> {
//        Binding {
//            wrappedValue.isSelected
//        } set: {
//            if $0 {
//                $root.wrappedValue[keyPath: keyPath].wrappedValue = value
//            } else {
//                $root.wrappedValue.selected = nil
//            }
//        }
//    }
//}
