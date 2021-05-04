//
//  FlowPath.swift
//
//  Created by Daniil on 02.11.2020.
//

import Foundation
import SwiftUI

public struct FlowPath: ExpressibleByArrayLiteral, RangeReplaceableCollection {
	public typealias Element = FlowStep
	public typealias Index = Int
	public typealias SubSequence = Array<FlowStep>.SubSequence
	
	public static var current: FlowPath {
		get { FlowStep.tree.path.dropFirst() }
		set { set(newValue) }
	}
	
	@discardableResult
	public static func set(_ new: FlowPath, animated: Bool = true) -> Bool {
		FlowStep.isAnimated = animated
		let result: Bool
		if animated {
			result = withAnimation {
				FlowStep.tree.go(to: new)
			}
		} else {
			result = FlowStep.tree.go(to: new)
		}
		return result
	}
	
	public var steps: [FlowStep]
	public var asStep: FlowStep? { steps.count == 1 ? steps[0] : nil }
	public var startIndex: Int { steps.startIndex }
	public var endIndex: Int { steps.endIndex }
	
	public init(arrayLiteral elements: FlowStep...) {
		steps = elements
	}
	
	public init() {
		steps = []
	}
	
	public init<C: Collection>(_ steps: C) where C.Element == FlowStep {
		self.steps = Array(steps)
	}
	
	public func through<C: Collection>(_ steps: C) -> FlowPath where C.Element == FlowStep {
		FlowPath(steps + Array(self.steps))
	}
	
	public func through(_ steps: FlowStep...) -> FlowPath {
		through(steps)
	}
	
	public func dropFirst(_ count: Int = 1) -> FlowPath {
		FlowPath(steps.dropFirst(count))
	}
	
	public subscript(position: Int) -> FlowStep {
		get { steps[position] }
		set { steps[position] = newValue }
	}
	
	public func index(after i: Int) -> Int {
		steps.index(after: i)
	}
	
	public mutating func replaceSubrange<C: Collection>(_ subrange: Range<Int>, with newElements: __owned C) where FlowStep == C.Element {
		steps.replaceSubrange(subrange, with: newElements)
	}
}

public struct NoneID: Hashable { public init() {} }
	
public protocol FlowPathConvertable {
	func asPath() -> FlowPath
}

extension FlowPathConvertable {
	public var finalStep: FlowStep? {
		asPath().steps.last
	}
}

extension FlowPath: FlowPathConvertable {
	public func asPath() -> FlowPath { self }
}

extension FlowStep: FlowPathConvertable {
	public func asPath() -> FlowPath { FlowPath([self]) }
}

extension FlowPathConvertable {
	public var node: AnyHashable? { finalStep?.node }
}
