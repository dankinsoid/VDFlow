//
//  File.swift
//  
//
//  Created by Данил Войдилов on 05.12.2021.
//

import Foundation
import SwiftUI

extension View {
	
	public func sheet<Content: View, T, D>(step: StateStep<T>.StepBinding<D>, onDismiss: (() -> Void)? = nil, @ViewBuilder content: @escaping () -> Content) -> some View {
		sheet(isPresented: step.rootBinding[isSelected: step.keyPath], onDismiss: onDismiss) {
			content()
				.stepEnvironment(step.binding)
		}
	}
}
