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
	
	public func navigate(to step: FlowStep, content: Content, completion: @escaping (Bool) -> Void) {
		if _0.contains(step: step), let cont = content.compactMap({ $0._0 }).last {
			_0.navigate(to: step, content: cont, completion: completion)
		} else if _1.contains(step: step), let cont = content.compactMap({ $0._1 }).last {
			_1.navigate(to: step, content: cont, completion: completion)
		} else {
			completion(false)
		}
	}
	
	public func contains(step: FlowStep) -> Bool {
		_0.contains(step: step) || _1.contains(step: step)
	}
	
	public func canNavigate(to step: FlowStep, content: Content) -> Bool {
		content.reduce(false) {
			switch $1 {
			case ._0(let l): return $0 || _0.canNavigate(to: step, content: l)
			case ._1(let r): return $0 || _1.canNavigate(to: step, content: r)
			}
		}
	}
	
	public func update(content: Content, data: Any?) {
		content.forEach {
			switch $0 {
			case ._0(let content): if let value = data as? L.Value? { _0.update(content: content, data: value) }
			case ._1(let content): if let value = data as? R.Value? { _1.update(content: content, data: value) }
			}
		}
	}
	
	public func children(content: Content) -> [(AnyFlowComponent, Any, Bool)] {
		content.map {
			switch $0 {
			case ._0(let content): return (_0, content, true)
			case ._1(let content): return (_1, content, true)
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
	
	public func index(for step: FlowStep) -> Int? {
		_0.asVcList.index(for: step) ?? _1.asVcList.index(for: step).map { _0.asVcList.count + $0 }
	}
	
	public func controllers(current: [UIViewController], upTo: Int?) -> [UIViewController] {
		_0.asVcList.controllers(current: current, upTo: upTo.map { min(_0.asVcList.count - 1 , $0) }) +
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
