//
//  FlowValue.swift
//  VDKitFix
//
//  Created by Данил Войдилов on 21.11.2020.
//

import Foundation

@propertyWrapper
public struct FlowValue<T, ID: Hashable> {
	
	private let id: NodeID<T, ID>
	
	public var wrappedValue: T? {
		get { FlowStorage.shared.steps[id.id]?.data as? T }
		nonmutating set {
			guard let value = newValue else { return }
			FlowStorage.shared.setToNavigate(.id(id, data: value))
		}
	}
	
	public var projectedValue: NodeID<T, ID> { id }
	
	public init(_ id: NodeID<T, ID>) {
		self.id = id
		FlowStorage.shared.collect(for: id.id)
	}
}

extension FlowValue {
	public init(_ id: ID) {
		self = FlowValue(NodeID<T, ID>(id))
	}
}

final class FlowStorage {
	static let shared = FlowStorage()
	var currentStep: FlowStep?
	
	private(set) var steps: [AnyHashable: FlowStep] = [:]
	private var needToCollect: Set<AnyHashable> = []
	private var observers: [ObjectIdentifier: (FlowStep) -> Void] = [:]
	
	func collect(for id: AnyHashable) {
		needToCollect.insert(id)
	}
	
	func remove(id: AnyHashable) {
		if !needToCollect.contains(id) {
			steps[id] = nil
		}
	}
	
	func set(_ value: FlowStep) {
		steps[value.id] = value
	}
	
	func setToNavigate(_ value: FlowStep) {
		steps[value.id] = value
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
