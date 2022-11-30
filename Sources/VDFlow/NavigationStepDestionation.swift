import SwiftUI

extension NavigationLink {
	
	public init<Dest: View, T, D>(
    step: StepBinding<T, D>,
    @ViewBuilder destination: () -> Dest,
    @ViewBuilder label: () -> Label
  ) where Destination == NavigationStepDestionation<Dest, D> {
    self.init(isActive: step.rootBinding.isSelected(step.keyPath)) {
			NavigationStepDestionation(content: destination(), stepBinding: step.binding)
		} label: {
			label()
		}
	}
}

public struct NavigationStepDestionation<Content: View, Value>: View {
	
	public let content: Content
	public let stepBinding: Binding<Step<Value>>
	
	public var body: some View {
		content
			.stepEnvironment(stepBinding)
	}
}
