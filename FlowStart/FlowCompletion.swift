//
//  FlowCompletion.swift
//  FlowStart
//
//  Created by Данил Войдилов on 16.11.2020.
//

import Foundation

public typealias FlowCompletion = OnReadyCompletion<(AnyFlowComponent, Any)?>
public typealias FlowCompletionPending = OnReadyCompletionPending<(AnyFlowComponent, Any)?>

public final class OnReadyCompletion<Value> {
	public typealias Completion = (Value) -> Void
	
	private let completion: Completion
	private var isReady: Bool
	private var action: ((@escaping Completion) -> Void)?
	
	public static func pending(_ completion: @escaping Completion) -> OnReadyCompletionPending<Value> {
		OnReadyCompletionPending(completion)
	}
	
	public convenience init(_ completion: @escaping Completion) {
		self.init(completion, isReady: true)
	}
	
	fileprivate init(_ completion: @escaping Completion, isReady: Bool) {
		self.completion = completion
		self.isReady = isReady
	}
	
	public func onReady(_ action: @escaping (@escaping Completion) -> Void) {
		let old = self.action
		self.action = { old?($0); action($0) }
		if isReady {
			action(completion)
		}
	}
	
	fileprivate func ready() {
		isReady = true
		if let action = self.action {
			action(completion)
		}
	}
	
	public func complete(_ value: Value) {
		onReady { $0(value) }
	}
	
	public func pending() -> OnReadyCompletionPending<Value> {
		OnReadyCompletionPending { self.complete($0) }
	}
	
}

public final class OnReadyCompletionPending<Value> {
	
	public let completion: OnReadyCompletion<Value>
	
	fileprivate init(_ completion: @escaping OnReadyCompletion<Value>.Completion) {
		self.completion = OnReadyCompletion(completion, isReady: false)
	}
	
	public func ready() {
		completion.ready()
	}
	
}
