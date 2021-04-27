//
//  File.swift
//  
//
//  Created by Данил Войдилов on 25.04.2021.
//

import UIKit

public struct FlowPare<L: FlowComponent, R: FlowComponent>: FlowComponent {
	
	public typealias Value = Any
	
	public let _0: L
	public let _1: R
	
	public enum Xor {
		case first(L.Content), second(R.Content)
		
		public var first: L.Content? { if case .first(let f) = self { return f } else { return nil } }
		public var second: R.Content? { if case .second(let f) = self { return f } else { return nil } }
	}
	
	public init(_ l: L, _ r: R) {
		_0 = l
		_1 = r
	}
	
	public func create() -> [Xor] {
		[.first(_0.create()), .second(_1.create())]
	}
	
	public func navigate(to step: FlowStep, content: [Xor], completion: @escaping (Bool) -> Void) {
		if _0.contains(step: step), let cont = content.compactMap({ $0.first }).first {
			_0.navigate(to: step, content: cont, completion: completion)
		} else if _1.contains(step: step), let cont = content.compactMap({ $0.second }).first {
			_1.navigate(to: step, content: cont, completion: completion)
		} else {
			completion(false)
		}
	}
	
	public func contains(step: FlowStep) -> Bool {
		_0.contains(step: step) || _1.contains(step: step)
	}
	
	public func canNavigate(to step: FlowStep, content: [Xor]) -> Bool {
		content.reduce(false) {
			switch $1 {
			case .first(let l): return $0 || _0.canNavigate(to: step, content: l)
			case .second(let r): return $0 || _1.canNavigate(to: step, content: r)
			}
		}
	}
	
	public func update(content: [Xor], data: Any?) {
		content.forEach {
			switch $0 {
			case .first(let f): if let v = data as? L.Value? { _0.update(content: f, data: v) }
			case .second(let f): if let v = data as? R.Value? { _1.update(content: f, data: v) }
			}
		}
	}
	
	public func currentNode(content: [Xor]) -> FlowNode? {
		content.last.map {
			switch $0 {
			case .first(let first): return _0.currentNode(content: first) ?? FlowNode(_0.flowId)
			case .second(let second): return _1.currentNode(content: second) ?? FlowNode(_1.flowId)
			}
		}
	}
	
	public func flow(for node: FlowNode, content: [Xor]) -> (AnyPrimitiveFlow, Any)? {
		if _0.contains(step: .init(id: node, data: nil, options: [])) {
			let contents = content.compactMap({ $0.first })
			return contents.map { _0.flow(for: node, content: $0) }.last ?? contents.last.map { (_0, $0) }
		} else if _0.contains(step: .init(id: node, data: nil, options: [])) {
			let contents = content.compactMap({ $0.second })
			return contents.map { _1.flow(for: node, content: $0) }.last ?? contents.last.map { (_1, $0) }
		} else {
			return nil
		}
	}
}

extension FlowPare: ViewControllersListComponent where L.Content: UIViewControllerArrayConvertable, R.Content: UIViewControllerArrayConvertable {
	public var count: Int { _0.asVcList.count + _1.asVcList.count }
	
	public func index(for step: FlowStep) -> Int? {
		_0.asVcList.index(for: step) ?? _1.asVcList.index(for: step).map { _0.asVcList.count + $0 }
	}
	
	public func controllers(current: [UIViewController], upTo: Int?) -> [UIViewController] {
		_0.asVcList.controllers(current: current, upTo: upTo.map { min(_0.asVcList.count - 1 , $0) }) +
		_1.asVcList.controllers(current: current, upTo: upTo.map { $0 - _0.asVcList.count })
	}
	
	public func asViewControllers(contentAny: Any) -> [UIViewController] {
		guard let content = contentAny as? [Xor] else { return [] }
		return content.compactMap { $0.first }.reduce([], { $0 + _0.asVcList.asViewControllers(content: $1) }) +
			content.compactMap { $0.second }.reduce([], { $0 + _1.asVcList.asViewControllers(content: $1) })
	}
	
	public func createContent(from vcs: [UIViewController]) -> Any? {
		let content: Content =
			(_0.asVcList.create(from: vcs).map { [Xor.first($0)] } ?? []) +
			(_1.asVcList.create(from: vcs).map { [Xor.second($0)] } ?? [])
		return content
	}
}

extension FlowPare.Xor: UIViewControllerArrayConvertable where L.Content: UIViewControllerArrayConvertable, R.Content: UIViewControllerArrayConvertable {
	
	public static func create(from vcs: [UIViewController]) -> FlowPare<L, R>.Xor? {
		if let vc = L.Content.create(from: vcs) {
			return .first(vc)
		} else if let vc = R.Content.create(from: vcs) {
			return .second(vc)
		} else {
			return nil
		}
	}
	
	public func asViewControllers() -> [UIViewController] {
		switch self {
		case .first(let f): return f.asViewControllers()
		case .second(let s): return s.asViewControllers()
		}
	}
}

extension FlowPare.Xor: UIViewControllerConvertable where L.Content: UIViewControllerConvertable, R.Content: UIViewControllerConvertable {
	
	public static func create(from vc: UIViewController) -> FlowPare<L, R>.Xor? {
		if let vc = L.Content.create(from: vc) {
			return .first(vc)
		} else if let vc = R.Content.create(from: vc) {
			return .second(vc)
		} else {
			return nil
		}
	}
	
	public func asViewController() -> UIViewController {
		switch self {
		case .first(let f): return f.asViewController()
		case .second(let s): return s.asViewController()
		}
	}
}
