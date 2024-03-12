import SwiftUI

public extension NavigationLink {

	init<Dest: View, T, D>(
		step: StepBinding<T, D>,
		@ViewBuilder destination: () -> Dest,
		@ViewBuilder label: () -> Label
	) where Destination == NavigationStepDestination<Dest, D> {
		self.init(isActive: step.isSelected) {
			NavigationStepDestination(content: destination(), stepBinding: step.binding)
		} label: {
			label()
		}
	}
}

public struct NavigationStepDestination<Content: View, Value>: View {

	public let content: Content
	public let stepBinding: Binding<Value>

	public var body: some View {
		content
			.stepEnvironment(stepBinding)
	}
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
public extension View {

	func navigationDestination<T: StepsCollection>(
		for step: StateStep<T>,
		@ViewBuilder destination: @escaping (T.Steps) -> some View
	) -> some View {
		navigationDestination(for: T.Steps.self) { key in
			destination(key)
		}
	}

	func navigationDestination<Root, Value>(
		step: StepBinding<Root, Value>,
		@ViewBuilder destination: @escaping () -> some View
	) -> some View {
		navigationDestination(isPresented: step.isSelected) {
			destination()
				.stepEnvironment(step.binding)
		}
	}
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
public extension StepsCollection {

	var navigationPath: NavigationPath {
		get {
			let allValues = Steps.allCases
			guard let selected, let index = allValues.firstIndex(of: selected) else {
				return NavigationPath()
			}
			return NavigationPath(allValues.prefix(through: index))
		}
		set {
			let allValues = Steps.allCases
			guard
				!newValue.isEmpty,
				!allValues.isEmpty
			else {
				selected = nil
				return
			}
			selected = allValues[allValues.index(allValues.startIndex, offsetBy: newValue.count - 1)]
		}
	}
}
