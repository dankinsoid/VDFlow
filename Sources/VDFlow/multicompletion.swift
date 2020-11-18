//
//  multicompletion.swift
//  FlowStart
//
//  Created by Данил Войдилов on 16.11.2020.
//

import Foundation

func multiCompletion(_ blocks: [(@escaping () -> Void) -> Void], completion: @escaping () -> Void) {
	var count = 0
	let all = blocks.count
	guard all > 0 else {
		completion()
		return
	}
	blocks.forEach {
		$0 {
			count += 1
			if count == all {
				completion()
			}
		}
	}
}
