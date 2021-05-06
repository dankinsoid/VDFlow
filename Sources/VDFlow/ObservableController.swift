//
//  File.swift
//  
//
//  Created by Данил Войдилов on 06.05.2021.
//

import UIKit
import SwiftUI

public protocol ObservableControllerType: UIViewController {
	@discardableResult
	func on(_ type: ControllerObserveType, id: AnyHashable, _ action: @escaping (Bool) -> Void) -> () -> Void
	func cancel(observer id: AnyHashable, on type: ControllerObserveType)
}

open class ObservableHostingController<Root: View>: UIHostingController<Root> {
	
	private var observers: [ControllerObserveType: [AnyHashable: (Bool) -> Void]] = [:]
	
	override open func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		send(.willAppear, animated: animated)
	}
	
	override open func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		send(.didAppear, animated: animated)
	}

	override open func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		send(.willDisappear, animated: animated)
	}
	
	override open func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		send(.didDisappear, animated: animated)
	}
	
	private func send(_ type: ControllerObserveType, animated: Bool) {
		observers[type]?.forEach { $0.value(animated) }
	}
	
	@discardableResult
	open func on(_ type: ControllerObserveType, id: AnyHashable = UUID(), _ action: @escaping (Bool) -> Void) -> () -> Void {
		observers[type, default: [:]][id] = action
		return { self.cancel(observer: id, on: type) }
	}
	
	@discardableResult
	public final func on(_ type: ControllerObserveType, id: AnyHashable = UUID(), _ action: @escaping () -> Void) -> () -> Void {
		on(type, id: id) { _ in action() }
	}
	
	public final func cancel(observer id: AnyHashable, on type: ControllerObserveType) {
		observers[type]?[id] = nil
	}
}

public enum ControllerObserveType: Hashable {
	case willAppear, didAppear, willDisappear, didDisappear
}
