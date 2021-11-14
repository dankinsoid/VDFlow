//
//  File.swift
//  
//
//  Created by Данил Войдилов on 21.08.2021.
//

#if canImport(UIKit)
import SwiftUI
import UIKit

struct SwipeView: UIViewRepresentable {
    
    var interactive: FlowStackInteractive
    var interacting: Binding<FlowChangeType?>
    var progress: Binding<CGFloat>
    var shouldBegin: (FlowChangeType) -> Bool
    var completion: (FlowChangeType) -> Void
    
    func makeUIView(context: Context) -> UISwipeView {
        let result = UISwipeView()
        setInstance(result)
        return result
    }
    
    func updateUIView(_ uiView: UISwipeView, context: Context) {
        setInstance(uiView)
        uiView.instance?.driver = InteractiveDriverBinding(interacting: interacting, progress: progress, interactive: interactive) {
            if interactive.hide?.edges.contains(.init($0)) == true {
                completion(.hide)
            } else if interactive.show?.edges.contains(.init($0)) == true {
                completion(.show)
            }
        }
    }
    
    private func setInstance(_ uiView: UISwipeView) {
        let edges = (interactive.hide?.edges ?? []).union(interactive.show?.edges ?? [])
        let startFromEdges = (interactive.hide?.fromEdgeOnly == true ? interactive.hide?.edges ?? [] : [])
            .union(interactive.show?.fromEdgeOnly == true ? interactive.show?.edges ?? [] : [])
        if uiView.instance?.edges != edges {
            uiView.instance = .init(scroll: uiView, edges: edges, startFromEdges: startFromEdges) { edge in
                if interactive.hide?.edges.contains(.init(edge)) == true {
                    return shouldBegin(.hide)
                } else if interactive.show?.edges.contains(.init(edge)) == true {
                    return shouldBegin(.show)
                } else {
                    return false
                }
            }
            uiView.reset()
        } else {
            uiView.instance?.startFromEdges = startFromEdges
        }
    }
}

final class UISwipeView: UIScrollView, UIScrollViewDelegate {
    
    private let content = UIView()
    private var contentConstraints: [NSLayoutConstraint] = []
    private var isFirstLayout = true
    
    var instance: Instance?
    var edges: Edge.Set { instance?.edges ?? [] }
    var initialOffset: CGPoint {
        CGPoint(
            x: edges.contains(.trailing) ? frame.width : 0,
            y: edges.contains(.bottom) ? frame.height : 0
        )
    }
    
    init() {
        super.init(frame: .zero)
        afterInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func afterInit() {
        alpha = 0
        isPagingEnabled = true
        contentInsetAdjustmentBehavior = .never
        isUserInteractionEnabled = false
        isDirectionalLockEnabled = true
        
        addSubview(content)
        content.frame.size = CGSize(width: frame.width * 2, height: frame.height)
        content.translatesAutoresizingMaskIntoConstraints = false
        content.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        content.topAnchor.constraint(equalTo: topAnchor).isActive = true
        content.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        content.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        instance?.didScroll()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        instance?.didEndDecelerating()
        reset()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        instance?.willBeginDragging()
    }
    
    func reset() {
        delegate = nil
        panGestureRecognizer.isEnabled = true
        alwaysBounceVertical = edges.contains(.top) || edges.contains(.bottom)
        alwaysBounceHorizontal = edges.contains(.trailing) || edges.contains(.leading)
        let k = CGSize(
            width: edges.contains(.horizontal) ? 3 : edges.intersection(.horizontal).isEmpty ? 1 : 2,
            height: edges.contains(.vertical) ? 3 : edges.intersection(.vertical).isEmpty ? 1 : 2
        )
        contentConstraints.forEach { $0.isActive = false }
        contentConstraints = [
            content.widthAnchor.constraint(equalTo: widthAnchor, multiplier: k.width),
            content.heightAnchor.constraint(equalTo: heightAnchor, multiplier: k.height)
        ]
        contentConstraints.forEach { $0.isActive = true }
        
        content.frame.size = CGSize(width: frame.width * k.width, height: frame.height * k.height)
        contentOffset = initialOffset
        delegate = self
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        instance?.shouldBegin(sender: gestureRecognizer) == true && super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        superview?.superview?.addGestureRecognizer(panGestureRecognizer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard isFirstLayout else { return }
        isFirstLayout = false
        reset()
    }
}

extension UISwipeView {
    final class Instance {
        var driver: InteractiveDriver?
        
        let edges: Edge.Set
        var startFromEdges: Edge.Set
        var shouldBegin: (Edge) -> Bool
        private var wasBegan = false
        private var lastPercent: CGFloat?
        private let threshold: CGFloat = 36
        unowned var scroll: UISwipeView
        
        private var percent: CGFloat {
            let dif = scroll.contentOffset - scroll.initialOffset
            if dif.x == 0 {
                return offset / scroll.frame.height
            } else {
                return offset / scroll.frame.width
            }
        }
        
        private var prevEdge: Edge?
        
        var currentEdge: Edge {
            let dif = scroll.contentOffset - scroll.initialOffset
            if dif.x == 0 {
                return dif.y > 0 ? .top : .bottom
            } else {
                return dif.x > 0 ? .leading : .trailing
            }
        }
        
        private var offset: CGFloat {
            var value: CGFloat
            let offset = scroll.contentOffset - scroll.initialOffset
            if offset.x == 0 {
                guard edges.contains(.top) || edges.contains(.bottom) else { return 0 }
                value = offset.y
                if edges.contains(.bottom) && edges.contains(.top) {
                    value = abs(value)
                } else if edges.contains(.bottom) {
                    value = -value
                }
                return value
            } else {
                guard edges.contains(.leading) || edges.contains(.trailing) else { return 0 }
                value = offset.x
                if edges.contains(.trailing) && edges.contains(.leading) {
                    value = abs(value)
                } else if edges.contains(.trailing) {
                    value = -value
                }
                return value
            }
        }
        
        init(scroll: UISwipeView, edges: Edge.Set, startFromEdges: Edge.Set, shouldBegin: @escaping (Edge) -> Bool) {
            self.scroll = scroll
            self.edges = edges
            self.startFromEdges = startFromEdges.intersection(edges)
            self.shouldBegin = shouldBegin
        }
        
        func didScroll() {
            guard scroll.frame.width > 0 else { return }
            let percent = abs(max(0, min(1, self.percent)))
            let edge = currentEdge
            if let prev = prevEdge, edge != prev, !shouldBegin(edge) {
                driver?.update(0, edge: prev)
                return
            }
            driver?.begin(edge: edge)
            prevEdge = edge
            lastPercent = percent
            driver?.update(percent, edge: edge)
        }
        
        func didEndDecelerating() {
            guard driver?.wasBegun == true else { return }
            let percent = self.percent
            lastPercent = percent
            prevEdge = nil
            if percent >= 1 {
                driver?.finish(edge: currentEdge)
                lastPercent = nil
            } else if percent <= 0 {
                driver?.cancel(edge: currentEdge)
                lastPercent = nil
            }
        }
        
        func willBeginDragging() {
            guard driver?.wasBegun == false else { return }
            driver?.begin(edge: currentEdge)
        }
        
        func shouldBegin(sender gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard !startFromEdges.isEmpty else {
                return shouldBegin(edge(gestureRecognizer))
            }
            guard shouldBegin(edge(gestureRecognizer)) else {
                return false
            }
            let size = gestureRecognizer.view?.frame.size ?? scroll.frame.size
            let location = gestureRecognizer.location(in: gestureRecognizer.view ?? scroll)
            
            let edgeInsets = EdgeInsets(
                top: abs(location.y),
                leading: abs(location.x),
                bottom: abs(size.height - location.y),
                trailing: abs(size.width - location.x)
            )
            
            return (
                startFromEdges.contains(.trailing) && edgeInsets.leading < threshold ||
                    startFromEdges.contains(.leading) && edgeInsets.trailing < threshold ||
                    startFromEdges.contains(.top) && edgeInsets.bottom < threshold ||
                    startFromEdges.contains(.bottom) && edgeInsets.top < threshold
            )
        }
        
        private func edge(_ gestureRecognizer: UIGestureRecognizer) -> Edge {
            let velocity = (gestureRecognizer as? UIPanGestureRecognizer)?.velocity(in: scroll) ?? .zero
            if velocity.x > 0, velocity.x > velocity.y {
                return .trailing
            } else if velocity.x < 0, velocity.x < velocity.y {
                return .leading
            } else if velocity.y > 0, velocity.y > velocity.x {
                return .bottom
            } else {
                return .top
            }
        }
    }
}

protocol InteractiveDriver {
    var wasBegun: Bool { get }
    func begin(edge: Edge)
    func cancel(edge: Edge)
    func finish(edge: Edge)
    func update(_ precent: CGFloat, edge: Edge)
}

struct InteractiveDriverBinding: InteractiveDriver {
    
    var wasBegun: Bool { interacting != nil }
    @Binding var interacting: FlowChangeType?
    @Binding var progress: CGFloat
    let interactive: FlowStackInteractive
    var completion: (Edge) -> Void
    
    func begin(edge: Edge) {
        if interactive.hide?.edges.contains(.init(edge)) == true {
            interacting = .hide
        } else if interactive.show?.edges.contains(.init(edge)) == true {
            interacting = .show
        } else {
            return
        }
        progress = 0
    }
    
    func cancel(edge: Edge) {
        progress = 0
        interacting = nil
    }
    
    func finish(edge: Edge) {
        progress = 1
        interacting = nil
        completion(edge)
    }
    
    func update(_ precent: CGFloat, edge: Edge) {
        if interactive.hide?.edges.contains(.init(edge)) == true, interacting == .hide {
            progress = precent
        } else if interactive.show?.edges.contains(.init(edge)) == true, interacting == .show {
            progress = precent
        }
    }
}

public enum FlowChangeType {
    case show, hide
    
    public var inverted: FlowChangeType {
        switch self {
        case .show: return .hide
        case .hide: return .show
        }
    }
}
#endif
