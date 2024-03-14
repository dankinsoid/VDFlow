import SwiftUI

public struct NavigationSteps<Selection: Hashable, Content: View>: View {
    
    let content: Content
    @StateOrBinding var selection: Selection
    @State private var ids: [Selection] = []
    
    public init(selection: Binding<Selection>, @ViewBuilder content: () -> Content) {
        self.content = content()
        self._selection = .binding(selection)
    }
    
    public var body: some View {
        _VariadicView.Tree(Root(base: self)) {
            content
        }
    }
    
    private struct Root: _VariadicView.UnaryViewRoot {
        
        let base: NavigationSteps
        
        func body(children: _VariadicView.Children) -> some View {
            MyNavigationStack(selection: base.$selection, children: children)
        }
    }
}

public extension NavigationSteps where Selection == Int {
    
    init(@ViewBuilder content: () -> Content) {
        self._selection = StateOrBinding(wrappedValue: 0)
        self.content = content()
    }
}

private struct StepTag: _ViewTraitKey {
    
    static var defaultValue: AnyHashable = Optional<Int>.none
}

public extension _VariadicView.Children.Element {
    
    var stepTag: AnyHashable {
        self[StepTag.self]
    }
}

public extension View {

    func stepTag<Value: Hashable>(_ value: Value) -> some View {
        _trait(StepTag.self, value)
    }
}

private final class UINavigationStackDelegate: NSObject, UINavigationControllerDelegate {
    
    var notUpdate = false
    var didShow: (UIViewController) -> Void = { _ in }
    
    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        didShow(viewController)
    }
}

private struct MyNavigationStack<Selection: Hashable>: UIViewControllerRepresentable {
    
    @Binding var selection: Selection
    let children: _VariadicView.Children
    @State private var delegate = UINavigationStackDelegate()
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let controller = UINavigationController()
        controller.delegate = delegate
        return controller
    }
    
    func updateUIViewController(
        _ stack: UINavigationController,
        context: Context
    ) {
        guard !delegate.notUpdate else { return }
        delegate.didShow = { [weak delegate, $selection] controller in
            if let tag = controller.stackTag?.id.base as? Selection, tag != $selection.wrappedValue {
                delegate?.notUpdate = true
                $selection.wrappedValue = tag
                delegate?.notUpdate = false
            }
        }
        guard let selectedIndex else { return }
        if stack.view.window != nil {
            EnvironmentValues.NavigationPopKey._defaultValue = pop
        }
        stack.setViewControllers(
            controllers(for: stack, selectedIndex: selectedIndex),
            animated: stack.view.window != nil
        )
    }
    
    func controllers(for stack: UINavigationController, selectedIndex: Int) -> [UIViewController] {
        Array(0...selectedIndex).map { i in
            controller(for: i, stack: stack)
        }
    }
    
    func controller(for i: Int, stack: UINavigationController) -> UIViewController {
        let view = children[i]
        if let controller = stack.viewControllers.first(where: { $0.stackID?.id == view.id }) as? Host {
            controller.rootView = Child(content: view, pop: pop)
            return controller
        }
        let controller = Host(rootView: Child(content: view, pop: pop))
        controller.stackID = IDWrapper(children[i].id)
        if let tag = tag(of: view, i) {
            controller.stackTag = IDWrapper(tag)
        }
        return controller
    }
    
    func tag(of child: _VariadicView.Children.Element, _ i: Int) -> Selection? {
        (child.stepTag.base as? Selection) ?? (i as? Selection)
    }
    
    func pop(offset: Int) {
        guard let selectedIndex else { return }
        let newIndex = max(0, min(selectedIndex - offset, children.count - 1))
        guard let tag = tag(of: children[newIndex], newIndex) else { return }
        selection = tag
    }

    var selectedIndex: Int? {
        let tags = children.enumerated().map {
            (tag(of: $0.element, $0.offset), $0.offset)
        }
        guard let i = tags.first(where: { $0.0 == selection })?.1 else {
            return nil
        }
        return i
    }

    typealias Host = UIHostingController<Child>
    
    struct Child: View {
        
        let content: _VariadicView.Children.Element
        let pop: (Int) -> Void
        
        var body: some View {
            content
                .environment(\.pop, pop)
        }
    }
}

extension EnvironmentValues {
    
    enum NavigationPopKey: EnvironmentKey {
        static var _defaultValue: (Int) -> Void = { _ in printPreview("hmm") }
        static let defaultValue: (Int) -> Void = { Self._defaultValue($0) }
    }

    public var pop: (Int) -> Void {
        get { self[NavigationPopKey.self] }
        set { self[NavigationPopKey.self] = newValue }
    }

    public var popToRoot: () -> Void {
        { pop(.max) }
    }

    public var push: (Int) -> Void {
        { pop(-$0) }
    }
}

private extension UIViewController {
    
    var stackID: IDWrapper? {
        get { objc_getAssociatedObject(self, &stackIDKey) as? IDWrapper }
        set { objc_setAssociatedObject(self, &stackIDKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    var stackTag: IDWrapper? {
        get { objc_getAssociatedObject(self, &stackTagKey) as? IDWrapper }
        set { objc_setAssociatedObject(self, &stackTagKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}

private var stackIDKey = 0
private var stackTagKey = 0

private final class IDWrapper {
    var id: AnyHashable
    
    init(_ id: AnyHashable) {
        self.id = id
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
enum NavStackPreview: PreviewProvider {
    
    static var previews: Previews {
        Previews()
    }
    
    struct Previews: View {
        
        @State var selection = 0
        
        var body: some View {
            NavigationSteps(selection: $selection) {
                ForEach(0..<10) { i in
                    Page(i: i, selection: $selection)
                }
            }
            .previewOverlay()
        }
    }
    
    struct Page: View {
        @Environment(\.pop) var pop
        let i: Int
        @Binding var selection: Int
        
        var body: some View {
            HStack {
                if selection > 0 {
                    Button("Pop") {
                        pop(1)
                    }
                }
                Spacer()
                Button("\(i) == \(selection)") {
                    selection = .random(in: 0..<10)
                }
                Spacer()
                if selection < 9 {
                    Button("Push") {
                        pop(-1)
                    }
                }
            }
            .padding()
        }
    }
}

final class PreviewPrintObject: ObservableObject {
    
    static let shared = PreviewPrintObject()
        
    @Published var views: [AnyView] = []
}

func printPreview(@ViewBuilder _ view: () -> some View) {
    PreviewPrintObject.shared.views.append(AnyView(view()))
    PreviewPrintObject.shared.views = Array(PreviewPrintObject.shared.views.suffix(5))
}

func printPreview(_ items: Any?...) {
    printPreview { Text("\(items)" as String) }
}

extension View {
    func previewOverlay() -> some View {
        modifier(PreviewPrintModifier())
    }
}

struct PreviewPrintModifier: ViewModifier {
    
    @ObservedObject private var object = PreviewPrintObject.shared
    
    func body(content: Content) -> some View {
        content.overlay(
            VStack(spacing: 0) {
                ForEach(Array(object.views.enumerated()), id: \.offset) { offset, view in
                    view
                }
            },
            alignment: .bottom
        )
    }
}
