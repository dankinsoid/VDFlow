//
//  File.swift
//  
//
//  Created by Данил Войдилов on 14.11.2021.
//
#if canImport(UIKit)
import UIKit

extension UIImage {
	
	convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
		UIGraphicsBeginImageContextWithOptions(size, false, 0)
		color.setFill()
		UIRectFill(CGRect(origin: .zero, size: size))
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		guard let cgImage = image?.cgImage else {
			return nil
		}
		self.init(cgImage: cgImage)
	}
}

extension CGPoint {
	static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
		CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
	}
}
#endif
