//
//  File.swift
//  
//
//  Created by Данил Войдилов on 25.11.2021.
//
#if canImport(UIKit)
import UIKit
import SwiftUI

public typealias PresentClosure = (UIViewController, UIViewController, Bool, @escaping () -> Void) -> Void

extension EnvironmentValues {
	public struct PresentFlow {
		public var presentController: PresentClosure = { $0.present($1, animated: $2, completion: $3) }
		public var style: PresentFlowStyle?
		
		public init() {}
	}
}

private enum PresentFlowKey: EnvironmentKey {
	static var defaultValue: EnvironmentValues.PresentFlow { .init() }
}

private enum InsideNavigationFlowKey: EnvironmentKey {
	static var defaultValue: Bool { false }
}

private enum TagEnvironmentKey: EnvironmentKey {
	static let defaultValue: AnyHashable = UUID()
}

extension EnvironmentValues {
	public var presentFlow: PresentFlow {
		get { self[PresentFlowKey.self] }
		set { self[PresentFlowKey.self] = newValue }
	}
}

extension View {
	
	public func presentFlow(transform: @escaping (inout EnvironmentValues.PresentFlow) -> Void) -> some View {
		transformEnvironment(\.presentFlow, transform: transform)
	}
	
	public func presentFlow<T>(_ keyPath: WritableKeyPath<EnvironmentValues.PresentFlow, T>, _ value: T) -> some View {
		presentFlow {
			$0[keyPath: keyPath] = value
		}
	}
}

public enum PresentFlowStyle {
	case native(UIModalPresentationStyle, UIModalTransitionStyle), delegate(UIViewControllerTransitioningDelegate)
}
#endif
