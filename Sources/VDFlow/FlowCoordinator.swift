//
//  FlowCoordinator.swift
//  FlowStart
//
//  Created by Daniil on 05.11.2020.
//

import Foundation

public protocol AnyFlowCoordinator {
	func navigate<ID: Hashable>(id: ID, completion: @escaping () -> Void)
	func navigate<P: FlowPathConvertable>(to path: P, completion: @escaping () -> Void)
	func current() -> (component: AnyFlowComponent, view: Any)?
}

extension AnyFlowCoordinator {
	public func navigate<ID: Hashable>(id: ID) { navigate(id: id, completion: {}) }
	public func navigate<P: FlowPathConvertable>(to path: P) { navigate(to: path, completion: {}) }
}

public final class FlowCoordinator<Root: FlowComponent>: AnyFlowCoordinator {
	
	var root: () -> Root
	private lazy var previousFlow = root()
	private var queue: [(FlowPath, () -> Void)] = []
	private var isNavigating = false
	
	public init(_ root: @escaping @autoclosure () -> Root) {
		self.root = root
		afterInit()
	}
	
	public init(@FlowBuilder _ root: @escaping () -> Root) {
		self.root = root
		afterInit()
	}
	
	private func afterInit() {
		FlowStorage.shared.observe(object: self) {[weak self] in
			self?.navigate(to: $0)
		}
	}
	
	private func navigateTo(path: FlowPath, completion: @escaping () -> Void = {}) {
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
		FlowStorage.shared.currentStep = path.steps.last ?? .empty
		let flow = root()
		let compl: () -> Void = {[weak self] in
			completion()
			self?.isNavigating = false
			self?.previousFlow = flow
			path.steps.forEach {
				FlowStorage.shared.remove(id: $0.id)
			}
			if let (path, cmpl) = self?.queue.first {
				self?.queue.removeFirst()
				self?.navigate(to: path, completion: cmpl)
			}
		}
		let content = flow.create()
		let currentFlow = flow.current(content: content)
		if let (current, view) = currentFlow, current.contains(path: path, content: view) {
			navigate(to: path, flow: current, content: view, completion: compl)
		} else if flow.contains(path: path, content: content) {
			navigate(to: path, flow: flow, content: content, completion: compl)
		} else {
			FlowStorage.shared.currentStep = nil
			compl()
			return
		}
	}
	
	public func current() -> (component: AnyFlowComponent, view: Any)? {
		previousFlow.current(contentAny: previousFlow.createAny())
	}
	
	private func navigate(to path: FlowPath, flow: AnyFlowComponent, content: Any, completion: @escaping () -> Void) {
		guard !path.steps.isEmpty else {
//			flow.current(contentAny: content)?.0.didNavigated()
			completion()
			return
		}
		let step = path.steps[0]
		let newPath = path.dropFirst()
		let flowCompletion: (Bool) -> Void = { completed in
			FlowStorage.shared.currentStep = nil
			guard completed, let pare = flow.current(contentAny: content) else {
				completion()
				return
			}
			self.navigate(to: newPath, flow: pare.0, content: pare.1, completion: completion)
		}
		flow.navigate(to: step, contentAny: content, completion: flowCompletion)
	}
	
	public func navigate<P: FlowPathConvertable>(to path: P, completion: @escaping () -> Void = {}) {
		navigateTo(path: path.asPath(), completion: completion)
	}
	
	public func navigate<ID: Hashable>(id: ID, completion: @escaping () -> Void = {}) {
		navigate(to: NodeID<Void, ID>(id), completion: completion)
	}
	
	deinit {
		FlowStorage.shared.remove(observer: self)
	}
}

extension AnyFlowComponent {
	func contains(path: FlowPath, content: Any) -> Bool {
		guard let step = path.steps.first else { return true }
		if let flow = children(contentAny: content).first(where: { step.isNode($0.0.flowIdAny) }) {
			return flow.0.contains(path: path.dropFirst(), content: flow.1)
		}
		return false
	}
}
