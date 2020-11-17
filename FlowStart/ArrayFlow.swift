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
	private let rootComponent: AnyFlowComponent?
	
	public init(delegate: Delegate, root: AnyFlowComponent? = nil, components: [AnyFlowComponent]) {
		self.components = components
		self.delegate = delegate
		self.rootComponent = root
	}
	
	public func navigate(to step: FlowStep, parent: Delegate.Parent, completion: FlowCompletion) {
		guard let i =
						moveIndex(step.move, parent: parent) ??
						components.firstIndex(where: { $0.canGo(to: step.point) }),
						i < components.count,
						let component = i > -1 ? components[i] : rootComponent else {
			completion.complete(nil)
			return
		}
		let (vcs, vc) = children(parent: parent, current: i)
		guard vc != nil || i < 0 else {
			completion.complete(nil)
			return
		}
		let componentPending = completion.pending()
		component.updateAny(content: i > -1 ? vc! : parent, step: step, completion: componentPending.completion)
		let pending = OnReadyCompletion<Void>.pending(componentPending.ready)
		delegate.set(children: vcs, current: i, to: parent, animated: step.animated, completion: pending.completion)
		completion.onReady { _ in
			pending.ready()
		}
	}
	
	private func moveIndex(_ move: Int?, parent: Delegate.Parent) -> Int? {
		guard let offset = move, let i = currentIndex(parent: parent) else { return nil }
		return min(components.count, max(0, i + offset))
	}
	
	private func children(parent: Delegate.Parent, current: Int) -> ([Delegate.Child], Delegate.Child?) {
		guard current >= 0 else { return ([], nil) }
		var result: ([Delegate.Child], Delegate.Child?) = ([], nil)
		delegate.setType.componentsToSet(from: Array(ids().enumerated()), current: current).forEach { pare in
			if let vc = delegate.children(for: parent).first(where: { delegate.getId(for: $0) == pare.element }) {
				result.0.append(vc)
				if pare.offset == current {
					result.1 = vc
				}
				return
			}
			guard let vc = components[pare.offset].createAny() as? Delegate.Child else { return }
			delegate.set(id: pare.element, child: vc)
			result.0.append(vc)
			if pare.offset == current {
				 result.1 = vc
			 }
		}
		return result
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
		if let result = rootComponent?._ifNavigate(to: point) {
			return result
		}
		for component in components {
			if let result = component._ifNavigate(to: point) {
				return result
			}
		}
		return nil
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

public enum ArrayFlowSetType {
	case all, upTo, from, one, custom((_ count: Int, _ current: Int) -> [ClosedRange<Int>])
	
	public func componentsToSet<T>(from all: [T], current index: Int) -> [T] {
		switch self {
		case .all:								return all
		case .upTo:								return Array(all.prefix(upTo: index + 1))
		case .from:								return Array(all.suffix(from: index))
		case .one:								return [all[index]]
		case .custom(let block):	return Array(block(all.count, index).map { all[$0] }.joined())
		}
	}
}

public protocol ArrayFlowDelegateProtocol {
	associatedtype Parent
	associatedtype Child
	var setType: ArrayFlowSetType { get }
	func children(for parent: Parent) -> [Child]
	func set(id: String, child: Child)
	func getId(for child: Child) -> String?
	func currentChild(for parent: Parent) -> Child?
	func set(children: [Child], current: Int, to parent: Parent, animated: Bool, completion: OnReadyCompletion<Void>)
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
