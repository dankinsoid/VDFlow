//
//  File.swift
//  
//
//  Created by Данил Войдилов on 06.05.2021.
//

#if canImport(UIKit)
import UIKit
import IterableView
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
		visitTagged(TaggedView(value, i: i)) { _, _ in []}
	}
	
	func iterate<C: Collection, T: View>(_ value: C, inner: ([UIViewController], NavigationTag) -> [UIViewController]) where C.Element == TaggedView<T> {
		for value in value {
			if !visitTagged(value, inner: inner) {
				return
			}
		}
	}
	
	private func visitTagged<V: View>(_ value: TaggedView<V>, inner: ([UIViewController], NavigationTag) -> [UIViewController]) -> Bool {
		if index == nil {
			let tag = value.tag
			let tags = NavigationTag(tags: value.tags.tags + [value.tag])
			let vc: UIViewController
			if let result = current.first(where: { $0.anyFlowId == tag }) {
				if let host = result as? UIHostingController<TaggedView<V>> {
					host.rootView = value
				}
				vc = result
			} else {
				let _vc = ObservableHostingController(rootView: value)
				vc = _vc
				_vc.rootView.onChange = {[weak _vc] in
					_vc?.inner = $0
				}
				vc.setFlowId(tag)
			}
			new.append(vc)
			new += inner(current, tags)
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
			let tag = value.viewTag ?? AnyHashable(i)
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
		let tag = value.viewTag ?? AnyHashable(0)
		vc?.setFlowId(tag)
		return false
	}
}
#endif
