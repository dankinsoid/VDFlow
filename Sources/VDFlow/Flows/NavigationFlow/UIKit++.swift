//
//  File.swift
//  
//
//  Created by Данил Войдилов on 14.11.2021.
//
#if canImport(UIKit)
import UIKit

extension UIViewController {
	var isDisabledBack: Bool {
		get { (objc_getAssociatedObject(self, &disableBackKey) as? Bool) ?? false }
		set { objc_setAssociatedObject(self, &disableBackKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
	}
}

private final class Weak<T: AnyObject> {
	weak var value: T?
	
	init(_ value: T?) { self.value = value }
}

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

extension UIColor {
	var alpha: CGFloat {
		cgColor.alpha
	}
}

fileprivate var disableBackKey = "disableBackKey"
#endif
