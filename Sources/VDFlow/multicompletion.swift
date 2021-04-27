//
//  multicompletion.swift
//  FlowStart
//
//  Created by Данил Войдилов on 16.11.2020.
//

import Foundation

func multiCompletion(_ blocks: [(@escaping (Bool) -> Void) -> Void], completion: @escaping (Bool) -> Void) {
	var count = 0
	let all = blocks.count
	guard all > 0 else {
		completion(true)
		return
	}
	var isSuccess = true
	blocks.forEach {
		$0 {
			isSuccess = isSuccess && $0
			count += 1
			if count == all {
				completion(isSuccess)
			}
		}
	}
}
