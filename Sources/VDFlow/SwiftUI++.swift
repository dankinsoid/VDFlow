//
//  File.swift
//  
//
//  Created by Данил Войдилов on 27.04.2021.
//

import Foundation
import UIKit

#if canImport(SwiftUI)
import SwiftUI

@available(iOS 13.0, *)
extension TabFlow: UIViewControllerRepresentable {
	
	public func makeUIViewController(context: Context) -> UITabBarController {
		create()
	}
	
	public func updateUIViewController(_ uiViewController: UITabBarController, context: Context) {}
}

@available(iOS 13.0, *)
extension NavigationFlow: UIViewControllerRepresentable {
	
	public func makeUIViewController(context: Context) -> UINavigationController {
		create()
	}
	
	public func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}

@available(iOS 13.0, *)
extension PresentFlow: UIViewControllerRepresentable {
	
	public func makeUIViewController(context: Context) -> UIViewController {
		create().asViewController()
	}
	
	public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

@available(iOS 13.0, *)
extension View where Self: Flow, Body: Flow {
	public typealias Body = Root
}

@available(iOS 13.0, *)
extension View where Self: Flow, Body: Flow, Body == Root {
	public var Body: Root { root }
}

@available(iOS 13.0, *)
extension FlowBuilder {
	@inline(__always)
	public static func buildExpression<T: View>(_ expression: @escaping @autoclosure () -> T) -> VC<UIHostingController<T>> {
		VC { UIHostingController(rootView: expression()) }
	}
}
#endif
