//
//  File.swift
//  
//
//  Created by Данил Войдилов on 27.04.2021.
//

import Foundation
import UIKit
import SwiftUI
import VDKit

public struct ViewFlow<Component: View>: FlowComponent {
	public let view: Component
	public var flowId: AnyHashable? {
		view.viewTag
	}
	
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
