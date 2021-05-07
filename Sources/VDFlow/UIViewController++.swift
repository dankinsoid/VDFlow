//
//  File.swift
//  
//
//  Created by Данил Войдилов on 23.04.2021.
//

import Foundation
import UIKit

extension UIViewController {
	
	var vcForPresent: UIViewController {
		presentedViewController?.vcForPresent ?? self
	}
	
	public var allPresented: [UIViewController] {
		presentedViewController.map { [$0] + $0.allPresented } ?? []
	}
	
	public func present(_ viewControllers: [UIViewController], animated: Bool, completion: (() -> Void)? = nil) {
		present(viewControllers, dismiss: true, animated: animated, presentClosure: { $0.present($1, animated: $2, completion: $3) }, completion: completion)
	}
	
	func present(_ viewControllers: [UIViewController], dismiss: Bool, animated: Bool, presentClosure: @escaping PresentClosure, completion: (() -> Void)? = nil) {
		let presented = allPresented
		let common = presented.commonPrefix(with: viewControllers)
		let toPresent = Array(viewControllers.dropFirst(common.count))
		if dismiss, presented.count > common.count {
			presented[common.count].dismissSelf(animated: animated) {
				self.present(vcs: toPresent.filter({ $0.view?.window == nil }), animated: animated, presentClosure: presentClosure, completion: completion)
			}
		} else {
			present(vcs: toPresent, animated: animated, presentClosure: presentClosure, completion: completion)
		}
	}
	
	private func present(vcs: [UIViewController], animated: Bool, presentClosure: @escaping PresentClosure, completion: (() -> Void)?) {
		guard !vcs.isEmpty else {
			completion?()
			return
		}
		presentClosure(vcForPresent, vcs[0], animated) {
			self.present(vcs: Array(vcs.dropFirst()), animated: animated, presentClosure: presentClosure, completion: completion)
		}
	}
	
	public func dismissSelf(animated: Bool, completion: (() -> Void)?) {
		guard presentedViewController != nil else {
			dismiss(animated: animated, completion: completion)
			return
		}
		if !animated {
			dismiss(animated: animated) {
				self.dismiss(animated: animated, completion: completion)
			}
		} else {
			dismissPresented(animated: animated) {
				self.dismiss(animated: animated, completion: completion)
			}
		}
	}
	
	public func dismissPresented(animated: Bool, completion: (() -> Void)?) {
		guard presentedViewController != nil else {
			completion?()
			return
		}
		guard animated else {
			dismiss(animated: animated, completion: completion)
			return
		}
		vcForPresent.dismiss(animated: animated) {
			self.dismissPresented(animated: animated, completion: completion)
		}
	}
}

private protocol WrapperId {
	var id: AnyHashable { get }
}

private final class Wrapper<T: Hashable>: WrapperId {
	var value: T
	var id: AnyHashable { value }
	
	init(_ value: T) {
		self.value = value
	}
}

private var flowIdKey = "flowIdKey"

extension NSObject {
	
	func flowId<ID: Hashable>(of type: ID.Type) -> ID? {
		(objc_getAssociatedObject(self, &flowIdKey) as? WrapperId)?.id.base as? ID
	}
	
	func isFlowId<ID: Hashable>(_ id: ID) -> Bool {
		flowId(of: ID.self) == id
	}
	
	func setFlowId<ID: Hashable>(_ id: ID) {
		objc_setAssociatedObject(self, &flowIdKey, Wrapper(id), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
	}
	
	var anyFlowId: AnyHashable? { (objc_getAssociatedObject(self, &flowIdKey) as? WrapperId)?.id }
}

extension Array where Element: NSObject {
	
	func commonPrefix(with array: [Element]) -> [Element] {
		var i = 0
		while i < count, i < array.count, self[i] === array[i] {
			i += 1
		}
		return Array(prefix(i))
	}
}
