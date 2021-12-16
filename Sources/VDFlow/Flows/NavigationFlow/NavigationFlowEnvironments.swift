//
//  File.swift
//  
//
//  Created by Данил Войдилов on 12.05.2021.
//

#if canImport(UIKit)
import UIKit
import SwiftUI

extension EnvironmentValues {
	public struct NavigationFlow {
		public var createController: () -> UINavigationFlowController = UINavigationFlowController.init
		public var barColor = Color.clear
		public var barShadowColor = Color.clear
		public var largeTitleFont: UIFont?
		public var largeTitleColor: Color?
		public var largeTitleMode: UINavigationItem.LargeTitleDisplayMode = .automatic
		public var prefersLargeTitle = true
		public var titleFont: UIFont?
		public var titleColor: Color?
		public var backImage: UIImage?
		public var showBackText = false
		public var barPadding: EdgeInsets?
		public var barAccentColor = Color.accentColor
		public var hidesBarsWhenVerticallyCompact = false
		public var hidesBarsOnTap = false
		public var hidesBarsOnSwipe = false
		public var hidesBarsWhenKeyboardAppears = false
		public var hidesBottomBarWhenPushed = false
		
		public init() {}
	}
}

private enum NavigationFlowKey: EnvironmentKey {
	static var defaultValue: EnvironmentValues.NavigationFlow { .init() }
}

private enum InsideNavigationFlowKey: EnvironmentKey {
	static var defaultValue: Bool { false }
}

private enum TagEnvironmentKey: EnvironmentKey {
	static let defaultValue: NavigationTag = NavigationTag()
}

extension EnvironmentValues {
	public var navigationFlow: NavigationFlow {
		get { self[NavigationFlowKey.self] }
		set { self[NavigationFlowKey.self] = newValue }
	}
	
	var isInsideNavigationFlow: Bool {
		get { self[InsideNavigationFlowKey.self] }
		set { self[InsideNavigationFlowKey.self] = newValue }
	}
	
	var navigationFlowEnvironment: NavigationFlowEnvironment {
		get { self[NavigationFlowEnvironment.Key.self] }
		set { self[NavigationFlowEnvironment.Key.self] = newValue }
	}
	
	var tag: NavigationTag {
		get { self[TagEnvironmentKey.self] }
		set { self[TagEnvironmentKey.self] = newValue }
	}
}

struct NavigationTag: Hashable {
	var tags: [AnyHashable] = []
}

extension View {
	
	public func navigationFlow(transform: @escaping (inout EnvironmentValues.NavigationFlow) -> Void) -> some View {
		transformEnvironment(\.navigationFlow, transform: transform)
	}
	
	public func navigationFlow<T>(_ keyPath: WritableKeyPath<EnvironmentValues.NavigationFlow, T>, _ value: T) -> some View {
		navigationFlow {
			$0[keyPath: keyPath] = value
		}
	}
}

final class NavigationFlowEnvironment {
	
	var children: [NavigationTag: ([UIViewController]) -> [UIViewController]] = [:]
	var update: (EnvironmentValues, Transaction) -> Void = { _, _ in }
	var didShow: [NavigationTag: (AnyHashable) -> Void] = [:]
	
	enum Key: EnvironmentKey {
		static let defaultValue = NavigationFlowEnvironment()
	}
}
#endif
