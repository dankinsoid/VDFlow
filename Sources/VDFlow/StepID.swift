import Foundation

public struct StepID: Hashable, Codable {
    
    var file: String
    var line: UInt
    var column: UInt
    
    public static let none = StepID(file: "StepID", line: #line, column: #column)
}
