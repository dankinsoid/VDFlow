//import SwiftUI
//
//extension NavigationLink {
//	
//	public init<Dest: View, T, D>(
//    step: StepBinding<T, D>,
//    @ViewBuilder destination: () -> Dest,
//    @ViewBuilder label: () -> Label
//  ) where Destination == NavigationStepDestination<Dest, D> {
//    self.init(isActive: step.rootBinding.isSelected(step.keyPath)) {
//			NavigationStepDestination(content: destination(), stepBinding: step.binding)
//		} label: {
//			label()
//		}
//	}
//}
//
//public struct NavigationStepDestination<Content: View, Value>: View {
//	
//	public let content: Content
//	public let stepBinding: Binding<Step<Value>>
//	
//	public var body: some View {
//		content
//			.stepEnvironment(stepBinding)
//	}
//}
//
//@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
//public extension View {
//    
//    func navigationDestination<T>(
//        for step: StateStep<T>,
//        @ViewBuilder destination: @escaping (Step<T>.Key) -> some View
//    ) -> some View {
//        navigationDestination(for: Step<T>.Key.self) { key in
//            destination(key)
//        }
//    }
//    
//    func navigationDestination<Root, Value>(
//        step: StepBinding<Root, Value>,
//        @ViewBuilder destination: @escaping () -> some View
//    ) -> some View {
//        navigationDestination(isPresented: step.isSelected) {
//            destination()
//                .stepEnvironment(step.binding)
//        }
//    }
//}
//
//@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
//public extension Binding {
//    
//    func navigationPath<T>() -> Binding<NavigationPath> where Value == Step<T> {
//        Binding<NavigationPath> {
//            let allValues = wrappedValue.allKeys
//            guard let index = allValues.firstIndex(of: wrappedValue.selected) else {
//                return NavigationPath()
//            }
//            return NavigationPath(allValues.prefix(index + 1))
//        } set: {
//            let allValues = wrappedValue.allKeys
//            guard
//                !$0.isEmpty,
//                !allValues.isEmpty
//            else {
//                wrappedValue.unselect()
//                return
//            }
//            wrappedValue.selected = allValues[$0.count - 1]
//        }
//    }
//}
