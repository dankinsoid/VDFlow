//
//  File.swift
//  
//
//  Created by Данил Войдилов on 24.11.2021.
//

#if canImport(UIKit)
import UIKit
import SwiftUI
import IterableView

extension UINavigationController {
	
	public func set(viewControllers: [UIViewController], animated: Bool, completion: @escaping () -> Void = {}) {
		guard viewControllers != self.viewControllers, !isSetting else {
			completion()
			return
		}
		if animated, view?.window != nil {
			isSetting = true
			CATransaction.begin()
			CATransaction.setCompletionBlock {
				self.isSetting = false
				completion()
			}
			setViewControllers(viewControllers, animated: true)
			CATransaction.commit()
		} else {
			setViewControllers(viewControllers, animated: false)
			completion()
		}
	}
	
	var strongDelegate: UINavigationControllerDelegate? {
		get { objc_getAssociatedObject(self, &strongDelegateKey) as? UINavigationControllerDelegate }
		set {
			delegate = newValue
			objc_setAssociatedObject(self, &strongDelegateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
	}
	
	var isSetting: Bool {
		get { (objc_getAssociatedObject(self, &isSettingKey) as? Bool) ?? false }
		set { objc_setAssociatedObject(self, &isSettingKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
	}
	
	func update(environment: EnvironmentValues.NavigationFlow) {
		
		navigationBar.set(backgroundColor: environment.barColor.ui)
		navigationBar.set(shadowColor: environment.barShadowColor.ui)
		
		navigationBar.prefersLargeTitles = environment.prefersLargeTitle
		var attsLarge = navigationBar.largeTitleTextAttributes ?? [:]
		attsLarge[.font] = environment.largeTitleFont
		attsLarge[.foregroundColor] = environment.largeTitleColor?.ui
		navigationBar.largeTitleTextAttributes = attsLarge
		navigationBar.standardAppearance.largeTitleTextAttributes = attsLarge
		navigationBar.scrollEdgeAppearance?.largeTitleTextAttributes = attsLarge
		navigationBar.compactAppearance?.largeTitleTextAttributes = attsLarge
		
		var atts = navigationBar.titleTextAttributes ?? [:]
		atts[.font] = environment.titleFont
		atts[.foregroundColor] = environment.titleColor?.ui
		navigationBar.titleTextAttributes = atts
		navigationBar.standardAppearance.titleTextAttributes = atts
		navigationBar.scrollEdgeAppearance?.titleTextAttributes = atts
		navigationBar.compactAppearance?.titleTextAttributes = atts
		
		let backImage = environment.backImage
		navigationBar.backIndicatorImage = backImage
		navigationBar.backIndicatorTransitionMaskImage = backImage
		navigationBar.standardAppearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
		navigationBar.scrollEdgeAppearance?.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
		navigationBar.compactAppearance?.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
		
		navigationBar.tintColor = environment.barAccentColor.ui
		
		if !environment.showBackText {
			navigationBar.backItem?.title = ""
		}
		if let insets = environment.barPadding {
			navigationBar.layoutMargins = UIEdgeInsets(top: insets.top, left: insets.leading, bottom: insets.bottom, right: insets.trailing)
		}
		
		hidesBarsWhenVerticallyCompact = environment.hidesBarsWhenVerticallyCompact
		hidesBarsOnTap = environment.hidesBarsOnTap
		hidesBarsOnSwipe = environment.hidesBarsOnSwipe
		hidesBarsWhenKeyboardAppears = environment.hidesBarsWhenKeyboardAppears
		hidesBottomBarWhenPushed = environment.hidesBottomBarWhenPushed
	}
}

extension UINavigationBar {
	
	func set(backgroundColor: UIColor) {
		isTranslucent = true
		barTintColor = backgroundColor
		self.backgroundColor = backgroundColor
		if #available(iOS 13.0, *) {
			let coloredAppearance = UINavigationBarAppearance()
			coloredAppearance.configureWithOpaqueBackground()
			coloredAppearance.backgroundColor = backgroundColor
			standardAppearance = coloredAppearance
			scrollEdgeAppearance = coloredAppearance
			compactAppearance = coloredAppearance
		}
	}
	
	func set(shadowColor: UIColor) {
		shadowImage = UIImage(color: shadowColor)
		if #available(iOS 13.0, *) {
			standardAppearance.shadowColor = shadowColor
			scrollEdgeAppearance?.shadowColor = shadowColor
			compactAppearance?.shadowColor = shadowColor
		}
	}
}

fileprivate var isSettingKey = "isSettingKey"
fileprivate var strongDelegateKey = "strongDelegateKey"
#endif
