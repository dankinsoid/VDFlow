//
//  File.swift
//  
//
//  Created by Данил Войдилов on 27.04.2021.
//

import Foundation
import UIKit

public struct VCWrapperComponent<Base: FlowComponent>: FlowComponent where Base.Content: UIViewControllerConvertable {
	public typealias Content = Base.Content
	
	public let base: Base
	public var flowId: Base.ID { base.flowId }
	public let wrap: (UIViewController) -> Void
	
	public init(base: Base, wrap: @escaping (UIViewController) -> Void) {
		self.base = base
		self.wrap = wrap
	}
	
	public func create() -> Base.Content {
		let result = base.create()
		wrap(result.asViewController())
		return result
	}
	
	public func update(content: Base.Content, data: Base.Value?) {
		base.update(content: content, data: data)
	}
}

extension VCWrapperComponent: ViewControllersListComponent {
	
	public var count: Int {
		base.asVcList.count
	}
	
	public var ids: [AnyHashable] { base.asVcList.allIds }
	
	public func index(for id: AnyHashable) -> Int? {
		base.asVcList.index(for: id)
	}
	
	public func controllers(current: [UIViewController], upTo: Int?) -> [UIViewController] {
		let result = base.asVcList.controllers(current: current, upTo: upTo)
		result.forEach(wrap)
		return result
	}
	
	public func asViewControllers(contentAny: Any) -> [UIViewController] {
		guard let content = contentAny as? Base.Content else { return [] }
		return base.asVcList.asViewControllers(content: content)
	}
	
	public func createContent(from vcs: [UIViewController]) -> Any? {
		base.asVcList.create(from: vcs)
	}
}

extension FlowComponent where Content: UIViewControllerConvertable {
	public func disableBack() -> VCWrapperComponent<Self> {
		VCWrapperComponent(base: self) {
			$0.isDisabledBack = true
		}
	}
	
	public func viewController(_ action: @escaping (UIViewController) -> Void) -> VCWrapperComponent<Self> {
		VCWrapperComponent(base: self, wrap: action)
	}
}
