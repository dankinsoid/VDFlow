//
//  File.swift
//  
//
//  Created by Данил Войдилов on 04.05.2021.
//

import SwiftUI

public protocol FullScreenUIViewControllerRepresentable: View {
	associatedtype UIViewControllerType: UIViewController
	override associatedtype Body = FullScreenViewControllerView<FullScreenUIViewControllerRepresentableProxy<Self>>
	associatedtype Coordinator = Void
	typealias Context = UIViewControllerRepresentableContext<FullScreenUIViewControllerRepresentableProxy<Self>>
	func makeCoordinator() -> Coordinator
	func makeUIViewController(context: Context) -> UIViewControllerType
	func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context)
	static func dismantleUIViewController(_ uiViewController: UIViewControllerType, coordinator: Coordinator)
}

extension FullScreenUIViewControllerRepresentable {
	public static func dismantleUIViewController(_ uiViewController: UIViewControllerType, coordinator: Coordinator) {}
}

extension FullScreenUIViewControllerRepresentable where Coordinator == Void {
	public func makeCoordinator() -> Coordinator { () }
}

extension FullScreenUIViewControllerRepresentable where Body == FullScreenViewControllerView<FullScreenUIViewControllerRepresentableProxy<Self>> {
	public var body: Body {
		FullScreenViewControllerView(content: FullScreenUIViewControllerRepresentableProxy(content: self))
	}
}

public struct FullScreenUIViewControllerRepresentableProxy<Content: FullScreenUIViewControllerRepresentable>: UIViewControllerRepresentable {
	public typealias UIViewControllerType = Content.UIViewControllerType
	public typealias Coordinator = Content.Coordinator
	public let content: Content
	
	public func makeCoordinator() -> Content.Coordinator {
		content.makeCoordinator()
	}
	
	public func makeUIViewController(context: Context) -> Content.UIViewControllerType {
		content.makeUIViewController(context: context)
	}
	
	public func updateUIViewController(_ uiViewController: Content.UIViewControllerType, context: Context) {
		content.updateUIViewController(uiViewController, context: context)
	}
	
	public static func dismantleUIViewController(_ uiViewController: Content.UIViewControllerType, coordinator: Content.Coordinator) {
		Content.dismantleUIViewController(uiViewController, coordinator: coordinator)
	}
}

public struct FullScreenViewControllerView<Content: UIViewControllerRepresentable>: View {
	let content: Content
	
	public var body: some View {
		content.edgesIgnoringSafeArea(.all)
	}
}
