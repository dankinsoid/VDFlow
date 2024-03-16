import SwiftUI

public extension NavigationLink {

	init<Dest: View, T, D>(
		step: StepBinding<T, D>,
		@ViewBuilder destination: () -> Dest,
		@ViewBuilder label: () -> Label
    ) where Destination == NavigationStepDestination<Dest, D>, T.AllSteps: ExpressibleByNilLiteral, T: StepsCollection {
		self.init(isActive: step.isSelected) {
            NavigationStepDestination(content: destination(), stepBinding: step.value)
		} label: {
			label()
		}
	}
}

public struct NavigationStepDestination<Content: View, Value>: View {

    let content: Content
    let stepBinding: Binding<Value>

	public var body: some View {
		content
			.stepEnvironment(stepBinding)
	}
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
public extension View {

    func navigationDestination<Root: StepsCollection, Value>(
		step: StepBinding<Root, Value>,
		@ViewBuilder destination: @escaping () -> some View
    ) -> some View where Root.AllSteps: ExpressibleByNilLiteral {
		navigationDestination(isPresented: step.isSelected) {
			destination()
				.stepEnvironment(step.value)
		}
	}
}
