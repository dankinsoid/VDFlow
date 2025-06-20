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

extension EmptyStep: StepsCollection {

	public var selected: AllSteps {
		get { .none }
		set {}
	}

	public static func step<T>(for keyPath: WritableKeyPath<EmptyStep, StepID<T>>) -> AllSteps? {
		AllSteps.none
	}

	public enum AllSteps: Codable, Hashable, Sendable, CaseIterable {

		case none
	}

	public var _lastMutateID: MutateID? { nil }
}
