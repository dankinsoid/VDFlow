//
//  File.swift
//  
//
//  Created by Данил Войдилов on 21.08.2021.
//

import SwiftUI

public enum FlowStackFrontTransitionKey: EnvironmentKey {
    public static var defaultValue: InteractiveTransition { .identity }
}

public enum FlowStackBackTransitionKey: EnvironmentKey {
    public static var defaultValue: InteractiveTransition { .identity }
}

extension EnvironmentValues {
    public var flowStackFrontTransition: InteractiveTransition {
        get { self[FlowStackFrontTransitionKey.self] }
        set { self[FlowStackFrontTransitionKey.self] = newValue }
    }
}

extension EnvironmentValues {
    public var flowStackBackTransition: InteractiveTransition {
        get { self[FlowStackBackTransitionKey.self] }
        set { self[FlowStackBackTransitionKey.self] = newValue }
    }
}

extension View {
    public func flowStackTransition(front: InteractiveTransition, back: InteractiveTransition = .identity) -> some View {
        environment(\.flowStackFrontTransition, front)
            .environment(\.flowStackBackTransition, back)
    }
}

public enum FlowStackInteractiveKey: EnvironmentKey {
    public static var defaultValue: FlowStackInteractive? { nil }
}

extension EnvironmentValues {
    public var flowStackInteractive: FlowStackInteractive? {
        get { self[FlowStackInteractiveKey.self] }
        set { self[FlowStackInteractiveKey.self] = newValue }
    }
}

extension View {
    
    public func flowStackInteractive(_ interactive: FlowStackInteractive?) -> some View {
        environment(\.flowStackInteractive, interactive)
    }
    
    public func flowStackInteractive(hide: Edge.Set, show: Edge.Set = [], fromEdgeOnly: Bool = false) -> some View {
        flowStackInteractive(FlowStackInteractive(hide: .init(hide, fromEdgeOnly: fromEdgeOnly), show:  .init(show, fromEdgeOnly: fromEdgeOnly)))
    }
}
