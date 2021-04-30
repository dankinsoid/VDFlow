//
//  EmptyComponent.swift
//  FlowStart
//
//  Created by Данил Войдилов on 16.11.2020.
//

import Foundation
import UIKit

public struct EmptyComponent: FlowComponent {
	public struct Content {}
	public init() {}
	public func create() -> Content { Content() }
	public func update(content: Content, data: Void?) {}
}

extension EmptyComponent.Content: UIViewControllerArrayConvertable {
	
	public static func create(from vcs: [UIViewController]) -> EmptyComponent.Content? {
		.init()
	}
	
	public func asViewControllers() -> [UIViewController] {
		[]
	}
}
