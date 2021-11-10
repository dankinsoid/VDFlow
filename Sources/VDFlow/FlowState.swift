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
public struct FlowState<Value: Equatable>: DynamicProperty {
  
  public var wrappedValue: Value {
    get {
      let current = (node.id.1 as? Value) ?? (node.id.0.base as? Value)
      if current == nil {
        let pair = map(defaultValue)
        node.set(id: pair.0, value: pair.1)
      }
      return current ?? defaultValue
    }
    nonmutating set {
      let pair = map(newValue)
      node.set(id: pair.0, value: pair.1)
      updater.toggle()
    }
  }
  private let defaultValue: Value
  private let map: (Value) -> (AnyHashable, Value?)
  
  @Environment(\.flowTree) private var node: FlowTree
  @ObservedObject var viewModel = FlowViewModel.root
  @State private var updater = false
  
  public var path: FlowPath {
    get { node.path }
    set { viewModel.go(to: newValue, from: node) }
  }
  
  public var projectedValue: Binding<Value> { binding }
  
  public var binding: Binding<Value> {
    Binding(get: { wrappedValue }, set: { wrappedValue = $0 })
  }
}

extension FlowState where Value: Hashable {
  
  public init(wrappedValue: Value) {
    self.defaultValue = wrappedValue
    self.map = { ($0, nil) }
  }
}

extension FlowState where Value: Identifiable {
  
  public init(wrappedValue: Value) {
    self.defaultValue = wrappedValue
    self.map = { ($0.id, $0) }
  }
}

extension FlowState where Value: Identifiable & Hashable {
  
  public init(wrappedValue: Value) {
    self.defaultValue = wrappedValue
    self.map = { ($0.id, $0) }
  }
}

extension View {
  
  public func flow<ID: Hashable>(_ state: FlowState<ID>, for id: ID) -> some View {
    FlowView(content: self) { $0[nil, id] }.tag(id)
  }
  
  public func flow<ID: Identifiable & Equatable>(_ state: FlowState<ID>, forIdFrom value: ID) -> some View {
    FlowView(content: self) { $0[AnyEquatable(value), value.id] }.tag(value.id)
  }
  
  public func flow<ID: Identifiable & Hashable>(_ state: FlowState<ID>, forIdFrom value: ID) -> some View {
    FlowView(content: self) { $0[AnyEquatable(value), value.id] }.tag(value.id)
  }
  
  public func flow<ID: Identifiable>(_ state: FlowState<ID>, for id: ID.ID) -> some View {
    FlowView(content: self) { $0[nil, id] }.tag(id)
  }
  
  public func flow<ID: Identifiable & Hashable>(_ state: FlowState<ID>, for id: ID.ID) -> some View {
    FlowView(content: self) { $0[nil, id] }.tag(id)
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
