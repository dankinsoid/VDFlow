//
//  File.swift
//  
//
//  Created by Данил Войдилов on 16.08.2021.
//

#if canImport(UIKit)
import Foundation
import SwiftUI

public struct InteractiveTransition {
    fileprivate var active: (AnyView, CGFloat, CGRect) -> AnyView
    fileprivate var identity: (AnyView, CGFloat, CGRect) -> AnyView
    
    public init<I: View, R: View>(@ViewBuilder active: @escaping (AnyView, CGFloat, CGRect) -> I, @ViewBuilder identity: @escaping (AnyView, CGFloat, CGRect) -> R) {
        self.active = { AnyView(active($0, $1, $2)) }
        self.identity = { AnyView(identity($0, $1, $2)) }
    }
    
    public init<I: View>(@ViewBuilder _ active: @escaping (AnyView, CGFloat, CGRect) -> I) {
        self.active = { AnyView(active($0, $1, $2)) }
        self.identity = { AnyView(active($0, 1 - $1, $2)) }
    }
    
    static func active<I: View>(active: @escaping (AnyView, CGFloat, CGRect) -> I) -> InteractiveTransition {
        .init(active)
    }
    
    public init() {
        active = { view, _, _ in view }
        identity = { view, _, _ in view }
    }
    
    public func active<V: View>(view: V, progress: CGFloat, frame: CGRect) -> AnyView {
        self.active(AnyView(view), progress, frame)
    }
    
    public func identity<V: View>(view: V, progress: CGFloat, frame: CGRect) -> AnyView {
        self.identity(AnyView(view), progress, frame)
    }
}

extension InteractiveTransition {
    
    public static var identity: InteractiveTransition {
        InteractiveTransition()
    }
    
    public func combined(with transition: InteractiveTransition) -> InteractiveTransition {
        InteractiveTransition(
            active: {
                transition.active(view: active(view: $0, progress: $1, frame: $2), progress: $1, frame: $2)
            },
            identity: {
                transition.identity(view: identity(view: $0, progress: $1, frame: $2), progress: $1, frame: $2)
            }
        )
    }
    
    public static func asymmetric(insertion: InteractiveTransition, removal: InteractiveTransition) -> InteractiveTransition {
        .init(active: insertion.active, identity: removal.identity)
    }
    
    public static func move(edge: Edge) -> InteractiveTransition {
        .init { view, progress, frame in
            switch edge {
            case .leading: view.offset(x: -frame.width * (1 - progress), y: 0)
            case .trailing: view.offset(x: frame.width * (1 - progress), y: 0)
            case .top: view.offset(x: 0, y: -frame.height * (1 - progress))
            case .bottom: view.offset(x: 0, y: frame.height * (1 - progress))
            }
        }
    }
    
    public func moved(edge: Edge) -> InteractiveTransition {
        combined(with: .move(edge: edge))
    }
    
    public static func offset(_ offset: CGPoint) -> InteractiveTransition {
        .init { view, progress, _ in
            view.offset(x: offset.x * (1 - progress), y: offset.y * (1 - progress))
        }
    }
    
    public static func offset(x: CGFloat = 0, y: CGFloat = 0) -> InteractiveTransition {
        offset(CGPoint(x: x, y: y))
    }
    
    public func offset(x: CGFloat = 0, y: CGFloat = 0) -> InteractiveTransition {
        combined(with: .offset(CGPoint(x: x, y: y)))
    }
    
    public func offset(_ offset: CGPoint) -> InteractiveTransition {
        combined(with: .offset(offset))
    }
    
    public static func scale(_ scale: CGSize, anchor: UnitPoint = .center) -> InteractiveTransition {
        .active { view, progress, _ -> AnyView in
            let size =  CGSize(
                width: scale.width + (1 - scale.width) * progress,
                height: scale.height + (1 - scale.height) * progress
            )
            return AnyView(view.scaleEffect(size, anchor: anchor))
        }
    }
    
    public static func scale(_ scale: CGFloat = 0.00001, anchor: UnitPoint = .center) -> InteractiveTransition {
        .scale(CGSize(width: scale, height: scale), anchor: anchor)
    }
    
    public func scaled(_ scale: CGFloat, anchor: UnitPoint = .center) -> InteractiveTransition {
        combined(with: .scale(CGSize(width: scale, height: scale), anchor: anchor))
    }
    
    public func scaled(_ scale: CGSize, anchor: UnitPoint = .center) -> InteractiveTransition {
        combined(with: .scale(scale, anchor: anchor))
    }
    
    public static var opacity: InteractiveTransition {
        .init { view, progress, _ in
            view.opacity(Double(progress))
        }
    }
    
    public var opacity: InteractiveTransition {
        combined(with: .opacity)
    }
    
    public var reversed: InteractiveTransition {
        .init(
            active: { active(view: $0, progress: 1 - $1, frame: $2) },
            identity: { identity(view: $0, progress: 1 - $1, frame: $2) }
        )
    }
    
    public func transition(frame: CGRect, progress: CGFloat = 1) -> AnyTransition {
        .asymmetric(
            insertion: .modifier(active: modifier(.show, 0, frame), identity: modifier(.show, progress, frame)),
            removal: .modifier(active: modifier(.hide, progress, frame), identity: modifier(.hide, 0, frame))
        )
    }
    
    private func modifier(_ type: FlowChangeType, _ progress: CGFloat, _ frame: CGRect) -> InteractiveTransitionUnitModifier {
        InteractiveTransitionUnitModifier(transition: self, frame: frame, state: .init(progress: progress, type: type))
    }
}

public struct InteractiveTransitionModifier: ViewModifier {
    
    let transition: InteractiveTransition
    let frame: CGRect
    @Environment(\.interactivePosition) var position
    
    @ViewBuilder
    public func body(content: Content) -> some View {
        if let state = position {
            switch state.type {
            case .show: transition.identity(view: content, progress: state.progress, frame: frame)
            case .hide: transition.active(view: content, progress: state.progress, frame: frame)
            }
        } else {
            content//.transition(anyTransition)
        }
    }
    
    private var anyTransition: AnyTransition {
        position.map { transition.transition(frame: frame, progress: $0.progress) } ?? .identity
    }
}

private struct InteractiveTransitionUnitModifier: ViewModifier {
    let transition: InteractiveTransition
    let frame: CGRect
    var state: InteractivePosition
    
    @ViewBuilder
    func body(content: Content) -> some View {
        switch state.type {
        case .show: transition.active(view: content, progress: state.progress, frame: frame)
        case .hide: transition.identity(view: content, progress: state.progress, frame: frame)
        }
    }
}

private struct InteractiveTransitionFramedModifier: ViewModifier {
    let transition: InteractiveTransition
    @State private var frame: CGRect = .zero
    
    func body(content: Content) -> some View {
        content
            .bindFrame(in: .global, to: $frame)
            .interactiveTransition(transition, frame: frame)
    }
}

public struct InteractivePosition: Hashable {
    public var progress: CGFloat
    public var type: FlowChangeType
}

enum InteractiveProgressKey: EnvironmentKey {
    static var defaultValue: InteractivePosition? { nil }
}

extension EnvironmentValues {
    public var interactivePosition: InteractivePosition? {
        get { self[InteractiveProgressKey.self] }
        set { self[InteractiveProgressKey.self] = newValue }
    }
}

extension View {
    
    public func interactiveTransition(_ transition: InteractiveTransition, frame: CGRect) -> some View {
        modifier(InteractiveTransitionModifier(transition: transition, frame: frame))
    }
    
    public func interactiveTransition(_ transition: InteractiveTransition) -> some View {
        modifier(InteractiveTransitionFramedModifier(transition: transition))
    }
    
    public func interactivePosition(_ progress: CGFloat, type: FlowChangeType) -> some View {
        environment(\.interactivePosition, .init(progress: progress, type: type))
    }
    
    public func interactivePosition(_ position: InteractivePosition?) -> some View {
        environment(\.interactivePosition, position)
    }
}
#endif
