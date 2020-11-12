//
//  Flow.swift
//  FlowStart
//
//  Created by Daniil on 27.10.2020.
//

import Foundation
import UIKit

public enum TestStep {
	public static let start = FlowID<UIColor>()
	public static let sec = FlowID<UIColor>()
	public static let end = FlowID<UIColor>()
}

public enum Hmm {
	case one, two, wow(Int)
}

struct AppFlow: Flow {
	let window: UIWindow
	
	var root: WindowFlow {
		WindowFlow(window) {
			FlowTest().root
		}
	}
	
}

class FlowTest: Flow {
	
	let hmm = Hmm.one
	
	var root: NavigationFlow {
		NavigationFlow {
			Component()
				.present {
					Component()
						.identified(by: TestStep.start)
					Component()
						.identified(by: TestStep.sec)
					Component()
				}
			Component()
				.identified(by: TestStep.end)
		}
	}
	
	private func component() -> Component? {
		nil
	}
	
	struct Component: FlowComponent {
		
		public func create() -> UIViewController {
			let result = UIViewController()
			result.loadViewIfNeeded()
			result.view.backgroundColor = .white
			return result
		}
		
		public func update(content: UIViewController, data: UIColor?) {
			content.view?.backgroundColor = data
		}
		
	}
	
}
public protocol AnyBaseFlow: AnyFlowComponent {
	func ifNavigate(to point: FlowPoint) -> AnyFlowComponent?
	func current(contentAny: Any) -> (AnyFlowComponent, Any)?
	func navigate(to step: FlowStep, contentAny: Any, completion: @escaping ((AnyFlowComponent, Any)?) -> Void)
	func canUpdateAny(content: Any) -> Bool
}

public protocol BaseFlow: AnyBaseFlow, FlowComponent where Value == FlowStep {
	func current(content: Content) -> (AnyFlowComponent, Any)?
	func navigate(to step: FlowStep, content: Content, completion: @escaping ((AnyFlowComponent, Any)?) -> Void)
	func canUpdate(content: Content) -> Bool
}

extension BaseFlow {
	
	public func update(content: Content, data: Value?) {
		guard let data = data else { return }
		navigate(to: data, content: content, completion: {_ in })
	}
	
	public func current(contentAny: Any) -> (AnyFlowComponent, Any)? {
		guard let content = contentAny as? Content else {
			return nil
		}
		return current(content: content)
	}
	
	public func navigate(to step: FlowStep, contentAny: Any, completion: @escaping ((AnyFlowComponent, Any)?) -> Void) {
		guard let content = contentAny as? Content else {
			completion(nil)
			return
		}
		navigate(to: step, content: content, completion: completion)
	}
	
}

public protocol Flow: FlowArrayConvertable {
	associatedtype Root: BaseFlow
	var root: Root { get }
}

extension Flow {
	
	public func asFlowArray() -> [AnyFlowComponent] {
		[root]
	}
	
}
