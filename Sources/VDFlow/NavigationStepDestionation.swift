//
//  File.swift
//  
//
//  Created by Данил Войдилов on 16.11.2021.
//

import SwiftUI

public struct NavigationStepDestionation<Content: View, Root, Value>: View {
	
	public let content: Content
	public let stepBinding: StateStep<Root>.StepBinding<Value>
	
	public var body: some View {
		content
			.stepEnvironment(stepBinding.binding)
	}
}
