//
//  File.swift
//  
//
//  Created by Данил Войдилов on 23.04.2021.
//

import Foundation

struct FlowOptions: OptionSet, Hashable, Codable {
	public static var animated: FlowOptions { FlowOptions(rawValue: 1) }
	public static func offset(_ offset: Int16) -> FlowOptions { FlowOptions(rawValue: UInt32(offset >> 16)) }

	public var rawValue: UInt32
	
	public init(rawValue: UInt32) {
		self.rawValue = rawValue
	}
	
	public var offset: Int {
		get { Int(Int16(rawValue << 16)) }
		set { rawValue = UInt32(UInt16((rawValue >> 16) << 16) & UInt16(Int16(newValue))) }
	}
}
