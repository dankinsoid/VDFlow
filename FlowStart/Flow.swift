//
//  Flow.swift
//  FlowStart
//
//  Created by Daniil on 27.10.2020.
//

import Foundation
import UIKit

public enum TestStep {
	public static let start = FlowID<Void>()
	public static let sec = FlowID<Void>()
	public static let third = FlowID<Void>()
	public static let end = FlowID<Void>()
}

public enum Hmm {
	case one, two, wow(Int)
}

struct AppFlow: Flow {
	let window: UIWindow
	
	var root: WindowFlow {
		WindowFlow(window) {
			FlowTest()
		}
	}
	
}

class FlowTest: Flow {
	
	let hmm = Hmm.one
	
	var root: TabFlow {
		TabFlow {
			Component(.green)
				.identified(by: TestStep.start)
			Component(.white)
				.present {
					Component(.red)
				}
				.present {
					Component(.yellow)
						.identified(by: TestStep.sec)
				}
			Component(.blue)
				.identified(by: TestStep.end)
		}
	}
	
	private func component() {
	}
	
	struct Component: FlowComponent {
		
		let color: UIColor
		
		init(_ color: UIColor) {
			self.color = color
		}
		
		public func create() -> UIViewController {
			let result = UIViewController()
			result.loadViewIfNeeded()
			result.view.backgroundColor = color
			result.tabBarItem = .init(title: "tab", image: nil, tag: 0)
			return result
		}
		
	}
	
}

public protocol AnyBaseFlow: AnyFlowComponent {
	func ifNavigate(to point: FlowPoint) -> AnyFlowComponent?
	func current(contentAny: Any) -> (AnyFlowComponent, Any)?
	func navigate(to step: FlowStep, contentAny: Any, completion: FlowCompletion)
}

public protocol BaseFlow: AnyBaseFlow, FlowComponent where Value == FlowStep {
	func current(content: Content) -> (AnyFlowComponent, Any)?
	func navigate(to step: FlowStep, content: Content, completion: FlowCompletion)
}

extension BaseFlow {
	
	public func update(content: Content, data: Value?) {
		guard let data = data else { return }
		navigate(to: data, content: content, completion: .init {_ in })
	}
	
}

extension AnyBaseFlow where Self: BaseFlow {

	public func current(contentAny: Any) -> (AnyFlowComponent, Any)? {
		guard let content = contentAny as? Content else {
			return nil
		}
		return current(content: content)
	}
	
	public func navigate(to step: FlowStep, contentAny: Any, completion: FlowCompletion) {
		guard let content = contentAny as? Content else {
			completion.complete(nil)
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
