//
//  ArrayFlow.swift
//  FlowStart
//
//  Created by Daniil on 08.11.2020.
//

import UIKit
import Foundation

public protocol ArrayFlowProtocol: BaseFlow where Delegate.Parent == Content {
	associatedtype Delegate: ArrayFlowDelegateProtocol
	var delegate: ArrayFlow<Delegate> { get }
}

extension ArrayFlowProtocol {
	
	public func navigate(to step: FlowStep, content: Content, completion: FlowCompletion) {
		delegate.navigate(to: step, parent: content, completion: completion)
	}
	
	public func ifNavigate(to point: FlowPoint) -> AnyFlowComponent? {
		delegate.ifNavigate(to: point)
	}
	
	public func current(content: Content) -> (AnyFlowComponent, Any)? {
		delegate.current(parent: content)
	}
	
}

public struct ArrayFlow<Delegate: ArrayFlowDelegateProtocol> {
	public let components: [AnyFlowComponent]
	private let delegate: Delegate
	
	public init(delegate: Delegate, components: [AnyFlowComponent]) {
		self.components = components
		self.delegate = delegate
	}
	
	public func navigate(to step: FlowStep, parent: Delegate.Parent, completion: FlowCompletion) {
		guard let i =
						moveIndex(step.move, parent: parent) ??
						components.firstIndex(where: { $0.canGo(to: step.point) }) else {
			completion.complete(nil)
			return
		}
		let component = components[i]
		let vcs = children(parent: parent, maxCount: i + 1)
		let componentPending = completion.pending()
		component.updateAny(content: vcs[i], step: step, completion: componentPending.completion)
		let pending = OnReadyCompletion<Void>.pending(componentPending.ready)
		delegate.set(children: vcs, to: parent, animated: step.animated, completion: pending.completion)
		completion.onReady { _ in
			pending.ready()
		}
	}
	
	private func moveIndex(_ move: Int?, parent: Delegate.Parent) -> Int? {
		guard let offset = move, let i = currentIndex(parent: parent) else { return nil }
		return min(components.count, max(0, i + offset))
	}
	
	private func children(parent: Delegate.Parent, maxCount: Int) -> [Delegate.Child] {
		ids().prefix(maxCount).enumerated().compactMap { pare in
			if let vc = delegate.children(for: parent).first(where: { delegate.getId(for: $0) == pare.element }) {
				return vc
			}
			guard let vc = components[pare.offset].createAny() as? Delegate.Child else { return nil }
			delegate.set(id: pare.element, child: vc)
			return vc
		}
	}
	
	private func ids() -> [String] {
		var orders: [String: Int] = [:]
		var result: [String] = []
		for component in components {
			let id = component.id + (orders[component.id].map { "\($0)" } ?? "")
			result.append(id)
			orders[component.id, default: 0] += 1
		}
		return result
	}
	
	public func ifNavigate(to point: FlowPoint) -> AnyFlowComponent? {
		components.first {
			$0.canGo(to: point)
		}
	}
	
	public func current(parent: Delegate.Parent) -> (AnyFlowComponent, Any)? {
		guard let vc = delegate.currentChild(for: parent),
					let i = currentIndex(parent: parent) else { return nil }
		return (components[i], vc)
	}
	
	private func currentIndex(parent: Delegate.Parent) -> Int? {
		guard let child = delegate.currentChild(for: parent),
					let id = delegate.getId(for: child),
					let i = ids().firstIndex(of: id) else { return nil }
		return i
	}
	
}

public protocol ArrayFlowDelegateProtocol {
	associatedtype Parent
	associatedtype Child
	func children(for parent: Parent) -> [Child]
	func set(id: String, child: Child)
	func getId(for child: Child) -> String?
	func currentChild(for parent: Parent) -> Child?
	func set(children: [Child], to parent: Parent, animated: Bool, completion: OnReadyCompletion<Void>)
}

extension ArrayFlowDelegateProtocol where Child: UIView {
	public func getId(for child: Child) -> String? {
		child.accessibilityIdentifier
	}
	public func set(id: String, child: Child) {
		child.accessibilityIdentifier = id
	}
}

extension ArrayFlowDelegateProtocol where Child: UIViewController {
	public func getId(for child: Child) -> String? {
		child.view?.accessibilityIdentifier
	}
	public func set(id: String, child: Child) {
		child.loadViewIfNeeded()
		child.view?.accessibilityIdentifier = id
	}
}

extension ArrayFlowDelegateProtocol where Parent: UIViewController, Child: UIViewController {
	
	func before(_ completion: @escaping () -> Void) {
		
	}
	
	public func dismissPresented(parent: Parent, animated: Bool, completion: @escaping () -> Void) {
		if parent.presentedViewController != nil {
			parent.dismissPresented(animated: animated, completion: completion)
		} else if let current = currentChild(for: parent), current.presentedViewController != nil {
			current.dismissPresented(animated: animated, completion: completion)
		} else {
			completion()
		}
	}
	
}
