import Foundation

/// An empty step type used as a placeholder or default value in the flow navigation system.
///
/// This type is used when a step doesn't need to carry any data but still needs to be part of the navigation flow.
public struct EmptyStep: Hashable, Codable, CustomStringConvertible, Sendable {

	private var updater = false
	/// A string representation of the EmptyStep.
	public var description: String { "EmptyStep" }

	/// Creates a new empty step instance.
	public init() {}
}

public struct EmptyStepsCollection: StepsCollection {

	public var selected: AllSteps {
		get { .none }
		set {}
	}
	
	public let none = EmptyStep()
	public init() {}

	public static func step<T>(for keyPath: WritableKeyPath<Self, StepID<T>>) -> AllSteps? {
		AllSteps.none
	}

	public static func keyPath(for step: AllSteps) -> PartialKeyPath<EmptyStepsCollection> {
		\.none
	}
	
	public enum AllSteps: Codable, Hashable, Sendable, CaseIterable {

		case none
	}

	public var _lastMutateID: MutateID? { nil }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension Never: StepsCollection {
	public var _lastMutateID: MutateID? { nil }
	public var selected: Never {
		get { fatalError() }
		set {}
	}
	public static func step<T>(for keyPath: WritableKeyPath<Self, StepID<T>>) -> AllSteps? { nil }
	public static func keyPath(for step: Never) -> PartialKeyPath<Never> { }
}
