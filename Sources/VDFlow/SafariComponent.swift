//
//  SafariComponent.swift
//  FlowStart
//
//  Created by Daniil on 08.11.2020.
//

import UIKit
import SafariServices

public struct SafariComponent: FlowComponent {
	public let url: URL
	public let configuration: SFSafariViewController.Configuration
	
	public init(url: URL, configuration: SFSafariViewController.Configuration = .init()) {
		self.url = url
		self.configuration = configuration
	}
	
	public func create() -> SFSafariViewController {
		SFSafariViewController(url: url, configuration: configuration)
	}
	
	public func update(content: SFSafariViewController, data: Void?) {}
	
}
