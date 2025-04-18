import Foundation

/// A protocol for types that observe changes to navigation steps.
///
/// Implement this protocol to receive notifications when steps are selected or changed.
///
/// - Warning: These methods are called synchronously during navigation changes.
///   Avoid performing heavy or long-running tasks as they will block the UI.
///   Consider dispatching any intensive work to a background queue.
public protocol StepsObserver: Sendable {

	/// Called just before a step selection changes.
	///
	/// - Parameters:
	///   - newValue: The step that will be selected.
	///   - type: The type of the parent collection.
	///   - value: The value associated with the step.
	func stepWillChange<Parent: StepsCollection, Value>(to newValue: Parent.AllSteps, in type: Parent.Type, with value: Value)

    /// Called after a step selection has changed.
    ///
    /// - Parameters:
    ///   - newValue: The step that was selected.
    ///   - type: The type of the parent collection.
    ///   - value: The value associated with the step.
    func stepDidChange<Parent: StepsCollection, Value>(to newValue: Parent.AllSteps, in type: Parent.Type, with value: Value)
}

/// A default implementation of the `StepsObserver` protocol that does nothing.
///
/// Use this as a default observer when no custom observation is needed.
public struct NoopStepsObserver: StepsObserver {

    public init() {}

    public func stepWillChange<Parent: StepsCollection, Value>(to newValue: Parent.AllSteps, in type: Parent.Type, with value: Value) {}
	public func stepDidChange<Parent: StepsCollection, Value>(to newValue: Parent.AllSteps, in type: Parent.Type, with value: Value) {}
}

/// A singleton system that manages step change observations throughout the application.
///
/// This enum provides a central point for registering observers of step changes.
public enum StepSystem {

	/// The current observer for step changes.
	///
	/// Set this property to register a custom observer for step changes app-wide.
	public static var observer: StepsObserver {
		get { lock.withLock { _observer } }
		set { lock.withLock { _observer = newValue } }
	}
	private static let lock = NSRecursiveLock()
	private static var _observer: StepsObserver = NoopStepsObserver()
}
