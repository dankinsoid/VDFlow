//
//  FlowValue.swift
//  VDKitFix
//
//  Created by Данил Войдилов on 21.11.2020.
//

import Foundation

@propertyWrapper
public struct FlowValue<T> {
	
	private let id: NodeID<T>
	
	public var wrappedValue: T? {
		get { FlowStorage.shared.steps[id.id]?.data as? T }
		nonmutating set {
			guard let value = newValue else { return }
			FlowStorage.shared.setToNavigate(id: id.id, value: .id(id, data: value))
		}
	}
	
	public var projectedValue: NodeID<T> { id }
	
	public init(_ id: NodeID<T>) {
		self.id = id
		FlowStorage.shared.collect(for: id.id)
	}
	
}

extension FlowValue {
	
	public init<R: RawRepresentable>(_ raw: R) where R.RawValue == String {
		self = FlowValue(NodeID<T>(raw))
	}
	
	public init(_ id: String) {
		self = FlowValue(NodeID<T>(id))
	}
}

final class FlowStorage {
	static let shared = FlowStorage()
	
	private(set) var steps: [String: FlowStep] = [:]
	private var needToCollect: Set<String> = []
	private var observers: [ObjectIdentifier: (FlowStep) -> Void] = [:]
	
	func collect(for id: String) {
		needToCollect.insert(id)
	}
	
	func remove(id: String?) {
		if let id = id, !needToCollect.contains(id) {
			steps[id] = nil
		}
	}
	
	func set(id: String?, value: FlowStep) {
		guard let id = id else { return }
		steps[id] = value
	}
	
	func setToNavigate(id: String, value: FlowStep) {
		steps[id] = value
		DispatchQueue.main.async {
			self.observers.forEach {
				$0.value(value)
		 }
		}
	}
	
	func observe(object: AnyObject, _ observer: @escaping (FlowStep) -> Void) {
		observers[ObjectIdentifier(object)] = observer
	}
	
	func remove(observer: AnyObject) {
		observers[ObjectIdentifier(observer)] = nil
	}
	
}
