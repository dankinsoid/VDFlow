//
//  OpenURLFlow.swift
//  FlowStart
//
//  Created by Daniil on 08.11.2020.
//

import UIKit

public enum SharedSteps {
	public static let url = FlowID<URL>("appOpenURLFlowID")
	public static let safari = FlowID<URL>("openSafariFlowID")
}

public struct OpenURLFlow: BaseFlow {
	
	public typealias Content = Void
	public typealias Value = FlowStep
	
	public func navigate(to step: FlowStep, content: Void, completion: FlowCompletion) {
		if step.point?.id == SharedSteps.url.id, let url = step.point?.data as? URL, UIApplication.shared.canOpenURL(url) {
			UIApplication.shared.open(url) { _ in
				completion.complete(nil)
			}
		}
	}
	
	public func current(content: Void) -> (AnyFlowComponent, Any)? {
		nil
	}
	
	public func create() -> Void {
		()
	}
	
	public func ifNavigate(to point: FlowPoint) -> AnyFlowComponent? {
		nil
	}
	
}
