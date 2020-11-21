//
//  EmptyComponent.swift
//  FlowStart
//
//  Created by Данил Войдилов on 16.11.2020.
//

import Foundation

public struct EmptyComponent: FlowComponent {
	public func create() -> Void { () }
	public func update(content: Void, data: Void?) {}
	public init() {}
}
