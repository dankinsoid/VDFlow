//
//  File.swift
//  
//
//  Created by Данил Войдилов on 16.11.2021.
//

import SwiftUI

extension NavigationLink {
	
	public init<Dest: View, T, D>(step: StateStep<T>.StepBinding<D>, @ViewBuilder destination: () -> Dest, @ViewBuilder label: () -> Label) where Destination == NavigationStepDestionation<Dest, D> {
		self.init(tag: step.rootBinding.wrappedValue.key(step.keyPath), selection: step.rootBinding.selected.optional) {
			NavigationStepDestionation(content: destination(), stepBinding: step.binding)
		} label: {
			label()
		}
	}
}

public struct NavigationStepDestionation<Content: View, Value>: View {
	
	public let content: Content
	public let stepBinding: Binding<Step<Value>>
	
	public var body: some View {
		content
			.stepEnvironment(stepBinding)
	}
}
