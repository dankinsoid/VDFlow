//
//  File.swift
//  
//
//  Created by Данил Войдилов on 08.02.2021.
//

import Foundation

public struct VC<Content>: FlowComponent {
	private let createClosure: () -> Content
	
	public init(_ create: @escaping () -> Content) {
		createClosure = create
	}
	
	public init(_ create: @escaping @autoclosure () -> Content) {
		createClosure = create
	}
	
	public func create() -> Content {
		createClosure()
	}
}
