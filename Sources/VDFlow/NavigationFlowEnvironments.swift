//
//  File.swift
//  
//
//  Created by Данил Войдилов on 12.05.2021.
//

import UIKit
import SwiftUI

public struct NavigationFlowModifiers<T: View> {
	let view: T
}

extension View {
	public var navigationFlow: NavigationFlowModifiers<Self> { .init(view: self) }
}

enum NavigationFlowBarColorKey: EnvironmentKey {
	static var defaultValue: Color { .clear }
}

enum NavigationFlowShadowColorKey: EnvironmentKey {
	static var defaultValue: Color { .clear }
}

enum NavigationFlowLargeTitleFontKey: EnvironmentKey {
	static var defaultValue: UIFont? { nil }
}

enum NavigationFlowLargeTitleColorKey: EnvironmentKey {
	static var defaultValue: Color? { nil }
}

enum NavigationFlowLargeTitleKey: EnvironmentKey {
	static var defaultValue: Bool { true }
}

enum NavigationFlowTitleFontKey: EnvironmentKey {
	static var defaultValue: UIFont? { nil }
}

enum NavigationFlowTitleColorKey: EnvironmentKey {
	static var defaultValue: Color? { nil }
}

enum NavigationFlowBackImageKey: EnvironmentKey {
	static var defaultValue: UIImage? { nil }
}

enum NavigationFlowShowBackText: EnvironmentKey {
	static var defaultValue: Bool { false }
}

enum NavigationFlowBarPadding: EnvironmentKey {
	static var defaultValue: EdgeInsets { .init() }
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
	
	public var navigationFlowLargeTitleFont: UIFont? {
		get { self[NavigationFlowLargeTitleFontKey.self] }
		set { self[NavigationFlowLargeTitleFontKey.self] = newValue }
	}
	
	public var navigationFlowLargeTitleColor: Color? {
		get { self[NavigationFlowLargeTitleColorKey.self] }
		set { self[NavigationFlowLargeTitleColorKey.self] = newValue }
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
	
	public var navigationFlowBarPadding: EdgeInsets {
		get { self[NavigationFlowBarPadding.self] }
		set { self[NavigationFlowBarPadding.self] = newValue }
	}
}

extension NavigationFlowModifiers {
	public func barColor(_ color: Color) -> some View {
		view.environment(\.navigationFlowBarColor, color)
	}
	
	public func barShadowColor(_ color: Color) -> some View {
		view.environment(\.navigationFlowBarShadowColor, color)
	}
	
	public func largeTitleFont(_ font: UIFont?) -> some View {
		view.environment(\.navigationFlowLargeTitleFont, font)
	}
	
	public func largeTitleColor(_ color: Color?) -> some View {
		view.environment(\.navigationFlowLargeTitleColor, color)
	}
	
	public func titleFont(_ font: UIFont?) -> some View {
		view.environment(\.navigationFlowTitleFont, font)
	}
	
	public func titleColor(_ color: Color?) -> some View {
		view.environment(\.navigationFlowTitleColor, color)
	}
	
	public func prefersLargeTitle(_ large: Bool) -> some View {
		view.environment(\.navigationFlowLargeTitle, large)
	}
	
	public func backImage(_ image: UIImage?) -> some View {
		view.environment(\.navigationFlowBackImage, image)
	}
	
	public func showBackText(_ show: Bool) -> some View {
		view.environment(\.navigationFlowShowBackText, show)
	}
	
	public func barPadding(_ edges: EdgeInsets) -> some View {
		view.environment(\.navigationFlowBarPadding, edges)
	}
}
