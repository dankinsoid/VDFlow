//
//  File.swift
//  
//
//  Created by Данил Войдилов on 14.11.2021.
//

import Foundation

protocol StepProtocol {
	var stepID: UUID { get }
	var mutateID: UInt64 { get set }
}

extension UUID { static let none = UUID() }

protocol StepCollection {
	var elements: [StepProtocol] { get }
}

extension Array: StepCollection { var elements: [StepProtocol] { compactMap { $0 as? StepProtocol } } }
extension Dictionary: StepCollection { var elements: [StepProtocol] { values.compactMap { $0 as? StepProtocol } } }
extension Set: StepCollection { var elements: [StepProtocol] { compactMap { $0 as? StepProtocol } } }
extension ContiguousArray: StepCollection { var elements: [StepProtocol] { compactMap { $0 as? StepProtocol } } }
extension Optional: StepCollection where Wrapped: StepCollection { var elements: [StepProtocol] { self?.elements ?? [] } }
