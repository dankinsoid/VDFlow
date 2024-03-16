import Foundation

public struct SelectionState: Hashable, Codable, Sendable {

    private(set) public var isSelected = false
    private(set) public var needUpdate = false
    
    public init() {}

    public mutating func select(needUpdate: Bool) {
        isSelected = true
        self.needUpdate = needUpdate
    }

    public mutating func deselect(needUpdate: Bool) {
        isSelected = false
        self.needUpdate = needUpdate
    }
    
    public mutating func reset() {
        needUpdate = false
    }
}
