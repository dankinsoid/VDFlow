//
//  File.swift
//  
//
//  Created by Данил Войдилов on 27.04.2021.
//

import Foundation
import SwiftUI

extension UIHostingController {
	public convenience init(@ViewBuilder _ builder: () -> Content) {
		self.init(rootView: builder())
	}
}
