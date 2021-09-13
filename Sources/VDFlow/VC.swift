//
//  File.swift
//  
//
//  Created by Данил Войдилов on 08.02.2021.
//

import Foundation
import SwiftUI

public struct VC<Content> {
	private let createClosure: () -> Content
	
	public init(_ create: @escaping () -> Content) {
		createClosure = create
	}
	
	public init(_ create: @escaping @autoclosure () -> Content) {
		createClosure = create
	}
	
	public func create() -> Content {
		createClosure()
	}
}

extension VC: View where Content: UIViewController {
    public typealias Body = FullScreenViewControllerView<FullScreenUIViewControllerRepresentableProxy<Self>>
}

extension VC: FullScreenUIViewControllerRepresentable where Content: UIViewController {
	
	public func makeUIViewController(context: Context) -> Content {
		create()
	}
	
	public func updateUIViewController(_ uiViewController: Content, context: Context) {}
}
