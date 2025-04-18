import Foundation

public protocol StepsObserver: Sendable {

	func stepWillChange<Parent: StepsCollection, Value>(to newValue: Parent.AllSteps, in type: Parent.Type, with value: Value)
    func stepDidChange<Parent: StepsCollection, Value>(to newValue: Parent.AllSteps, in type: Parent.Type, with value: Value)
}

public struct NoopStepsObserver: StepsObserver {

    public init() {}

    public func stepWillChange<Parent: StepsCollection, Value>(to newValue: Parent.AllSteps, in type: Parent.Type, with value: Value) {}
	public func stepDidChange<Parent: StepsCollection, Value>(to newValue: Parent.AllSteps, in type: Parent.Type, with value: Value) {}
}

public enum StepSystem {

	public static var observer: StepsObserver {
		get { lock.withLock { _observer } }
		set { lock.withLock { _observer = newValue } }
	}
	private static let lock = NSRecursiveLock()
	private static var _observer: StepsObserver = NoopStepsObserver()
}
