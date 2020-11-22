//
//  FlowCoordinator.swift
//  FlowStart
//
//  Created by Daniil on 05.11.2020.
//

import Foundation

public final class FlowCoordinator {
	
	private var root: () -> AnyBaseFlow
	private lazy var previousFlow = root()
	private var queue: [(FlowPath, () -> Void)] = []
	private var isNavigating = false
	
	public init(_ root: @escaping @autoclosure () -> AnyBaseFlow) {
		self.root = root
		afterInit()
	}
	
	public init<F: Flow>(_ root: F) {
		self.root = { root.root }
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
		guard !isNavigating else {
			queue.append((path, completion))
			return
		}
		isNavigating = true
		path.steps.forEach(FlowStorage.shared.set)
		FlowStorage.shared.currentStep = path.steps.last!
		let flow = root()
		let compl: () -> Void = {[weak self] in
			completion()
			self?.previousFlow = flow
			path.steps.forEach {
				FlowStorage.shared.remove(id: $0._id)
			}
			if let (path, cmpl) = self?.queue.first {
				self?.queue.removeFirst()
				self?.navigate(to: path, completion: cmpl)
			}
		}
		let content = flow.createAny()
		let (current, view) = flow.currentFlow(content: content)
		if current.canNavigate(path: path) {
			navigate(to: path, flow: current, content: view, completion: compl)
		} else if flow.canNavigate(path: path) {
			navigate(to: path, flow: flow, content: content, completion: compl)
		} else {
			compl()
			return
		}
	}
	
	public func current() -> (component: AnyFlowComponent, view: Any)? {
		previousFlow.current(contentAny: previousFlow.createAny())
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
			FlowStorage.shared.currentStep = nil
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
