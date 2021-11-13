//
//  File.swift
//  
//
//  Created by Данил Войдилов on 11.11.2021.
//

import Foundation
import QuartzCore
import VDBuilders

protocol StepProtocol {
	var id: UUID { get }
	var mutateID: UInt64 { get set }
}

@dynamicMemberLookup
@propertyWrapper
public struct Step<Base>: StepProtocol, Identifiable, CustomStringConvertible {
	
	public var wrappedValue: Base {
		get { value }
		set {
			select()
			value = newValue
		}
	}
	
	private var value: Base
	
	public var projectedValue: Step {
		get { self }
		set { self = newValue }
	}
	
	public var id = UUID()
	var mutateID: UInt64 = 0
	
	public var selected: Selected {
		get {
			Selected(
				id: Mirror(reflecting: wrappedValue)
					.children
					.compactMap { $0.value as? StepProtocol }
					.sorted(by: { $0.mutateID < $1.mutateID })
					.last?.id ?? .none,
				base: value
			)
		}
		set {
			let time = DispatchTime.now().uptimeNanoseconds
			mutateID = time
			if let new = newValue.keyPath {
				wrappedValue[keyPath: new] = time
			}
		}
	}
	
	public var description: String {
		let children = Mirror(reflecting: wrappedValue)
			.children
			.compactMap { ch in (ch.value as? StepProtocol).map { ($0, ch.label) } }
		
		var selected = children
			.sorted(by: { $0.0.mutateID < $1.0.mutateID })
			.filter { $0.0.mutateID != 0 }
			.last
		
		if selected?.1?.hasPrefix("_") == true {
			selected?.1?.removeFirst()
		}
		if let selected = selected {
			let str = "\(selected.0)"
			let result = "\(selected.1 ?? "nil")"
			return str == "none" ? result : "\(result).\(str)"
		}
		return "none"
	}
	
	public init<T>(wrappedValue: Base, _ selected: WritableKeyPath<Base, Step<T>>) {
		self.init(wrappedValue, selected: selected)
	}
	
	public init(wrappedValue: Base) {
		self.init(wrappedValue)
	}
	
	public init(_ wrappedValue: Base) {
		value = wrappedValue
	}
	
	public init<T>(_ wrappedValue: Base, selected: WritableKeyPath<Base, Step<T>>) {
		var value = wrappedValue
		value[keyPath: selected].mutateID = DispatchTime.now().uptimeNanoseconds
		self.init(value)
	}
	
	public func tag<T>(_ keyPath: WritableKeyPath<Base, Step<T>>) -> Selected {
		Selected(id: wrappedValue[keyPath: keyPath].id, keyPath: keyPath.appending(path: \.mutateID))
	}
	
	public subscript<T>(dynamicMember keyPath: WritableKeyPath<Base, T>) -> T {
		get { wrappedValue[keyPath: keyPath] }
		set { wrappedValue[keyPath: keyPath] = newValue }
	}
	
	public mutating func select() {
		mutateID = DispatchTime.now().uptimeNanoseconds
	}
	
	public mutating func select<T>(_ keyPath: WritableKeyPath<Base, Step<T>>) {
		wrappedValue[keyPath: keyPath].select()
	}
	
	public mutating func select(_ keyPath: WritableKeyPath<Base, EmptyStep>) {
		wrappedValue[keyPath: keyPath].select()
	}
	
	public struct Selected: Hashable {
		public static var none: Selected { Selected() }
		public let id: UUID
		var keyPath: WritableKeyPath<Base, UInt64>?
		var base: (() -> Base)?
		
		init(id: UUID, keyPath: WritableKeyPath<Base, UInt64>) {
			self.id = id
			self.keyPath = keyPath
		}
		
		init(id: UUID, base: Base) {
			self.id = id
			self.base = { base }
		}
		
		init() {
			id = .none
		}
		
		public func hash(into hasher: inout Hasher) {
			id.hash(into: &hasher)
		}
		
		public static func ==(lhs: Selected, rhs: Selected) -> Bool {
			lhs.id == rhs.id
		}
		
		public func match<T>(_ keyPath: WritableKeyPath<Base, Step<T>>) -> Bool {
			if let kp = self.keyPath {
				return kp == keyPath.appending(path: \.mutateID)
			}
			let idKeyPath = keyPath.appending(path: \.id)
			return base?()[keyPath: idKeyPath] == id
		}
	}
	
	@discardableResult
	public mutating func move(_ offset: Int = 1, @TagsBuilder in steps: () -> [(Step) -> Selected]) -> Bool {
		move(offset, in: steps().map { $0(self) })
	}
	
	@discardableResult
	public mutating func move(_ offset: Int = 1, in steps: [Selected]) -> Bool {
		guard let i = steps.firstIndex(of: selected), i + offset < steps.count, i + offset >= 0 else {
			return false
		}
		selected = steps[i + offset]
		return true
	}
}

public func ~=<Base, T>(lhs: WritableKeyPath<Base, Step<T>>, rhs: Step<Base>.Selected) -> Bool {
	rhs.match(lhs)
}

extension Step where Base == EmptyStep {
	public init() {
		self.init(wrappedValue: EmptyStep())
	}
}

extension Step: Equatable where Base: Equatable {}
extension Step: Hashable where Base: Hashable {}
extension Step: Decodable where Base: Decodable {}
extension Step: Encodable where Base: Encodable {}
private extension UUID { static let none = UUID() }