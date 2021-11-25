//
//  File.swift
//  
//
//  Created by Данил Войдилов on 24.11.2021.
//

#if canImport(UIKit)
import SwiftUI
import UIKit

extension View {

	public func onUpdate(action: @escaping (EnvironmentValues, Transaction) -> Void) -> some View {
		background(OnUpdate(onUpdate: action))
	}
	
	public func onUpdate(action: @escaping () -> Void) -> some View {
		onUpdate { _, _ in
			action()
		}
	}
}

private struct OnUpdate: UIViewRepresentable {
	var onUpdate: (EnvironmentValues, Transaction) -> Void
	
	func makeUIView(context: Context) -> UIViewType {
		let view = UIView()
		view.alpha = 0
		view.isUserInteractionEnabled = false
		return view
	}
	
	func updateUIView(_ uiView: UIView, context: Context) {
		onUpdate(context.environment, context.transaction)
	}
}
#endif
