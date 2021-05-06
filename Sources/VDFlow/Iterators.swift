//
//  File.swift
//  
//
//  Created by Данил Войдилов on 06.05.2021.
//

import UIKit
import VDKit
import SwiftUI

final class ControllersVisitor: IterableViewVisitor {
	private var current: [UIViewController]
	var id: AnyHashable
	var index: Int?
	var new: [UIViewController] = []
	private var i = 0
	
	init(current: [UIViewController], upTo id: AnyHashable) {
		self.current = current
		self.id = id
	}
	
	func visit<V: View>(_ value: V) -> Bool {
		if index == nil {
			let tag = value.viewTag
			if tag != nil, let result = current.first(where: { $0.anyFlowId == tag }) {
				if let host = result as? UIHostingController<V> {
					host.rootView = value
				}
				new.append(result)
			} else {
				let host = UIHostingController(rootView: value)
				host.setFlowId(tag)
				new.append(host)
			}
			if tag == id {
				index = i
				return false
			} else {
				i += 1
				return true
			}
		} else {
			return false
		}
	}
}

final class FirstViewControllerVisitor: IterableViewVisitor {
	var vc: UIViewController?
	
	func visit<V: View>(_ value: V) -> Bool {
		guard vc == nil else { return false }
		vc = UIHostingController(rootView: value)
		if let tag = value.viewTag {
			vc?.setFlowId(tag)
		}
		return false
	}
}
