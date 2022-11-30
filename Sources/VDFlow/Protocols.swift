import Foundation

protocol StepProtocol {
    
	var stepID: UUID { get }
	var mutateID: MutateID { get }
	var noneSelectedId: MutateID { get }
	var children: [StepProtocol] { get }
}

extension StepProtocol {
    
	var allChildren: [StepProtocol] {
		children.flatMap {
			[$0] + $0.children
		}
	}
}

extension UUID {
    
    static let none = UUID()
}
