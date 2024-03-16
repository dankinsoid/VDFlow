import Foundation

public protocol StepsCollection {

    associatedtype AllSteps: Hashable & Codable & Sendable
	var selected: AllSteps { get set }
    static var _mutateIDs: [AllSteps: WritableKeyPath<Self, MutateID>] { get }
    var _lastMutateID: MutateID? { get }
}

//extension Optional: CaseIterable where Wrapped: CaseIterable {
//
//    public static var allCases: [Wrapped?] {
//        [.none] + Wrapped.allCases.map { $0 }
//    }
//}
//
//extension Optional: RawRepresentable where Wrapped: RawRepresentable {
//
//    public init?(rawValue: Wrapped.RawValue?) {
//        switch rawValue {
//        case let .some(rawValue):
//            guard let wrapped = Wrapped(rawValue: rawValue) else { return nil }
//            self = .some(wrapped)
//        case .none:
//            self = .none
//        }
//    }
//
//    public var rawValue: Wrapped.RawValue? {
//        self?.rawValue
//    }
//}
