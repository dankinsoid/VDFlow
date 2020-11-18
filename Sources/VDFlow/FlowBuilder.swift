//
//  FlowBuilder.swift
//  FlowStart
//
//  Created by Daniil on 27.10.2020.
//

import Foundation

@_functionBuilder
public struct FlowBuilder {
	
	/// :nodoc:
	@inlinable
	public static func buildBlock() -> FlowArrayConvertable {
		[]
	}
	
	/// :nodoc:
	@inlinable
	public static func buildBlock(_ components: FlowArrayConvertable...) -> FlowArrayConvertable {
		FlowGroup(components.flatMap { $0.asFlowArray() })
	}
	
	@inlinable
	public static func buildIf(_ component: FlowArrayConvertable?) -> FlowArrayConvertable {
		component ?? FlowGroup([])
	}
	
	/// :nodoc:
	@inlinable
	public static func buildEither(first: FlowArrayConvertable) -> FlowArrayConvertable {
		first
	}
	
	/// :nodoc:
	@inlinable
	public static func buildEither(second: FlowArrayConvertable) -> FlowArrayConvertable {
		second
	}
	
}
