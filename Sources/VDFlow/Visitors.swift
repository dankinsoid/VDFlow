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
			if tag != nil, let result = current.first(where: { $0.anyFlowId?.inner == tag?.inner }) {
				if let host = result as? UIHostingController<V> {
					host.rootView = value
				}
				new.append(result)
			} else {
				let host = ObservableHostingController(rootView: value)
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

public final class TagIndexVisitor: IterableViewVisitor {
	var id: AnyHashable
	private(set) public var index: Int?
	private var i = 0
	
	public init(upTo id: AnyHashable) {
		self.id = id
	}
	
	public func visit<V: View>(_ value: V) -> Bool {
		if index == nil {
			let tag = value.viewTag
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
	
	public static func index<I: IterableView>(of tag: AnyHashable, for iterable: I) -> Int? {
		let visitor = TagIndexVisitor(upTo: tag)
		_ = iterable.iterate(with: visitor)
		return visitor.index
	}
}

final class FirstViewControllerVisitor: IterableViewVisitor {
	var vc: UIViewController?
	
	func visit<V: View>(_ value: V) -> Bool {
		guard vc == nil else { return false }
		vc = ObservableHostingController(rootView: value)
		if let tag = value.viewTag {
			vc?.setFlowId(tag)
		}
		return false
	}
}
