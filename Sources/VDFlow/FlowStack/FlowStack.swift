//
//  File.swift
//  
//
//  Created by Данил Войдилов on 14.08.2021.
//

import SwiftUI
import VDKit

public struct FlowStack<Content: IterableView, Background: View, Selection: Hashable>: View {
    
    private let subviews: [Content.Subview]
    private let background: Background
    @Binding private var selection: Selection
    @Environment(\.flowStackFrontTransition) private var showTransition
    @Environment(\.flowStackBackTransition) private var hideTransition
    @Environment(\.flowStackInteractive) private var interactive
    @State private var interacting: FlowChangeType?
    @State private var progress: CGFloat = 0
    @State private var frame: CGRect = .zero
    private var currentIndex: Int? {
        subviews.firstIndex(where: { ($0.viewTag?.base as? Selection) == selection })
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
                
                for (index, view) in subviews[range(tagIndex: i)].enumerated() {
                    
                    if index >= i - 1 {
                        background
                            .edgesIgnoringSafeArea(.all)
                            .modifier(modifier(i: i, index: index, isBack: true))
                    }
                    
                    view
                        .modifier(modifier(i: i, index: index, isBack: false))
                }
            }
            .bindGeometry(to: bindFrame)
        }
    }
    
    public init(_ selection: Binding<Selection>, content: Content, background: Background) {
        self.background = background
        subviews = content.subviews
        _selection = selection
    }
    
    public init(_ selection: Binding<Selection>, @IterableViewBuilder _ content: () -> Content, @ViewBuilder background: () -> Background) {
        self.init(selection, content: content(), background: background())
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

extension FlowStack where Background == EmptyView {
    
    public init(_ selection: Binding<Selection>, content: Content) {
        self.init(selection, content: content, background: EmptyView())
    }
    
    public init(_ selection: Binding<Selection>, @IterableViewBuilder _ content: () -> Content) {
        self.init(selection, content: content(), background: EmptyView())
    }
}
