import Foundation

public protocol StepsCollection where Steps.RawValue == String {

	associatedtype Steps: RawRepresentable & CaseIterable & Hashable & Codable & Sendable
	var selected: Steps { get set }
}

public protocol OptionalStep: ExpressibleByNilLiteral {
    
    static var none: Self { get }
}

extension OptionalStep {
    
    public init(nilLiteral: ()) {
        self = .none
    }
}
