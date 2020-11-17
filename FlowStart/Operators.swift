//
//  Operators.swift
//  FlowStart
//
//  Created by Daniil on 27.10.2020.
//

import UIKit

extension FlowComponent {
	
	public func present(_ presentationStyle: UIModalPresentationStyle? = nil, transition: UIModalTransitionStyle? = nil, @FlowBuilder _ builder: () -> FlowArrayConvertable) -> PresentFlow<Self> {
		PresentFlow(root: self, presentationStyle: presentationStyle, transitionStyle: transition, components: builder().asFlowArray())
	}
	
	public func identified(by id: FlowID<Value>) -> IdentifiedComponent<Self> {
		IdentifiedComponent(id: id.id, base: self)
	}
	
}

extension FlowComponent where Content: UIViewController {
	
	public func presentationStyle(_ style: UIModalPresentationStyle) -> VCWrapperComponent<Self> {
		VCWrapperComponent(base: self) { $0.modalPresentationStyle = style }
	}
	
	public func transitionStyle(_ style: UIModalTransitionStyle) -> VCWrapperComponent<Self> {
		VCWrapperComponent(base: self) { $0.modalTransitionStyle = style }
	}
	
	public func tabItem(_ item: UITabBarItem) -> VCWrapperComponent<Self> {
		VCWrapperComponent(base: self) { $0.tabBarItem = item }
	}
	
	public func tabItem(system: UITabBarItem.SystemItem, tag: Int) -> VCWrapperComponent<Self> {
		tabItem(UITabBarItem(tabBarSystemItem: system, tag: tag))
	}
	
	public func tabItem(title: String?, image: UIImage?, selectedImage: UIImage? = nil) -> VCWrapperComponent<Self> {
		tabItem(UITabBarItem(title: title, image: image, selectedImage: selectedImage))
	}
	
	public func tabItem(title: String?, image: UIImage?, tag: Int) -> VCWrapperComponent<Self> {
		tabItem(UITabBarItem(title: title, image: image, tag: tag))
	}
	
	public func title(_ title: String?) -> VCWrapperComponent<Self> {
		VCWrapperComponent(base: self) { $0.title = title }
	}
	
}

public struct IdentifiedComponent<Base: FlowComponent>: WrapperComponentProtocol {
	public let id: String
	public let base: Base
}

public struct VCWrapperComponent<Base: FlowComponent>: WrapperComponentProtocol where Base.Content: UIViewController {
	public let base: Base
	public let wrap: (UIViewController) -> Void
	
	public init(base: Base, wrap: @escaping (UIViewController) -> Void) {
		self.base = base
		self.wrap = wrap
	}
	
	public func create() -> Base.Content {
		let result = base.create()
		wrap(result)
		return result
	}
	
}
