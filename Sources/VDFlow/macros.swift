#if swift(>=5.9)
import Foundation

@attached(member, conformances: StepsCollection, names: arbitrary)
@attached(memberAttribute)
@attached(extension, conformances: StepsCollection, names: arbitrary)
public macro Steps() = #externalMacro(module: "VDFlowMacros", type: "StepsMacro")

@attached(accessor, names: named(didSet))
public macro Step() = #externalMacro(module: "VDFlowMacros", type: "StepsMacro")
#endif
