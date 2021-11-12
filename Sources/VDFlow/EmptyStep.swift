//
//  File.swift
//  
//
//  Created by Данил Войдилов on 11.11.2021.
//

import Foundation

public struct EmptyStep: Hashable, Codable, CustomStringConvertible {
	private var updater = false
	public var description: String { "EmptyStep" }
	
	public init() {}
	
	public mutating func select() {
		updater.toggle()
	}
}
