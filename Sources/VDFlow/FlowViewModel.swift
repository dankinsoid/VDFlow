//
//  File.swift
//  
//
//  Created by Данил Войдилов on 06.05.2021.
//

import Foundation
import SwiftUI

final class FlowViewModel: ObservableObject {
	static let root = FlowViewModel(.root)
	let tree: FlowTree
	@Published var path: FlowPath = []
	
	func go(to path: FlowPath, from: FlowTree? = nil) {
		let way = (from ?? tree).way(by: path)
		way.forEach {
			$0.0.set($0.1)
		}
		self.path = path
	}
	
	func step(for flow: FlowTree) -> FlowStep? {
		tree.way(by: path).first(where: { $0.0 === flow })?.1
	}
	
	private init(_ tree: FlowTree) { self.tree = tree }
}
