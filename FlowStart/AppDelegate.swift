//
//  AppDelegate.swift
//  FlowStart
//
//  Created by Daniil on 27.10.2020.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var flow: FlowCoordinator?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		let w = UIWindow()
		self.window = w
		let coordinator = FlowCoordinator(AppFlow(window: w))
		flow = coordinator
		coordinator.navigate(to: TestStep.start.with(.blue))
		DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//			coordinator.navigate(to: TestStep.sec.with(.green))
			coordinator.navigate(to: FlowMove.next())
			DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
				coordinator.navigate(to: TestStep.end.with(.red))
			}
		}
		return true
	}

}
