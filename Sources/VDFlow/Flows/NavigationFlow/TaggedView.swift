//
//  SwiftUIView.swift
//  
//
//  Created by Данил Войдилов on 25.11.2021.
//

import SwiftUI

struct TaggedView<Content: View>: View {
	
	let content: Content
	let tag: AnyHashable
	
	init(_ content: Content, i: Int) {
		self.content = content
		tag = content.viewTag ?? AnyHashable(i)
	}
	
	var body: some View {
		content
			.environment(\.tag, tag)
	}
}
