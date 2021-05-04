//
//  File.swift
//  
//
//  Created by Данил Войдилов on 25.04.2021.
//

import UIKit

public struct FlowTuple<L: FlowComponent, R: FlowComponent>: FlowComponent {
	
	public typealias Value = Any
	public typealias Content = [XorValue<L.Content, R.Content>]
	
	public let _0: L
	public let _1: R
	
	public init(_ l: L, _ r: R) {
		_0 = l
		_1 = r
	}
	
	public func create() -> Content {
		[._0(_0.create()), ._1(_1.create())]
	}
	
	public func update(content: Content, data: Any?) {
		content.forEach {
			switch $0 {
			case ._0(let content): _0.update(content: content, data: data as? L.Value)
			case ._1(let content): _1.update(content: content, data: data as? R.Value)
			}
		}
	}
}

public enum XorValue<L, R> {
	case _0(L), _1(R)
	
	public var _0: L? { if case ._0(let value) = self { return value } else { return nil } }
	public var _1: R? { if case ._1(let value) = self { return value } else { return nil } }
}

extension FlowTuple: ViewControllersListComponent where L.Content: UIViewControllerArrayConvertable, R.Content: UIViewControllerArrayConvertable {
	
	public var count: Int { _0.asVcList.count + _1.asVcList.count }
	
	public var ids: [AnyHashable] { _0.asVcList.allIds + _1.asVcList.allIds }
	
	public func index(for id: AnyHashable) -> Int? {
		_0.asVcList.index(for: id) ?? _1.asVcList.index(for: id).map { _0.asVcList.count + $0 }
	}
	
	public func controllers(current: [UIViewController], upTo: Int?) -> [UIViewController] {
		_0.asVcList.controllers(current: current, upTo: upTo) +
		_1.asVcList.controllers(current: current, upTo: upTo.map { $0 - _0.asVcList.count })
	}
	
	public func asViewControllers(contentAny: Any) -> [UIViewController] {
		guard let content = contentAny as? Content else { return [] }
		return content.map { c -> [UIViewController] in
			switch c {
			case ._0(let f): return _0.asVcList.asViewControllers(content: f)
			case ._1(let s): return _1.asVcList.asViewControllers(content: s)
			}
		}.joined().map { $0 }
	}
	
	public func createContent(from vcs: [UIViewController]) -> Any? {
		let content: Content =
			(_0.asVcList.create(from: vcs).map { [._0($0)] } ?? []) +
			(_1.asVcList.create(from: vcs).map { [._1($0)] } ?? [])
		return content
	}
}

extension XorValue: UIViewControllerArrayConvertable where L: UIViewControllerArrayConvertable, R: UIViewControllerArrayConvertable {
	
	public static func create(from vcs: [UIViewController]) -> XorValue? {
		if let vc = L.create(from: vcs) {
			return ._0(vc)
		} else if let vc = R.create(from: vcs) {
			return ._1(vc)
		} else {
			return nil
		}
	}
	
	public func asViewControllers() -> [UIViewController] {
		switch self {
		case ._0(let content): return content.asViewControllers()
		case ._1(let content): return content.asViewControllers()
		}
	}
}

extension XorValue: UIViewControllerConvertable where L: UIViewControllerConvertable, R: UIViewControllerConvertable {
	
	public static func create(from vc: UIViewController) -> XorValue? {
		if let vc = L.create(from: vc) {
			return ._0(vc)
		} else if let vc = R.create(from: vc) {
			return ._1(vc)
		} else {
			return nil
		}
	}
	
	public func asViewController() -> UIViewController {
		switch self {
		case ._0(let content): return content.asViewController()
		case ._1(let content): return content.asViewController()
		}
	}
}
