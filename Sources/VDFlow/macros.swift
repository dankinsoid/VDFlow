#if swift(>=5.9)
import Foundation

/// A macro that generates required code for types that represent a collection of steps.
///
/// This macro streamlines the creation of navigation flow structures by generating
/// the necessary boilerplate code. When applied to a struct, it:
/// - Adds conformance to the `StepsCollection` protocol
/// - Generates an enum representing all possible steps
/// - Implements required methods for navigation
///
/// ```swift
/// @Steps
/// struct NavigationFlow {
///     var home
///     var profile: UserProfile = .init()
///     var settings
/// }
/// ```
@attached(member, conformances: StepsCollection, names: arbitrary)
@attached(memberAttribute)
@attached(extension, conformances: StepsCollection, names: arbitrary)
public macro Steps() = #externalMacro(module: "VDFlowMacros", type: "StepsMacro")

/// A macro that can be applied to individual properties within a steps collection.
///
/// This macro adds a didSet accessor to the property to handle navigation state changes.
@attached(accessor, names: named(didSet))
public macro Step() = #externalMacro(module: "VDFlowMacros", type: "StepsMacro")
#endif
