//
//  File.swift
//  
//
//  Created by Данил Войдилов on 22.11.2021.
//

import Foundation

public struct StepAction<Root>: Identifiable, CustomStringConvertible {
	public var id: PartialKeyPath<Step<Root>>
	public var description: String { "\(id)" }
	private(set) var set: (inout Step<Root>) -> Void
	
	public init<T>(_ keyPath: WritableKeyPath<Step<Root>, Step<T>>, value: T) {
		self.id = keyPath
		set = {
			$0[keyPath: keyPath].wrappedValue = value
		}
	}
	
	public init<T>(_ keyPath: WritableKeyPath<Step<Root>, Step<T>>) {
		self.id = keyPath
		set = {
			$0[keyPath: keyPath].select()
		}
	}
}

public func ~=<Base, T>(lhs: WritableKeyPath<Step<Base>, Step<T>>, rhs: StepAction<Base>) -> Bool {
	rhs.id == lhs
}
