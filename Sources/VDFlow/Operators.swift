//
//  Operators.swift
//  FlowStart
//
//  Created by Daniil on 27.10.2020.
//

import UIKit

extension FlowComponent {
	
	public func identified(by id: NodeID<Value, ID>) -> IdentifiedFlow<Self> {
		IdentifiedFlow(flowId: id.id, component: self)
	}
	
	public func map<R>(value: @escaping (R) -> Value) -> MapFlow<Self, R> {
		MapFlow<Self, R>(component: self, map: value)
	}
	
	public func map<R>(value: KeyPath<R, Value>) -> MapFlow<Self, R> {
		MapFlow<Self, R>(component: self, map: { $0[keyPath: value] })
	}
	
	public func custom<E, ID: Hashable>(id: NodeID<E, ID>, _ action: @escaping (Content, E?, @escaping (Bool) -> Void) -> Void) -> CustomFlow<Self, E, ID> {
		CustomFlow<Self, E, ID>(root: self, id: id, action)
	}
	
	public func custom<E, ID: Hashable>(id: NodeID<E, ID>, _ action: @escaping (Content, @escaping (Bool) -> Void) -> Void) -> CustomFlow<Self, E, ID> {
		CustomFlow<Self, E, ID>(root: self, id: id) { content, _, completion in action(content, completion) }
	}
	
	public func custom<E, ID: Hashable>(id: NodeID<E, ID>, _ action: @escaping (@escaping (Bool) -> Void) -> Void) -> CustomFlow<Self, E, ID> {
		CustomFlow<Self, E, ID>(root: self, id: id) { _, _, completion in action(completion) }
	}
	
	public func openURL() -> CustomFlow<Self, URL, String> {
		custom(id: SharedSteps.url) { _, url, completion in
			if let url = url, UIApplication.shared.canOpenURL(url) {
				UIApplication.shared.open(url) { _ in
					completion(true)
				}
			} else {
				completion(false)
			}
		}
	}
}

extension FlowComponent where Value == Void {
	
	public func identified(by id: ID) -> IdentifiedFlow<Self> {
		identified(by: .init(id))
	}
}

extension FlowComponent where Content: UIViewControllerConvertable {
	
	public func present<C: FlowComponent>(over: Bool = false, style presentationStyle: UIModalPresentationStyle? = nil, transition: UIModalTransitionStyle? = nil, present: @escaping PresentClosure = { $0.present($1, animated: $2, completion: $3) }, @FlowBuilder _ builder: () -> C) -> PresentFlow<Self, C> where C.Content: UIViewControllerArrayConvertable {
		PresentFlow(root: self, presentationStyle: presentationStyle, transitionStyle: transition, dismissPresented: !over, present: present, component: builder())
	}
	
	public func presentationStyle(_ style: UIModalPresentationStyle) -> VCWrapperComponent<Self> {
		VCWrapperComponent(base: self) { $0.modalPresentationStyle = style }
	}
	
	public func transitionStyle(_ style: UIModalTransitionStyle) -> VCWrapperComponent<Self> {
		VCWrapperComponent(base: self) { $0.modalTransitionStyle = style }
	}
	
	public func tabItem(_ item: UITabBarItem) -> VCWrapperComponent<Self> {
		VCWrapperComponent(base: self) { $0.tabBarItem = item }
	}
	
	public func disableBack() -> VCWrapperComponent<Self> {
		VCWrapperComponent(base: self) {
			if #available(iOS 13.0, *) {
				$0.isModalInPresentation = false
			}
			$0.isDisabledBack = true
		}
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
	
	public func alert<ID: Hashable>(id: NodeID<Void, ID>, title: String?, message: String?, actions: [UIAlertAction]) -> CustomFlow<Self, Void, ID> {
		custom(id: id) { vc, completion in
			let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
			actions.forEach(alertVC.addAction)
			vc.asViewController().vcForPresent.present(alertVC, animated: true, completion: { completion(true) })
		}
	}
	
	public func actionSheet<ID: Hashable>(id: NodeID<Void, ID>, title: String?, message: String?, actions: [UIAlertAction]) -> CustomFlow<Self, Void, ID> {
		custom(id: id) { vc, completion in
			let alertVC = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
			actions.forEach(alertVC.addAction)
			vc.asViewController().vcForPresent.present(alertVC, animated: true, completion: { completion(true) })
		}
	}
	
	public func alert<ID: Hashable>(id: NodeID<AlertConfig, ID>) -> CustomFlow<Self, AlertConfig, ID> {
		custom(id: id) { vc, config, completion in
			vc.asViewController().presentAlert(config: config, completion: { completion(true) })
		}
	}
}

extension FlowComponent where Content: UIWindow {
	
	public func alert() -> CustomFlow<Self, AlertConfig, String> {
		custom(id: SharedSteps.alert) { window, config, completion in
			guard let vc = window.rootViewController else {
				completion(false)
				return
			}
			vc.presentAlert(config: config, completion: { completion(true) })
		}
	}
}
