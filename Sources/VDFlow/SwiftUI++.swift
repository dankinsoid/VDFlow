//
//  File.swift
//  
//
//  Created by Данил Войдилов on 27.04.2021.
//

import Foundation
import UIKit
import SwiftUI

extension View {
	public func flowId<ID: Hashable>(_ id: ID) -> ViewFlow<Self, ID> {
		ViewFlow(view: self, flowId: id)
	}
}

extension View where Self: FlowComponent {
	public func flowId<ID: Hashable>(_ id: ID) -> IdentifiedFlow<Self, ID> {
		IdentifiedFlow(flowId: id, component: self)
	}
}

public struct ViewFlow<Component: View, ID: Hashable>: FlowComponent {
	public let view: Component
	public let flowId: ID
	
	public func create() -> UIHostingController<Component> {
		UIHostingController(rootView: view)
	}
	
	public func update(content: UIHostingController<Component>, data: ()?) {
		content.rootView = view
	}
}

extension UIHostingController {
	public convenience init(@ViewBuilder _ builder: () -> Content) {
		self.init(rootView: builder())
	}
}
