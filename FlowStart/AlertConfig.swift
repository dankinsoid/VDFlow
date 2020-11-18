//
//  AlertFlow.swift
//  FlowStart
//
//  Created by Daniil on 05.11.2020.
//

import Foundation
import UIKit

public struct AlertConfig {
	public var style: UIAlertController.Style
	public var title: String?
	public var message: String?
	public var buttons: [Button]
	
	public init(style: UIAlertController.Style = .alert, title: String?, message: String? = nil, buttons: [Button] = []) {
		self.style = style
		self.title = title
		self.message = message
		self.buttons = buttons
	}
	
	public func add(button: Button) -> AlertConfig {
		var result = self
		result.buttons.append(button)
		return result
	}
	
	public func addButton(title: String?, style: UIAlertAction.Style = .default, action: (() -> Void)?) -> AlertConfig {
		add(button: Button(title: title, style: style, action: action))
	}
	
	public struct Button {
		public var title: String?
		public var style: UIAlertAction.Style
		public var action: (() -> Void)?
		
		public init(title: String?, style: UIAlertAction.Style = .default, action: (() -> Void)?) {
			self.title = title
			self.style = style
			self.action = action
		}
		
		public static func cancel(title: String?) -> Button {
			Button(title: title, style: .cancel, action: nil)
		}
		
	}
}
