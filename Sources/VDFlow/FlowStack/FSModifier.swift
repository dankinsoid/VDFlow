//
//  File.swift
//  
//
//  Created by Данил Войдилов on 21.08.2021.
//

import SwiftUI

struct FSModifier: ViewModifier {
    let index: Int
    let count: Int
    var back: Bool = false
    
    let frontTransition: InteractiveTransition
    let backTransition: InteractiveTransition
    let interacting: FlowChangeType?
    let progress: CGFloat
    let frame: CGRect
    
    var zIndex: Double {
        index(for: Double(count - index) - (back ? 0 : 0.5))
    }
    
    func body(content: Content) -> some View {
        content
            .zIndex(zIndex)
            .interactiveTransition(interactiveTransition, frame: frame)
            .interactivePosition(transitionProgress, type: transitionType)
            .transition(transition)
    }
    
    private func index(for i: Double) -> Double {
        guard count > 0 else { return -1 }
        return -i / Double(count)
    }
    
    private var interactiveTransition: InteractiveTransition {
        if interacting != nil, index >= count - 2 {
            return index >= count - 1 ? frontTransition : backTransition
        } else {
            return backTransition
        }
    }
    
    private var transitionProgress: CGFloat {
        if interacting != nil, index >= count - 2 {
            return progress
        } else if index >= count - 1 {
            return 0
        } else {
            return 1
        }
    }
    
    private var transitionType: FlowChangeType {
        if let interacting = interacting, index >= count - 2 {
            return index >= count - 1 ? interacting.inverted : interacting
        } else {
            return .show
        }
    }
    
    private var transition: AnyTransition {
        if interacting != nil, index >= count - 2 {
            return .identity
        } else if index >= count - 1 {
            return frontTransition.transition(frame: frame)
        } else {
            return frontTransition.transition(frame: frame)
            //            return backTransition.inverted.combined(with: frontTransition).transition(frame: frame)
        }
    }
}

