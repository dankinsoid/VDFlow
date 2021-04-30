//
//  File.swift
//  
//
//  Created by Данил Войдилов on 28.04.2021.
//

import Foundation

extension Never: FlowComponent {
	public typealias Content = Never
	public typealias Value = Never
	public func create() -> Never { fatalError() }
	public func update(content: Never, data: Never?) {}
}
