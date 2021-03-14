//
//  FlowBuilder.swift
//  FlowStart
//
//  Created by Daniil on 27.10.2020.
//

import Foundation

@_functionBuilder
public struct FlowBuilder {
	
	@inlinable
	public static func buildBlock(_ components: FlowArrayConvertable...) -> FlowArrayConvertable {
		FlowGroup(components)
	}
	
	@inlinable
	public static func buildOptional(_ component: FlowArrayConvertable?) -> FlowArrayConvertable {
		component ?? FlowGroup([])
	}
	
	@inlinable
	public static func buildEither(first: FlowArrayConvertable) -> FlowArrayConvertable {
		first
	}
	
	@inlinable
	public static func buildEither(second: FlowArrayConvertable) -> FlowArrayConvertable {
		second
	}
	
	@inlinable
	public static func buildArray(_ components: [FlowArrayConvertable]) -> FlowArrayConvertable {
		FlowGroup(components)
	}
	
	@inlinable
	public static func buildExpression<T: UIViewControllerConvertable>(_ expression: @escaping @autoclosure () -> T) -> FlowArrayConvertable {
		VC(expression)
	}
	
	@inlinable
	public static func buildExpression(_ expression: FlowArrayConvertable) -> FlowArrayConvertable {
		expression
	}
}
