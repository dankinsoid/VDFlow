//
//  File.swift
//  
//
//  Created by Данил Войдилов on 05.05.2021.
//

import Foundation
import SwiftUI

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {
	static var bodyString: String {
		if Body.self == Never.self {
			return "Never"
		} else {
			return String(describing: Body.self) + "." + Body.bodyString
		}
	}
	
	var viewTag: AnyHashable? {
		guard Self.self == AnyView.self || Self.bodyString.contains("TagValueTraitKey") else { return nil }
		return _tag
	}
	
	private var _tag: AnyHashable? {
		if let tag = Mirror(reflecting: self).recursive(path: ["modifier", "value", "tagged"]) as? AnyHashable {
			return tag
		}
		guard Body.self != Never.self else { return nil }
		return body._tag
	}
}

extension Mirror {
	
	func recursive<C: Collection>(path: C) -> Any? where C.Element == String {
		guard !path.isEmpty else { return nil }
		var mirror = self
		for (i, key) in path.enumerated() {
			if let child = mirror.children.first(where: { $0.label == key }) {
				if i == path.count - 1 {
					return child.value
				}
				mirror = Mirror(reflecting: child.value)
			} else {
				break
			}
		}
		for (_, value) in children {
			if let result = Mirror(reflecting: value).recursive(path: path) {
				return result
			}
		}
		return nil
	}
}
