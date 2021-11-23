//
//  File.swift
//  
//
//  Created by Данил Войдилов on 23.04.2021.
//

#if canImport(UIKit)
import Foundation
import UIKit
import SwiftUI

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

private final class Wrapper {
	var id: AnyHashable
	
	init(_ value: AnyHashable) {
		id = value
	}
}

private var flowIdKey = "flowIdKey"

extension NSObject {
	
	func setFlowId(_ id: AnyHashable) {
		objc_setAssociatedObject(self, &flowIdKey, Wrapper(id), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
	}
	
	var anyFlowId: AnyHashable? { (objc_getAssociatedObject(self, &flowIdKey) as? Wrapper)?.id }
	
	func flowId<T: Hashable>(of type: T.Type) -> T? {
		anyFlowId?.base as? T
	}
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

protocol HostingController: UIViewController {
	var rootAnyView: AnyView { get }
}

extension UIHostingController: HostingController {
	var rootAnyView: AnyView { AnyView(rootView) }
}
#endif
