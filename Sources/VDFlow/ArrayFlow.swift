//
//  ArrayFlow.swift
//  FlowStart
//
//  Created by Daniil on 08.11.2020.
//

import UIKit
import VDKit
import Foundation

public struct ArrayFlow<Component: FlowComponent>: FlowComponent {
	public let array: [Component]
	
	public init(_ array: [Component]) {
		self.array = array
	}
	
	public func create() -> [OneContent] {
		array.map { .init(id: $0.flowId, content: $0.create()) }
	}
	
	public func update(content: [OneContent], data: Component.Value?) {
		content.forEach { arg in
			array.first(where: { $0.flowId == arg.id })?.update(content: arg.content, data: data)
		}
	}
	
	public struct OneContent {
		public var id: Component.ID
		public var content: Component.Content
	}
}

extension ArrayFlow: ViewControllersListComponent where Component.Content: UIViewControllerArrayConvertable {
	public var count: Int { array.reduce(0) { $0 + $1.asVcList.count } }
	public var ids: [AnyHashable] { array.map { $0.asVcList.allIds }.joinedArray() }
	
	public func index(for id: AnyHashable) -> Int? {
		guard let i = array.firstIndex(where: { $0.asVcList.index(for: id) != nil }),
					let ind = array[i].asVcList.index(for: id) else { return nil }
		return array.prefix(i).reduce(0) { $0 + $1.asVcList.count } + ind
	}
	
	public func controllers(current: [UIViewController], upTo: Int?) -> [UIViewController] {
		array.reduce((0, [])) { a, b in
			(a.0 + b.asVcList.count, a.1 + b.asVcList.controllers(current: current, upTo: upTo.map { $0 - a.0 }))
		}.1
	}
	
	public func asViewControllers(contentAny: Any) -> [UIViewController] {
		guard let content = contentAny as? [OneContent] else { return [] }
		let list = content.compactMap { c in
			array.first(where: { $0.flowId == c.id })?.asVcList.asViewControllers(content: c.content)
		}
		return Array(list.joined())
	}
	
	public func createContent(from vcs: [UIViewController]) -> Any? {
		let content: Content = array.compactMap { c in c.asVcList.create(from: vcs).map { .init(id: c.flowId, content: $0) } }
		return content
	}
}

extension ArrayFlow.OneContent: UIViewControllerArrayConvertable where Component.Content: UIViewControllerArrayConvertable {
	
	public static func create(from vcs: [UIViewController]) -> ArrayFlow.OneContent? {
		guard let id = vcs.compactMap({ $0.flowId(of: Component.ID.self) }).first else { return nil }
		return Component.Content.create(from: vcs).map { .init(id: id, content: $0) }
	}
	
	public func asViewControllers() -> [UIViewController] {
		content.asViewControllers()
	}
}

extension ArrayFlow.OneContent: UIViewControllerConvertable where Component.Content: UIViewControllerConvertable {
	
	public static func create(from vc: UIViewController) -> ArrayFlow.OneContent? {
		guard let id = vc.flowId(of: Component.ID.self) else { return nil }
		return Component.Content.create(from: vc).map { .init(id: id, content: $0) }
	}
	
	public func asViewController() -> UIViewController {
		content.asViewController()
	}
}
