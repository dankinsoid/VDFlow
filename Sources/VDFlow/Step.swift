import Foundation

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
	var stepID: UUID { id }
	var mutateID = MutateID()
	var noneSelectedId = MutateID()
	
	public var selected: Key {
		get {
			let last = children
				.filter { $0.mutateID != 0 }
				.sorted(by: { $0.mutateID < $1.mutateID })
				.last
			let id = (last?.mutateID ?? 0) > noneSelectedId ? last?.stepID ?? .none : .none
			return Key(id: id, base: value)
		}
		set {
			mutateID.update()
			if let new = newValue.keyPath {
				wrappedValue[keyPath: new].value = mutateID.value
			} else if newValue == .none {
				noneSelectedId.value = mutateID.value
				allChildren.forEach {
					$0.noneSelectedId.value = mutateID.value
				}
			}
		}
	}
	
	public var description: String {
		let children = (value as? any Collection)?
          .compactMap { $0 as? StepProtocol }
          .enumerated()
          .map { ($0.element, "\($0.offset)") } ??
      Mirror(reflecting: wrappedValue)
					.children
					.compactMap { ch in (ch.value as? StepProtocol).map { ($0, ch.label ?? "") } }
		
		var selected = children
			.sorted(by: { $0.0.mutateID < $1.0.mutateID })
			.filter { $0.0.mutateID != 0 }
			.last
		
		if noneSelectedId > (selected?.0.mutateID ?? 0) {
			selected = nil
		}
		
		if selected?.1.hasPrefix("_") == true {
			selected?.1.removeFirst()
		}
		if let selected = selected {
			let str = "\(selected.0)"
			let result = "\(selected.1)"
			return str == "none" ? result : "\(result).\(str)"
		}
		return "none"
	}
	
	public var allKeys: [Key] {
		children.map {
			Key(id: $0.stepID, base: value)
		}
	}
	
	var children: [StepProtocol] {
		(value as? any Collection)?
          .compactMap { $0 as? StepProtocol } ??
      Mirror(reflecting: value)
          .children
          .compactMap { $0.value as? StepProtocol }
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
		self.init(wrappedValue)
		self.wrappedValue[keyPath: selected].mutateID = MutateID()
		self.wrappedValue[keyPath: selected].mutateID.update()
	}
	
	/// - Warning: Don't pass nested or computed key path
	public func key<T>(_ keyPath: WritableKeyPath<Base, Step<T>>) -> Key {
		Key(id: wrappedValue[keyPath: keyPath].stepID, keyPath: keyPath.appending(path: \.mutateID))
	}
	
	public subscript<T>(dynamicMember keyPath: WritableKeyPath<Base, T>) -> T {
		get { wrappedValue[keyPath: keyPath] }
		set { wrappedValue[keyPath: keyPath] = newValue }
	}
    
  public func isSelected<T>(_ keyPath: WritableKeyPath<Base, Step<T>>) -> Bool {
    selected == key(keyPath)
  }
	
	public mutating func select() {
		mutateID = MutateID()
		mutateID.update()
	}
	
	public mutating func unselect() {
    selected = .none
	}
    
	public mutating func select(_ action: StepAction<Base>) {
		action.set(&self)
	}
	
	public mutating func select<T>(_ keyPath: WritableKeyPath<Base, Step<T>>) {
		wrappedValue[keyPath: keyPath].select()
	}
    
	public mutating func unselect<T>(_ keyPath: WritableKeyPath<Base, Step<T>>) {
    wrappedValue[keyPath: keyPath].unselect()
	}
	
	public struct Key: Hashable, Identifiable {
		public static var none: Key { Key() }
		
		public let id: UUID
		public var optional: Key? {
			get { id == .none ? nil : self }
			set { self = newValue ?? .none }
		}
		var keyPath: KeyPath<Base, MutateID>?
		var base: (() -> Base)?
		
		init(id: UUID, keyPath: KeyPath<Base, MutateID>) {
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
		
		public static func ==(lhs: Key, rhs: Key) -> Bool {
			lhs.id == rhs.id
		}
		
		public func match<T>(_ keyPath: WritableKeyPath<Base, Step<T>>) -> Bool {
			if let kp = self.keyPath {
				return kp == keyPath.appending(path: \.mutateID)
			}
			let idKeyPath = keyPath.appending(path: \.stepID)
			return base?()[keyPath: idKeyPath] == id
		}
	}
	
	@discardableResult
	public mutating func move(_ offset: Int = 1, @TagsBuilder in steps: () -> [(Step) -> Key]) -> Bool {
		move(offset, in: steps().map { $0(self) })
	}
	
	@discardableResult
	public mutating func move(_ offset: Int = 1, in steps: [Key]) -> Bool {
		guard let i = steps.firstIndex(of: selected), i + offset < steps.count, i + offset >= 0 else {
			return false
		}
		selected = steps[i + offset]
		return true
	}
}

public func ~=<Base, T>(lhs: WritableKeyPath<Base, Step<T>>, rhs: Step<Base>.Key) -> Bool {
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
