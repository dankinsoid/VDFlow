//
//  File.swift
//  
//
//  Created by Данил Войдилов on 12.05.2021.
//

#if canImport(UIKit)
import UIKit
import SwiftUI

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
	static var defaultValue: EdgeInsets? { nil }
}

enum NavigationFlowLargeTitleMode: EnvironmentKey {
	static var defaultValue: UINavigationItem.LargeTitleDisplayMode { .automatic }
}

enum NavigationFlowBarAccentColorKey: EnvironmentKey {
	static var defaultValue: Color { .accentColor }
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
	
	public var navigationFlowBarPadding: EdgeInsets? {
		get { self[NavigationFlowBarPadding.self] }
		set { self[NavigationFlowBarPadding.self] = newValue }
	}
	
	public var navigationFlowLargeTitleMode: UINavigationItem.LargeTitleDisplayMode {
		get { self[NavigationFlowLargeTitleMode.self] }
		set { self[NavigationFlowLargeTitleMode.self] = newValue }
	}
	
	public var navigationFlowBarAccentColor: Color {
		get { self[NavigationFlowBarAccentColorKey.self] }
		set { self[NavigationFlowBarAccentColorKey.self] = newValue }
	}
}

extension View {
	
	public func navigationFlow(barColor color: Color) -> some View {
		environment(\.navigationFlowBarColor, color)
	}
	
	public func navigationFlow(barShadowColor color: Color) -> some View {
		environment(\.navigationFlowBarShadowColor, color)
	}
	
	public func navigationFlow(largeTitleFont font: UIFont?) -> some View {
		environment(\.navigationFlowLargeTitleFont, font)
	}
	
	public func navigationFlow(largeTitleColor color: Color?) -> some View {
		environment(\.navigationFlowLargeTitleColor, color)
	}
	
	public func navigationFlow(titleFont font: UIFont?) -> some View {
		environment(\.navigationFlowTitleFont, font)
	}
	
	public func navigationFlow(titleColor color: Color?) -> some View {
		environment(\.navigationFlowTitleColor, color)
	}
	
	public func navigationFlow(prefersLargeTitle large: Bool) -> some View {
		environment(\.navigationFlowLargeTitle, large)
	}
	
	public func navigationFlow(largeTitleMode mode: UINavigationItem.LargeTitleDisplayMode) -> some View {
		environment(\.navigationFlowLargeTitleMode, mode)
	}
	
	public func navigationFlow(backImage image: UIImage?) -> some View {
		environment(\.navigationFlowBackImage, image)
	}
	
	public func navigationFlow(showBackText show: Bool) -> some View {
		environment(\.navigationFlowShowBackText, show)
	}
	
	public func navigationFlow(barPadding edges: EdgeInsets?) -> some View {
		environment(\.navigationFlowBarPadding, edges)
	}
	
	public func navigationFlow(barAccentColor color: Color) -> some View {
		environment(\.navigationFlowBarAccentColor, color)
	}
}
#endif
