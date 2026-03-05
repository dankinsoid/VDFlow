import SwiftUI

/// ``NavigationStack`` wrapper that pushes all children in the order they are declared.
///
/// Set the selection parameter to a bound property that provides the current top view.
/// For example, consider an enumeration of authorizations steps and a State variable to hold the selected step.
///
/// ```swift
/// enum AuthStep: String, CaseIterable, Hashable {
///     case phone, smsCode, emailAndPassword, emailCode
/// }
///
/// @State private var currentAuthStep: AuthStep = .phone
/// ```
/// Append a tag to each of content views using the `stepTag(_:)` view modifier so that the type of each selection matches the type of the bound state variable.
/// ```swift
/// NavigationSteps(selection: $currentAuthStep) {
///     EnterPhoneView()
///         .stepTag(AuthStep.phone)
///
///     EnterSMSCode()
///         .stepTag(AuthStep.smsCode)
///
///     if viewModel.isNewUser {
///         EnterEmailAndPassword()
///             .stepTag(AuthStep.emailAndPassword)
///
///         EnterEmailCode()
///             .stepTag(AuthStep.emailCode)
///     }
/// }
/// ```
///
/// ## Nesting
///
/// Use `nestable: true` to embed one `NavigationSteps` inside another while sharing the same `NavigationStack`.
/// The inner steps are flattened into the parent's navigation path automatically.
///
/// ```swift
/// NavigationSteps(selection: $outerStep) {
///     MainPage().stepTag(Step.main)
///
///     InnerFlow().stepTag(Step.inner)
///
///     FinalPage().stepTag(Step.final)
/// }
///
/// struct InnerFlow: View {
///     @State var step: InnerStep = .a
///     var body: some View {
///         NavigationSteps(selection: $step, nestable: true) {
///             PageA().stepTag(InnerStep.a)
///             PageB().stepTag(InnerStep.b)
///         }
///     }
/// }
/// ```
///
/// - Important: `nestable` relies on the **SwiftUI structural hierarchy** (environment propagation),
///   not the actual UIKit view hierarchy. This means any ancestor `NavigationSteps` in the view tree
///   is detected — even across `sheet` or `fullScreenCover` boundaries. If you present a `nestable`
///   `NavigationSteps` via sheet from within another `NavigationSteps`, it will incorrectly treat
///   the presenting one as its parent and break. Only use `nestable: true` for `NavigationSteps`
///   that are **direct structural descendants** within the same navigation stack.
///
/// - Tip: Use `Environment(\.pop)` environment value to control the pop/push actions:
/// ```swift
/// @Environment(\.pop) var pop
/// //...
/// Button("Go back") {
///   pop()
/// }
/// Button("Go forward") {
///   pop(-1)
/// }
/// Button("Go to start") {
///   pop.toRoot()
/// }
/// ```
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct NavigationSteps<Content: View>: View {

	let content: Content
	@StateOrBinding var selection: AnyHashable
	@State private var pop = PopActionWrapper()
    @Environment(\.hasNavigationStepsAncestor) private var hasNavAncestor
    @Environment(\.parentStepTag) private var parentStepTag
    private let nestableInNavStack: Bool

	public init<Selection: Hashable>(
        selection: Binding<Selection>,
        nestable: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
		self.content = content()
        _selection = .binding(
            Binding(
                get: { selection.wrappedValue },
                set: { selection.wrappedValue = ($0 as? Selection) ?? selection.wrappedValue }
            )
        )
        self.nestableInNavStack = nestable
	}

	public var body: some View {
        if nestableInNavStack, hasNavAncestor {
            _VariadicView.Tree(Nested(base: self, parentStepTag: parentStepTag)) {
                content
            }
        } else {
            _VariadicView.Tree(Root(base: self)) {
                content
            }
            .environment(\.pop, PopAction { offset in pop.pop(offset) })
            .environment(\.hasNavigationStepsAncestor, true)
        }
	}

	private struct Root: _VariadicView.UnaryViewRoot {

		let base: NavigationSteps

		func body(children: _VariadicView.Children) -> some View {
			NavigationStackWrapper(
				selection: base.$selection,
				popAction: base.pop,
				children: children
			)
		}
	}

    private struct Nested: _VariadicView.MultiViewRoot {

        let base: NavigationSteps
        let parentStepTag: AnyHashable

        func body(children: _VariadicView.Children) -> some View {
            if let i = findChild(matching: base.selection, in: children)?.offset {
                let selectionBox = BindingBox(base.$selection)
                ForEach(children.prefix(i + 1)) { child in
                    child
                        .stepTag(TagsPath(parent: parentStepTag, tag: child.stepTag))
                        ._trait(NestedSelectionTrait.self, selectionBox)
                }
            }
        }
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension NavigationSteps {

	init(
        nestable: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
		_selection = .state(0)
		self.content = content()
        self.nestableInNavStack = nestable
	}
}

private final class BindingBox {
    let binding: Binding<AnyHashable>
    init(_ binding: Binding<AnyHashable>) { self.binding = binding }
}

private struct NestedSelectionTrait: _ViewTraitKey {
    static var defaultValue: BindingBox? = nil
}

private struct StepTag: _ViewTraitKey {

	static var defaultValue: AnyHashable = Default()

    struct Default: Hashable {
	}
}

public extension _VariadicView.Children.Element {

	var stepTag: AnyHashable {
		self[StepTag.self]
	}
}

public extension View {

	func stepTag<Value: Hashable>(_ value: Value) -> some View {
        environment(\.parentStepTag, value)
            ._trait(StepTag.self, value)
	}
}

private struct TagsPath: Hashable {

    let parent: AnyHashable
    let tag: AnyHashable

    init(parent: AnyHashable, tag: AnyHashable) {
        self.parent = parent
        self.tag = tag
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct NavigationStackWrapper: View {

	@Binding var selection: AnyHashable
	let popAction: PopActionWrapper
	let children: _VariadicView.Children

	var body: some View {
		NavigationStack(
			path: Binding {
				guard let selectedIndex, selectedIndex > 0 else { return NavigationPath() }
				return NavigationPath(
					(1 ... selectedIndex).compactMap {
                        leafTag(of: children[$0], $0)
					}
				)
			} set: { path in
				guard path.count < children.count else { return }
				select(index: path.count)
			}
		) {
			if !children.isEmpty {
				children[0]
					.navigationDestination(for: AnyHashable.self) { tag in
                        if let child = findChild(matching: tag, in: children)?.element {
							child
						}
					}
			}
		}
		.onAppear {
			popAction.pop = pop
		}
		.onChange(of: selection) { _ in
			popAction.pop = pop
		}
	}

	func pop(offset: Int) {
		guard let selectedIndex else { return }
		let newIndex = max(0, min(selectedIndex - offset, children.count - 1))
        select(index: newIndex)
	}

    func select(index: Int) {
        let child = children[index]
        let leaf = leafTag(of: child, index)
        if let box = child[NestedSelectionTrait.self] {
            box.binding.wrappedValue = leaf
        } else {
            selection = leaf
        }
    }

	var selectedIndex: Int? {
		findLastChild(matching: selection, in: children)?.offset
	}
}

extension EnvironmentValues {

	enum NavigationPopKey: EnvironmentKey {

		static let defaultValue = PopAction { _ in }
	}

	/// Use `Environment(\.pop)` environment value to control the pop/push actions:
	/// ```swift
	/// @Environment(\.pop) var pop
	/// //...
	/// Button("Go back") {
	///   pop()
	/// }
	/// Button("Go forward") {
	///   pop(-1)
	/// }
	/// Button("Go to start") {
	///   pop.toRoot()
	/// }
	/// ```
	public var pop: PopAction {
		get { self[NavigationPopKey.self] }
		set { self[NavigationPopKey.self] = newValue }
	}
}

/// A type that represents a pop action.
public struct PopAction {

	private let pop: (Int) -> Void

	public init(_ pop: @escaping (Int) -> Void) {
		self.pop = pop
	}

	public func callAsFunction(_ offset: Int) {
		pop(offset)
	}

	public func callAsFunction() {
		pop(1)
	}

	public func toRoot() {
		pop(.max)
	}
}

/// Recursively matches selection against a child tag, including TagsPath parent/inner components.
private func tagMatches(_ childTag: AnyHashable, selection: AnyHashable) -> Bool {
    if childTag == selection {
        return true
    }
    if let path = childTag.base as? TagsPath {
        return path.parent == selection || tagMatches(path.tag, selection: selection)
    }
    return false
}

/// Finds the first child whose tag matches selection (accounting for TagsPath nesting).
private func findChild(
    matching selection: AnyHashable,
    in children: _VariadicView.Children
) -> (offset: Int, element: _VariadicView.Children.Element)? {
    children.enumerated().first { i, child in
        let tag = child.stepTag
        let resolved = tag.base is StepTag.Default ? AnyHashable(i) : tag
        return tagMatches(resolved, selection: selection)
    }
}

/// Finds the last child whose tag matches selection.
/// For nested groups the last match corresponds to the current inner step.
private func findLastChild(
    matching selection: AnyHashable,
    in children: _VariadicView.Children
) -> (offset: Int, element: _VariadicView.Children.Element)? {
    var result: (offset: Int, element: _VariadicView.Children.Element)?
    for (i, child) in children.enumerated() {
        let tag = child.stepTag
        let resolved = tag.base is StepTag.Default ? AnyHashable(i) : tag
        if tagMatches(resolved, selection: selection) {
            result = (i, child)
        }
    }
    return result
}

/// Extracts the leaf tag (unwrapping TagsPath wrappers) for use in NavigationPath.
private func leafTag(of child: _VariadicView.Children.Element, _ i: Int) -> AnyHashable {
    resolveLeafTag(child.stepTag, i)
}

private func resolveLeafTag(_ tag: AnyHashable, _ i: Int) -> AnyHashable {
    if tag.base is StepTag.Default {
        return i
    }
    if let path = tag.base as? TagsPath {
        return resolveLeafTag(path.tag, i)
    }
    return tag
}

private final class PopActionWrapper {

	var pop: (Int) -> Void

	init(_ pop: @escaping (Int) -> Void = { _ in }) {
		self.pop = pop
	}
}

extension EnvironmentValues {

    private enum HasNavigationStepsAncestorKey: EnvironmentKey {

        static let defaultValue: Bool = false
    }

    public var hasNavigationStepsAncestor: Bool {
        get { self[HasNavigationStepsAncestorKey.self] }
        set { self[HasNavigationStepsAncestorKey.self] = newValue }
    }

    private enum StepTagKey: EnvironmentKey {

        static let defaultValue: AnyHashable = StepTag.Default()
    }

    var parentStepTag: AnyHashable {
        get { self[StepTagKey.self] }
        set { self[StepTagKey.self] = newValue }
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
				ForEach(0 ..< 10) { i in
					Page(i: i, selection: $selection)
				}
			}
		}
	}

	struct Page: View {
		@Environment(\.pop) var pop
		let i: Int
		@Binding var selection: Int

		var body: some View {
			VStack {
				HStack {
					if selection > 0 {
						Button("Pop") {
							pop()
						}
					}
					Spacer()
					Button("\(i) == \(selection)") {
						selection = .random(in: 0 ..< 10)
					}
					Spacer()
					if selection < 9 {
						Button("Push") {
							pop(-1)
						}
					}
				}
			}
			.padding()
		}
	}
}

// MARK: - Nestable Preview

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
enum NestableNavPreview: PreviewProvider {

    static var previews: NestableRoot {
        NestableRoot()
    }

    enum OuterStep: String, CaseIterable, Hashable {
        case first, second, third
    }

    enum InnerStep: String, CaseIterable, Hashable {
        case a, b, c
    }

    struct NestableRoot: View {

        @State var outerSelection: OuterStep = .first

        var body: some View {
            NavigationSteps(selection: $outerSelection) {
                OuterPage(title: "First", step: .first, selection: $outerSelection)
                    .stepTag(OuterStep.first)

                InnerFlow()
                    .stepTag(OuterStep.second)

                OuterPage(title: "Third", step: .third, selection: $outerSelection)
                    .stepTag(OuterStep.third)
            }
        }
    }

    struct InnerFlow: View {

        @StateStep var selection: InnerStep = .a

        var body: some View {
            NavigationSteps(selection: $selection, nestable: true) {
                InnerPage(title: "A", step: .a, selection: $selection)
                    .stepTag(InnerStep.a)
                
                InnerPage(title: "B", step: .b, selection: $selection)
                    .stepTag(InnerStep.b)
                InnerPage(title: "C", step: .c, selection: $selection)
                    .stepTag(InnerStep.c)
            }
        }
    }

    struct OuterPage: View {
        @Environment(\.pop) var pop
        let title: String
        let step: OuterStep
        @Binding var selection: OuterStep

        var body: some View {
            VStack(spacing: 16) {
                Text("Outer: \(title)")
                    .font(.title)
                Text("selection = \(selection.rawValue)")
                    .foregroundStyle(.secondary)
                HStack {
                    if let prev = OuterStep.allCases.elementBefore(step) {
                        Button("← \(prev.rawValue)") { selection = prev }
                    }
                    Spacer()
                    if let next = OuterStep.allCases.elementAfter(step) {
                        Button("\(next.rawValue) →") { selection = next }
                    }
                }
            }
            .padding()
            .navigationTitle("Outer: \(title)")
        }
    }

    struct InnerPage: View {
        @Environment(\.pop) var pop
        let title: String
        let step: InnerStep
        @Binding var selection: InnerStep

        var body: some View {
            VStack(spacing: 16) {
                Text("Inner: \(title)")
                    .font(.title2)
                    .foregroundStyle(.blue)
                Text("selection = \(selection.rawValue)")
                    .foregroundStyle(.secondary)
                HStack {
                    if let prev = InnerStep.allCases.elementBefore(step) {
                        Button("← \(prev.rawValue)") { selection = prev }
                    }
                    Spacer()
                    Button("Pop") { pop() }
                    Spacer()
                    if let next = InnerStep.allCases.elementAfter(step) {
                        Button("\(next.rawValue) →") { selection = next }
                    }
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .navigationTitle("Inner: \(title)")
        }
    }
}

private extension Collection where Element: Equatable {

    func elementAfter(_ element: Element) -> Element? {
        guard let i = firstIndex(of: element) else { return nil }
        let next = index(after: i)
        return next < endIndex ? self[next] : nil
    }

    func elementBefore(_ element: Element) -> Element? {
        guard let i = firstIndex(of: element), i > startIndex else { return nil }
        return self[index(i, offsetBy: -1)]
    }
}
