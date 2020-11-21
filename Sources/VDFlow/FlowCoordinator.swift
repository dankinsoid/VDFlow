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
		afterInit()
	}
	
	public init<F: Flow>(_ root: F) {
		self.root = root.root
		afterInit()
	}
	
	private func afterInit() {
		FlowStorage.shared.observe(object: self) {[weak self] in
			self?.navigate(to: $0)
		}
	}
	
	public func navigate(to path: FlowPath, completion: @escaping () -> Void = {}) {
		guard !path.steps.isEmpty else {
			completion()
			return
		}
		path.steps.forEach {
			FlowStorage.shared.set(id: $0.id, value: path.steps[0])
		}
		let compl: () -> Void = {
			completion()
			path.steps.forEach {
				FlowStorage.shared.remove(id: $0.id)
			}
		}
		let content = root.createAny()
		let (current, view) = root.currentFlow(content: content)
		if current.canNavigate(path: path) {
			navigate(to: path, flow: current, content: view, completion: compl)
		} else if root.canNavigate(path: path) {
			navigate(to: path, flow: root, content: content, completion: compl)
		} else {
			compl()
			return
		}
	}
	
	public func current() -> AnyFlowComponent? {
		root.current(contentAny: root.createAny())?.0
	}
	
	private func navigate(to path: FlowPath, flow: AnyBaseFlow, content: Any, completion: @escaping () -> Void) {
		guard !path.steps.isEmpty else {
			flow.current(contentAny: content)?.0.didNavigated()
			completion()
			return
		}
		let step = path.steps[0]
		let newPath = path.dropFirst()
		let flowCompletion = FlowCompletion { maybe in
			guard let pare = maybe else {
				completion()
				return
			}
			self.navigate(to: newPath, flow: pare.0, content: pare.1, completion: completion)
		}
		flow.navigate(to: step, contentAny: content, completion: flowCompletion)
	}
	
	public func navigate(to step: FlowStep, completion: @escaping () -> Void = {}) {
		navigate(to: FlowPath([step]), completion: completion)
	}
	
	public func navigate(to node: FlowNode, completion: @escaping () -> Void = {}) {
		navigate(to: FlowPath([.move(.node(node))]), completion: completion)
	}
	
	public func navigate(to node: NodeID<Void>, completion: @escaping () -> Void = {}) {
		navigate(to: node.with(()), completion: completion)
	}
	
	public func navigate<R: RawRepresentable>(to id: R, completion: @escaping () -> Void = {}) where R.RawValue == String {
		navigate(to: NodeID(id), completion: completion)
	}
	
	public func navigate(to id: String, completion: @escaping () -> Void = {}) {
		navigate(to: NodeID<Void>(id), completion: completion)
	}
	
	deinit {
		FlowStorage.shared.remove(observer: self)
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
		guard !path.steps.isEmpty else { return false }
		guard let node = path.steps[0].node else {
			return asFlow != nil
		}
		if path.steps.count == 1 {
			return canGo(to: node)
		}
		return asFlow?.flow(for: node)?.canNavigate(path: path.dropFirst()) ?? false
	}
	
}
