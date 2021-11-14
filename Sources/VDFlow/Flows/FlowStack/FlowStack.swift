//
//  File.swift
//  
//
//  Created by Данил Войдилов on 14.08.2021.
//

#if canImport(UIKit)
import SwiftUI
import IterableView

public struct FlowStack<Content: IterableView, Background: View, Overlay: View, Selection: Hashable>: View {
    
    private let content: Content
    private let background: Background
    private let overlay: (CGFloat) -> Overlay
    @StateOrBinding private var selection: Selection?
    @Environment(\.flowStackFrontTransition) private var showTransition
    @Environment(\.flowStackBackTransition) private var hideTransition
    @Environment(\.flowStackInteractive) private var interactive
    @State private var interacting: FlowChangeType?
    @State private var progress: CGFloat = 0
    @State private var frame: CGRect = .zero
    private var subviews: [Content.Subview] { content.subviews }
    private var currentIndex: Int? {
        selection.flatMap { TagIndexVisitor.index(of: $0, for: content) } ?? (content.count > 0 ? 0 : nil)
    }
    private var fractionIndex: CGFloat {
        switch interacting {
        case .show: return currentIndex.flatMap { CGFloat($0) + progress } ?? 0
        case .hide: return currentIndex.flatMap { CGFloat($0) - progress } ?? 0
        case .none: return currentIndex.flatMap { CGFloat($0) } ?? 0
        }
    }
    
    public var body: some View {
        if let i = currentIndex {
            ZStack {
                if let interactive = interactive {
                    SwipeView(interactive: interactive, interacting: $interacting, progress: $progress) {
                        shouldBegin(type: $0)
                    } completion: {
                        complete(type: $0)
                    }
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(-1.1)
                }
                
							ForEach(Array(subviews[range(tagIndex: i)].enumerated()), id: \.offset) {
								let (index, view) = $0
                    if index >= i - 1 {
                        background
                            .edgesIgnoringSafeArea(.all)
                            .modifier(modifier(i: i, index: index, isBack: true))
                    }
                    
                    view
                        .modifier(modifier(i: i, index: index, isBack: false))
                }
                
                overlay(fractionIndex)
            }
            .bindGeometry(to: bindFrame)
        }
    }
    
    init(_ selection: StateOrBinding<Selection?>, content: Content, background: Background, overlay: @escaping (CGFloat) -> Overlay) {
        self.background = background
        self.content = content
        self.overlay = overlay
        _selection = selection
    }
    
    private func modifier(i: Int, index: Int, isBack: Bool) -> FSModifier {
        FSModifier(
            index: index,
            count: range(tagIndex: i).upperBound,
            back: isBack,
            frontTransition: isBack ? .opacity : showTransition,
            backTransition: isBack ? .opacity : hideTransition,
            interacting: interacting,
            progress: progress,
            frame: frame
        )
    }
    
    private func range(tagIndex: Int) -> Range<Int> {
        switch interacting {
        case .hide, nil: return 0..<min(subviews.count, tagIndex + 1)
        case .show: return 0..<min(subviews.count, tagIndex + 2)
        }
    }
    
    private func shouldBegin(type: FlowChangeType) -> Bool {
        guard let i = currentIndex else { return false }
        switch type {
        case .hide: return i > 0
        case .show: return i < subviews.count - 1
        }
    }
    
    private func complete(type: FlowChangeType) {
        switch type {
        case .show:
            if let i = currentIndex, i < subviews.count - 1 {
                if let tag = subviews[i + 1].viewTag?.base as? Selection {
                    selection = tag
                }
            }
        case .hide:
            if let i = currentIndex, i > 0 {
                if let tag = subviews[i - 1].viewTag?.base as? Selection {
                    selection = tag
                }
            }
        }
    }
    
    private func bindFrame(proxy: GeometryProxy) {
        let newFrame = proxy.frame(in: .global).inset(by: (-proxy.safeAreaInsets).ui)
        if newFrame != frame {
            frame = newFrame
        }
    }
}

extension FlowStack {
    
    public init(_ selection: Binding<Selection?>, content: Content, background: Background, overlay: @escaping (CGFloat) -> Overlay) {
        self.init(.binding(selection), content: content, background: background, overlay: overlay)
    }
    
    public init(_ selection: Binding<Selection?>, @IterableViewBuilder _ content: () -> Content, @ViewBuilder background: () -> Background, @ViewBuilder overlay: @escaping (CGFloat) -> Overlay) {
        self.init(selection, content: content(), background: background(), overlay: overlay)
    }
}

extension FlowStack where Selection == String {
    
    public init(content: Content, background: Background, overlay: @escaping (CGFloat) -> Overlay) {
        self.init(.state(content.subrange(at: 0..<1).viewTag?.base as? Selection), content: content, background: background, overlay: overlay)
    }
    
    public init(@IterableViewBuilder _ content: () -> Content, @ViewBuilder background: () -> Background, @ViewBuilder overlay: @escaping (CGFloat) -> Overlay) {
        self.init(content: content(), background: background(), overlay: overlay)
    }
}

extension FlowStack where Background == EmptyView {
    
    public init(_ selection: Binding<Selection?>, content: Content, overlay: @escaping (CGFloat) -> Overlay) {
        self.init(selection, content: content, background: EmptyView(), overlay: overlay)
    }
    
    public init(_ selection: Binding<Selection?>, @IterableViewBuilder _ content: () -> Content, @ViewBuilder overlay: @escaping (CGFloat) -> Overlay) {
        self.init(selection, content: content(), background: EmptyView(), overlay: overlay)
    }
}

extension FlowStack where Selection == String, Background == EmptyView {
    
    public init(content: Content, overlay: @escaping (CGFloat) -> Overlay) {
        self.init(content: content, background: EmptyView(), overlay: overlay)
    }
    
    public init(@IterableViewBuilder _ content: () -> Content, @ViewBuilder overlay: @escaping (CGFloat) -> Overlay) {
        self.init(content: content(), overlay: overlay)
    }
}

extension FlowStack where Overlay == EmptyView {
    
    public init(_ selection: Binding<Selection?>, content: Content, background: Background) {
        self.init(.binding(selection), content: content, background: background, overlay: { _ in EmptyView() })
    }
    
    public init(_ selection: Binding<Selection?>, @IterableViewBuilder _ content: () -> Content, @ViewBuilder background: () -> Background) {
        self.init(selection, content: content(), background: background())
    }
}

extension FlowStack where Selection == String, Overlay == EmptyView {
    
    public init(content: Content, background: Background) {
        self.init(.state(content.subrange(at: 0..<1).viewTag?.base as? Selection), content: content, background: background, overlay: { _ in EmptyView() })
    }
    
    public init(@IterableViewBuilder _ content: () -> Content, @ViewBuilder background: () -> Background) {
        self.init(content: content(), background: background())
    }
}

extension FlowStack where Background == EmptyView, Overlay == EmptyView {
    
    public init(_ selection: Binding<Selection?>, content: Content) {
        self.init(selection, content: content, background: EmptyView(), overlay: { _ in EmptyView() })
    }
    
    public init(_ selection: Binding<Selection?>, @IterableViewBuilder _ content: () -> Content) {
        self.init(selection, content: content())
    }
}

extension FlowStack where Selection == String, Background == EmptyView, Overlay == EmptyView {
    
    public init(content: Content) {
        self.init(content: content, background: EmptyView(), overlay: { _ in EmptyView() })
    }
    
    public init(@IterableViewBuilder _ content: () -> Content) {
        self.init(content: content())
    }
}
#endif
