//
//  NavigationFlow.swift
//  FlowStart
//
//  Created by Daniil on 02.11.2020.
//

import Foundation
import UIKit
import SwiftUI
import VDKit

public struct NavigationFlow<Content: IterableView, Selection: Hashable>: FullScreenUIViewControllerRepresentable {
	
	public let createController: () -> UINavigationController
	public let content: Content
	@Binding private var id: Selection?
	
	public init(create: @escaping () -> UINavigationController, _ selection: Binding<Selection?>, content: Content) {
		createController = create
		self.content = content
		_id = selection
	}
	
	public init(create: @escaping @autoclosure () -> UINavigationController = .init(), _ selection: Binding<Selection?>, @IterableViewBuilder _ builder: () -> Content) {
		self.init(create: create, selection, content: builder())
	}
	
	public init(delegate: UINavigationControllerDelegate, _ selection: Binding<Selection?>, @IterableViewBuilder _ builder: () -> Content) {
		self.init(create: {
			let vc = UINavigationController()
			vc.delegate = delegate
			return vc
		}, selection, content: builder())
	}
	
	public func makeUIViewController(context: Context) -> UINavigationController {
		let vc = createController()
		if let _: (UINavigationController, UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? = vc.delegate?.navigationController {
			vc.strongDelegate = FullDelegate<Selection>(_id, delegate: vc.delegate)
		} else if let _: (UINavigationController, UINavigationController.Operation, UIViewController, UIViewController) -> UIViewControllerAnimatedTransitioning? = vc.delegate?.navigationController {
			vc.strongDelegate = FullDelegate<Selection>(_id, delegate: vc.delegate)
		} else {
			vc.strongDelegate = Delegate<Selection>(_id, delegate: vc.delegate)
		}
		let visitor = FirstViewControllerVisitor()
		_ = content.iterate(with: visitor)
		if let first = visitor.vc {
			vc.setViewControllers([first], animated: false)
		}
		vc.navigationBar.setBackgroundImage(UIImage(), for: .default)
		return vc
	}
	
	public func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
		updateStyle(uiViewController, context: context)
		guard let id = self.id else { return }
		let visitor = ControllersVisitor(current: uiViewController.viewControllers, upTo: id)
		_ = content.iterate(with: visitor)
		guard visitor.index != nil else { return }
	
		var vcs = visitor.new
		if let i = vcs.firstIndex(where: { $0.isDisabledBack }), i > 0 {
			vcs.removeFirst(i - 1)
		}
		guard vcs != uiViewController.viewControllers else { return }
		let animated = FlowStep.isAnimated && uiViewController.view?.window != nil
//		content.dismissPresented(animated: animated) {
		uiViewController.set(viewControllers: vcs, animated: animated)
//		}
	}
	
	private func updateStyle(_ uiViewController: UINavigationController, context: Context) {
		uiViewController.navigationBar.set(backgroundColor: context.environment.navigationFlowBarColor.ui)
		uiViewController.navigationBar.set(shadowColor: context.environment.navigationFlowBarShadowColor.ui)
		var atts = uiViewController.navigationBar.titleTextAttributes ?? [:]
		atts[.font] = context.environment.navigationFlowTitleFont
		atts[.foregroundColor] = context.environment.navigationFlowTitleColor?.ui
		uiViewController.navigationBar.prefersLargeTitles = context.environment.navigationFlowLargeTitle
		uiViewController.navigationBar.backIndicatorImage = context.environment.navigationFlowBackImage
		uiViewController.navigationBar.backIndicatorTransitionMaskImage = context.environment.navigationFlowBackImage
		if !context.environment.navigationFlowShowBackText {
			uiViewController.navigationBar.backItem?.title = ""
		}
	}
}

private class Delegate<ID: Hashable>: NSObject, UINavigationControllerDelegate {
	@Binding var id: ID?
	weak var delegate: UINavigationControllerDelegate?
	
	init(_ id: Binding<ID?>, delegate: UINavigationControllerDelegate?) {
		self._id = id
		self.delegate = delegate
	}
	
	func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
		let newId = viewController.anyFlowId?.base as? ID
		if newId != id {
			id = newId
		}
	}
	
	func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
		delegate?.navigationController?(navigationController, willShow: viewController, animated: animated)
	}
	
	func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
		delegate?.navigationControllerSupportedInterfaceOrientations?(navigationController) ?? .all
	}
	
	func navigationControllerPreferredInterfaceOrientationForPresentation(_ navigationController: UINavigationController) -> UIInterfaceOrientation {
		delegate?.navigationControllerPreferredInterfaceOrientationForPresentation?(navigationController) ?? .portrait
	}
}

private final class FullDelegate<ID: Hashable>: Delegate<ID> {
	
	func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		delegate?.navigationController?(navigationController, interactionControllerFor: animationController)
	}
	
	func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		delegate?.navigationController?(navigationController, animationControllerFor: operation, from: fromVC, to: toVC)
	}
}

extension UINavigationController {
	
	public func set(viewControllers: [UIViewController], animated: Bool, completion: @escaping () -> Void = {}) {
		if animated, view?.window != nil {
			CATransaction.begin()
			CATransaction.setCompletionBlock(completion)
			setViewControllers(viewControllers, animated: true)
			CATransaction.commit()
		} else {
			setViewControllers(viewControllers, animated: false)
			completion()
		}
	}
	
	var strongDelegate: UINavigationControllerDelegate? {
		get { objc_getAssociatedObject(self, &strongDelegateKey) as? UINavigationControllerDelegate }
		set {
			delegate = newValue
			objc_setAssociatedObject(self, &strongDelegateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
	}
}

extension UIViewController {
	var isDisabledBack: Bool {
		get { (objc_getAssociatedObject(self, &disableBackKey) as? Bool) ?? false }
		set { objc_setAssociatedObject(self, &disableBackKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
	}
}

fileprivate var disableBackKey = "disableBackKey"
fileprivate var strongDelegateKey = "strongDelegateKey"

extension UINavigationBar {
	
	func set(backgroundColor: UIColor) {
		isTranslucent = backgroundColor == .clear
		barTintColor = backgroundColor
		if #available(iOS 13.0, *) {
			standardAppearance.backgroundColor = backgroundColor
		}
	}
	
	func set(shadowColor: UIColor) {
		shadowImage = UIImage(color: shadowColor)
		if #available(iOS 13.0, *) {
			standardAppearance.shadowColor = shadowColor
		}
	}
}

enum NavigationFlowBarColorKey: EnvironmentKey {
	static var defaultValue: Color { .clear }
}

enum NavigationFlowShadowColorKey: EnvironmentKey {
	static var defaultValue: Color { .clear }
}

enum NavigationFlowTitleFontKey: EnvironmentKey {
	static var defaultValue: UIFont? { nil }
}

enum NavigationFlowTitleColorKey: EnvironmentKey {
	static var defaultValue: Color? { nil }
}

enum NavigationFlowLargeTitleKey: EnvironmentKey {
	static var defaultValue: Bool { true }
}

enum NavigationFlowBackImageKey: EnvironmentKey {
	static var defaultValue: UIImage? { nil }
}

enum NavigationFlowShowBackText: EnvironmentKey {
	static var defaultValue: Bool { false }
}

extension EnvironmentValues {
	public var navigationFlowBarColor: Color {
		get { self[NavigationFlowBarColorKey.self] }
		set { self[NavigationFlowBarColorKey.self] = newValue }
	}
	
	public var navigationFlowBarShadowColor: Color {
		get { self[NavigationFlowShadowColorKey.self] }
		set { self[NavigationFlowShadowColorKey.self] = newValue }
	}
	
	public var navigationFlowTitleFont: UIFont? {
		get { self[NavigationFlowTitleFontKey.self] }
		set { self[NavigationFlowTitleFontKey.self] = newValue }
	}
	
	public var navigationFlowTitleColor: Color? {
		get { self[NavigationFlowTitleColorKey.self] }
		set { self[NavigationFlowTitleColorKey.self] = newValue }
	}
	
	public var navigationFlowLargeTitle: Bool {
		get { self[NavigationFlowLargeTitleKey.self] }
		set { self[NavigationFlowLargeTitleKey.self] = newValue }
	}
	
	public var navigationFlowBackImage: UIImage? {
		get { self[NavigationFlowBackImageKey.self] }
		set { self[NavigationFlowBackImageKey.self] = newValue }
	}
	
	public var navigationFlowShowBackText: Bool {
		get { self[NavigationFlowShowBackText.self] }
		set { self[NavigationFlowShowBackText.self] = newValue }
	}
}

extension View {
	public func navigationFlowBarColor(_ color: Color) -> some View {
		environment(\.navigationFlowBarColor, color)
	}
	
	public func navigationFlowBarShadowColor(_ color: Color) -> some View {
		environment(\.navigationFlowBarShadowColor, color)
	}
	
	public func navigationFlowTitleFont(_ font: UIFont?) -> some View {
		environment(\.navigationFlowTitleFont, font)
	}
	
	public func navigationFlowTitleColor(_ color: Color?) -> some View {
		environment(\.navigationFlowTitleColor, color)
	}
	
	public func navigationFlowLargeTitle(_ large: Bool) -> some View {
		environment(\.navigationFlowLargeTitle, large)
	}
	
	public func navigationFlowBackImage(_ image: UIImage?) -> some View {
		environment(\.navigationFlowBackImage, image)
	}
	
	public func navigationFlowShowBackText(_ show: Bool) -> some View {
		environment(\.navigationFlowShowBackText, show)
	}
}

extension Color {
	var ui: UIColor {
		if #available(iOS 14.0, *) {
			return UIColor(self)
		} else {
			if self == .clear { return .clear }
			let scanner = Scanner(string: self.description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
			var hexNumber: UInt64 = 0
			var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0
			
			let result = scanner.scanHexInt64(&hexNumber)
			if result {
				r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
				g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
				b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
				a = CGFloat(hexNumber & 0x000000ff) / 255
			}
			return UIColor(red: r, green: g, blue: b, alpha: a)
		}
	}
}
