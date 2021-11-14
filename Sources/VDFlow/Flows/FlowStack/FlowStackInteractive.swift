//
//  File.swift
//  
//
//  Created by Данил Войдилов on 15.08.2021.
//
import Foundation
import SwiftUI

public struct FlowStackInteractive: Hashable {
    public var hide: FlowStackInteractiveUnit?
    public var show: FlowStackInteractiveUnit?
    
    public init(hide: FlowStackInteractiveUnit?, show: FlowStackInteractiveUnit? = nil) {
        self.hide = hide
        self.show = show
    }
    
    public init(_ edges: Edge.Set, fromEdgeOnly: Bool = false) {
        self.init(hide: .init(edges, fromEdgeOnly: fromEdgeOnly))
    }
}

public struct FlowStackInteractiveUnit: Hashable {
    public var edges: Edge.Set
    public var fromEdgeOnly: Bool
    
    public init(_ edges: Edge.Set, fromEdgeOnly: Bool = false) {
        self.edges = edges
        self.fromEdgeOnly = fromEdgeOnly
    }
}

extension Edge.Set: Hashable {}
