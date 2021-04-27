//
//  File.swift
//  
//
//  Created by Данил Войдилов on 23.04.2021.
//

import Foundation
import UIKit

public protocol UIViewControllerArrayConvertable {
	static func create(from vcs: [UIViewController]) -> Self?
	func asViewControllers() -> [UIViewController]
}

public protocol UIViewControllerConvertable: UIViewControllerArrayConvertable {
	static func create(from vc: UIViewController) -> Self?
	func asViewController() -> UIViewController
}

extension UIViewControllerArrayConvertable where Self: UIViewControllerConvertable {
	public static func create(from vcs: [UIViewController]) -> Self? {
		vcs.compactMap { Self.create(from: $0) }.first
	}
	
	public func asViewControllers() -> [UIViewController] {
		[asViewController()]
	}
}

extension UIViewControllerConvertable where Self: UIViewController {
	public static func create(from vc: UIViewController) -> Self? {
		vc as? Self
	}
}

extension Array: UIViewControllerArrayConvertable where Element: UIViewControllerArrayConvertable {
	
	public static func create(from vcs: [UIViewController]) -> Array<Element>? {
		Element.create(from: vcs).map { [$0] }
	}
	
	public func asViewControllers() -> [UIViewController] {
		map({ $0.asViewControllers() }).joined().map { $0 }
	}
}

extension UIViewController: UIViewControllerConvertable {
	
	public func asViewController() -> UIViewController {
		self
	}
	
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
				self.present(vcs: toPresent, animated: animated, presentClosure: presentClosure, completion: completion)
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
		guard presentedViewController == nil else {
			if !animated {
				dismiss(animated: animated) {
					self.dismiss(animated: animated, completion: completion)
				}
				return
			}
			presentedViewController?.dismissSelf(animated: animated, completion: completion)
			return
		}
		dismiss(animated: animated, completion: completion)
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
