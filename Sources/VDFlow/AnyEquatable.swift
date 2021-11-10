//
//  File.swift
//  
//
//  Created by Данил Войдилов on 10.11.2021.
//

import Foundation

struct AnyEquatable: Equatable {
	var base: Any
	private var compareWith: (Any, Any) -> Bool
	
	init<E: Equatable>(_ value: E) {
		base = value
		compareWith = { $0 as? E == $1 as? E }
	}
	
	init(_ base: Any, compareWith: @escaping (Any, Any) -> Bool) {
		self.base = base
		self.compareWith = compareWith
	}
	
	static func == (lhs: AnyEquatable, rhs: AnyEquatable) -> Bool {
		lhs.compareWith(lhs, rhs)
	}
}
