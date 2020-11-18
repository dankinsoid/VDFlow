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
	
	public func custom<E>(id: FlowID<E>, _ action: @escaping (Content, E?, @escaping () -> Void) -> Void) -> CustomFlow<Self, E> {
		CustomFlow<Self, E>(root: self, id: id, action)
	}
	
	public func custom<E>(id: FlowID<E>, _ action: @escaping (Content, @escaping () -> Void) -> Void) -> CustomFlow<Self, E> {
		CustomFlow<Self, E>(root: self, id: id) { content, _, completion in action(content, completion) }
	}
	
	public func custom<E>(id: FlowID<E>, _ action: @escaping (@escaping () -> Void) -> Void) -> CustomFlow<Self, E> {
		CustomFlow<Self, E>(root: self, id: id) { _, _, completion in action(completion) }
	}
	
	public func openURL() -> CustomFlow<Self, URL> {
		custom(id: SharedSteps.url) { _, url, completion in
			if let url = url, UIApplication.shared.canOpenURL(url) {
				UIApplication.shared.open(url) { _ in
					completion()
				}
			} else {
				completion()
			}
		}
	}
	
}

extension FlowComponent where Value == Void {
	
	public func identified(by id: String) -> IdentifiedComponent<Self> {
		IdentifiedComponent(id: id, base: self)
	}
	
	public func identified<R: RawRepresentable>(by id: R) -> IdentifiedComponent<Self> where R.RawValue == String {
		IdentifiedComponent(id: id.rawValue, base: self)
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
	
	public func alert(id: FlowID<Void>, title: String?, message: String?, actions: [UIAlertAction]) -> CustomFlow<Self, Void> {
		custom(id: id) { vc, completion in
			let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
			actions.forEach(alertVC.addAction)
			vc.vcForPresent.present(alertVC, animated: true, completion: completion)
		}
	}
	
	public func actionSheet(id: FlowID<Void>, title: String?, message: String?, actions: [UIAlertAction]) -> CustomFlow<Self, Void> {
		custom(id: id) { vc, completion in
			let alertVC = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
			actions.forEach(alertVC.addAction)
			vc.vcForPresent.present(alertVC, animated: true, completion: completion)
		}
	}
	
	public func alert(id: FlowID<AlertConfig>) -> CustomFlow<Self, AlertConfig> {
		custom(id: id) { vc, config, completion in
			vc.presentAlert(config: config, completion: completion)
		}
	}
	
}

extension FlowComponent where Content: UIWindow {
	
	public func alert() -> CustomFlow<Self, AlertConfig> {
		custom(id: SharedSteps.alert) { window, config, completion in
			guard let vc = window.rootViewController else {
				completion()
				return
			}
			vc.presentAlert(config: config, completion: completion)
		}
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
