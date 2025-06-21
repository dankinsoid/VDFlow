import Foundation

public extension StepsCollection {

	typealias StepID<Value> = VDFlow.StepWrapper<Self, Value>
}

/// A protocol that defines the basic requirements for a step wrapper type.
///
/// This protocol is implemented by types that wrap steps in a navigation flow.
public protocol StepWrapperType {

	/// Selects this step in the navigation flow.
	mutating func select()
}

/// A property wrapper that wraps a value associated with a step in a navigation flow.
///
/// This type is used to associate values with steps in a `StepsCollection`, enabling
/// navigation with associated data. It manages the selection state and change tracking
/// for individual steps within a flow.
///
/// ```swift
/// @Steps
/// struct NavigationFlow {
///     var home
///     var profile: UserProfile = .init() // Uses StepWrapper internally
///     var settings
/// }
///
/// var flow = NavigationFlow.home
/// flow.$profile.select(with: UserProfile(id: "123")) // Navigate with data
/// ```
@propertyWrapper
public struct StepWrapper<Parent: StepsCollection, Value>: Identifiable, StepWrapperType {

	/// The identifier for this step within the parent collection.
	public let id: Parent.AllSteps
	/// The ID used to track mutations to this step.
	private var mutateID = MutateID()
	/// The value associated with this step.
	public var wrappedValue: Value
	/// The projected value of the property wrapper, which is the wrapper itself.
	///
	/// This allows you to access the wrapper's methods through the `$` prefix syntax.
	public var projectedValue: StepWrapper {
		get { self }
		set { self = newValue }
	}

	/// Creates a new step wrapper with the given value and identifier.
	///
	/// - Parameters:
	///   - wrappedValue: The value associated with this step.
	///   - id: The identifier for this step within the parent collection.
	public init(
		wrappedValue: Value,
		_ id: Parent.AllSteps
	) {
		self.wrappedValue = wrappedValue
		self.id = id
	}

	/// Selects this step in the navigation flow.
	///
	/// Calling this method will update the mutation ID and notify observers
	/// about the selection change.
	public mutating func select() {
        StepSystem.observer.stepWillChange(to: id, in: Parent.self, with: wrappedValue)
		mutateID.update()
		StepSystem.observer.stepDidChange(to: id, in: Parent.self, with: wrappedValue)
	}

	/// Selects this step in the navigation flow and updates its associated value.
	///
	/// - Parameter value: The new value to associate with this step.
	///
	/// ```swift
	/// flow.$profile.select(with: UserProfile(id: "123"))
	/// ```
	public mutating func select(with value: Value) {
		wrappedValue = value
		select()
	}

	/// The last mutation ID for this step or any nested steps.
	///
	/// This property is used internally for tracking the most recent change in this step
	/// or any of its nested steps.
	public var _lastMutateID: (Parent.AllSteps, MutateID)? {
        let lastNested = (wrappedValue as? any StepsCollection)?._lastMutateID?.optional
        let this = mutateID.optional
        return [lastNested, this]
            .compactMap { $0 }
            .sorted { $0 > $1 }
            .map { (id, $0) }
            .first
	}

	/// The key path for this step within the parent collection.
	public var keyPath: WritableKeyPath<Parent, Value> {
		Parent.keyPath(for: id)! as! WritableKeyPath<Parent, Value>
	}
}

public extension StepWrapper where Value == EmptyStep {

	init(_ id: Parent.AllSteps) {
		self.init(wrappedValue: EmptyStep(), id)
	}
}

public extension StepWrapper {

	init<T>(_ id: Parent.AllSteps) where T? == Value {
		self.init(wrappedValue: nil, id)
	}
}

extension StepWrapper: Sendable where Value: Sendable {}
extension StepWrapper: Equatable where Value: Equatable {}
extension StepWrapper: Hashable where Value: Hashable {}
extension StepWrapper: Decodable where Value: Decodable {}
extension StepWrapper: Encodable where Value: Encodable {}
