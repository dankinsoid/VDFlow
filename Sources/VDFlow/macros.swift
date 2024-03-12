#if swift(>=5.9)
import Foundation

@attached(memberAttribute)
@attached(member, conformances: StepsCollection, names: arbitrary)
@attached(extension, conformances: StepsCollection, names: arbitrary)
public macro Steps() = #externalMacro(module: "VDFlowMacros", type: "StepsMacro")

@attached(accessor, names: named(didSet))
public macro StepDidSet() = #externalMacro(module: "VDFlowMacros", type: "StepsMacro")
#endif
