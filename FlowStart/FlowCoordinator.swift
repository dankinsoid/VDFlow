//
//  FlowCoordinator.swift
//  FlowStart
//
//  Created by Daniil on 05.11.2020.
//

import Foundation

public final class FlowCoordinator {
	
	private var root: AnyBaseFlow
	
	public init(_ root: AnyBaseFlow) {
		self.root = root
	}
	
	public init<F: Flow>(_ root: F) {
		self.root = root.root
	}
	
	public func navigate(to path: FlowPath, completion: @escaping () -> Void = {}) {
		guard !path.points.isEmpty else {
			completion()
			return
		}
		let content = root.createAny()
		let (current, view) = root.currentFlow(content: content)
		if current.canNavigate(path: path) {
			navigate(to: path, flow: current, content: view, completion: completion)
		} else if root.canNavigate(path: path) {
			navigate(to: path, flow: root, content: content, completion: completion)
		} else {
			completion()
			return
		}
	}
	
	private func navigate(to path: FlowPath, flow: AnyBaseFlow, content: Any, completion: @escaping () -> Void) {
		guard !path.points.isEmpty else {
			completion()
			return
		}
		let point = path.points[0]
		let newPath = path.dropFirst()
		let flowCompletion = FlowCompletion { maybe in
			guard let pare = maybe else {
				completion()
				return
			}
			if let flow = pare.0.asFlow {
				self.navigate(to: newPath, flow: flow, content: pare.1, completion: completion)
			}
		}
		flow.navigate(to: .point(point), contentAny: content, completion: flowCompletion)
	}
	
	public func navigate(to point: FlowPoint, completion: @escaping () -> Void = {}) {
		navigate(to: FlowPath([point]), completion: completion)
	}
	
	public func navigate(to move: FlowMove, completion: @escaping () -> Void = {}) {
		let content = root.createAny()
		let (flow, view) = root.currentFlow(content: content)
		let flowCompletion = FlowCompletion { _ in
			completion()
		}
		flow.navigate(to: .move(move), contentAny: view, completion: flowCompletion)
	}
	
}

extension AnyBaseFlow {
	
	public func currentFlow(content: Any) -> (AnyBaseFlow, Any) {
		guard let (component, view) = current(contentAny: content) else {
			return (self, content)
		}
		return component.asFlow?.currentFlow(content: view) ?? (self, content)
	}
	
	public func canNavigate(path: FlowPath) -> Bool {
		guard !path.points.isEmpty else { return false }
		if path.points.count == 1 {
			return canGo(to: path.points[0])
		}
		return asFlow?.ifNavigate(to: path.points[0])?.asFlow?.canNavigate(path: path.dropFirst()) ?? false
	}
	
}
