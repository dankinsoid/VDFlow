//
//  File.swift
//  
//
//  Created by Данил Войдилов on 05.12.2021.
//

import Foundation
import SwiftUI

extension View {
	public func sheet<T>(step: ) -> some View {
		sheet(isPresented: <#T##Binding<Bool>#>, onDismiss: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>, content: <#T##() -> View#>)
		sheet(item: <#T##Binding<Identifiable?>#>, onDismiss: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>, content: <#T##(Identifiable) -> View#>)
	}
}
