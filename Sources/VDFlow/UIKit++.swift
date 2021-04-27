//
//  UIKit++.swift
//  FlowStart
//
//  Created by Данил Войдилов on 18.11.2020.
//

import Foundation
import UIKit

extension UIViewController {
	
	public func presentAlert(config: AlertConfig?, completion: (() -> Void)? = nil) {
		guard let config = config else {
			completion?()
			return
		}
		let alertVC = UIAlertController(title: config.title, message: config.message, preferredStyle: config.style)
		config.buttons.map({ UIAlertAction(title: $0.title, style: $0.style, handler: $0.action.map { a in {_ in a() } }) }).forEach(alertVC.addAction)
		vcForPresent.present(alertVC, animated: true, completion: completion)
	}
}
