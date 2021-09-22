//
//  File.swift
//  
//
//  Created by Данил Войдилов on 16.09.2021.
//

import SwiftUI
import VDKit

public struct SwitchView<Content: IterableView, Selection: Hashable>: View {
    
    public let content: Content
    public let selection: Selection
    public var currentIndex: Int? {
        TagIndexVisitor.index(of: selection, for: content)
    }
    
    public var body: some View {
        if let i = currentIndex {
            content.subrange(at: i..<(i + 1))
        }
    }
    
    public init(_ selection: Selection, content: Content) {
        self.content = content
        self.selection = selection
    }
}

extension SwitchView {
    
    public init(_ selection: Selection, @IterableViewBuilder _ content: () -> Content) {
        self.init(selection, content: content())
    }
}
