//
//  File.swift
//  
//
//  Created by Данил Войдилов on 24.11.2021.
//

import SwiftUI
import Combine

private struct ChangeObserver<V: Equatable>: ViewModifier {
	init(newValue: V, action: @escaping (V) -> Void) {
		self.newValue = newValue
		self.newAction = action
	}
	
	private typealias Action = (V) -> Void
	
	private let newValue: V
	private let newAction: Action
	
	@State private var state: (V, Action)?
	
	func body(content: Content) -> some View {
		content
			.onAppear()
			.onReceive(Just(newValue)) { newValue in
				if let (currentValue, action) = state, newValue != currentValue {
					action(newValue)
				}
				state = (newValue, newAction)
			}
	}
}

extension View {
	@_disfavoredOverload
	@ViewBuilder func onChange13<V>(of value: V, perform action: @escaping (V) -> Void) -> some View where V: Equatable {
		if #available(iOS 14, *) {
			onChange(of: value, perform: action)
		} else {
			modifier(ChangeObserver(newValue: value, action: action))
		}
	}
}
