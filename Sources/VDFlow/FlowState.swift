//
//  File.swift
//  
//
//  Created by Данил Войдилов on 29.04.2021.
//

import Foundation
import SwiftUI
import VDKit

@available(iOS 13.0.0, *)
@propertyWrapper
public struct FlowState<Value: Hashable>: DynamicProperty {
	
	public var wrappedValue: Value {
		get {
			let current = node.id.base as? Value
			if current == nil {
				node.set(id: defaultValue)
			}
			return current ?? defaultValue
		}
		nonmutating set {
			node.set(id: newValue)
			updater.toggle()
		}
	}
	private let defaultValue: Value
	
	@Environment(\.flowTree) private var node: FlowTree
	@StateObject var viewModel = FlowViewModel.root
	@State private var updater = false
	
	public var path: FlowPath {
		get { node.path }
		set { viewModel.go(to: newValue, from: node) }
	}
	
	public var projectedValue: Binding<Value> { binding }
	
	public var binding: Binding<Value> {
		Binding(get: { wrappedValue }, set: { wrappedValue = $0 })
	}
	
	public init(wrappedValue: Value) {
		self.defaultValue = wrappedValue
	}
}

extension View {
	public func flow<ID: Hashable>(_ state: FlowState<ID>, for id: ID) -> some View {
		FlowView(content: self) { $0[id] }.tag(id)
	}
}

struct FlowView<Content: View>: View {
	let content: Content
	var createTree: (FlowTree) -> (FlowTree, Bool)
	@Environment(\.flowTree) private var flow: FlowTree
	
	var body: some View {
		content.environment(\.flowTree, tree)
	}
	
	private var tree: FlowTree {
		let tree = createTree(flow)
		if tree.1, let step = FlowViewModel.root.step(for: tree.0) {
			tree.0.set(step)
		}
		return tree.0
	}
}

enum FlowKey: EnvironmentKey {
	static var defaultValue: FlowTree { .root }
}

extension EnvironmentValues {
	var flowTree: FlowTree {
		get { self[FlowKey.self] }
		set { self[FlowKey.self] = newValue }
	}
}
