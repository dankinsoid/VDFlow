import Foundation

public protocol StepsCollection {

    associatedtype AllSteps: Hashable & Codable & Sendable
	var selected: AllSteps { get set }
    var _selectionState: SelectionState { get set }
}
