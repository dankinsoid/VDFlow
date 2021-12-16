//
//  File.swift
//  
//
//  Created by Данил Войдилов on 06.12.2021.
//
#if canImport(UIKit)
import Foundation
import UIKit

open class UINavigationFlowController: UINavigationController {
	
	override open func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
		let array = viewControllers.flatMap {
			[$0] + (($0 as? FlatVC)?.inner.create(self.viewControllers) ?? [])
		}
		super.setViewControllers(array, animated: animated)
	}
}
#endif
