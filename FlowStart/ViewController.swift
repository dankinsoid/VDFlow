//
//  ViewController.swift
//  FlowStart
//
//  Created by Daniil on 27.10.2020.
//

import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		let vcs = [
			vc(color: .red),
			vc(color: .blue),
			vc(color: .green),
			vc(color: .yellow),
			vc(color: .magenta)
		]
		present(vcs, animated: false) {
			DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
				vcs[2].dismissPresented(animated: false, completion: nil)
			}
		}
	}

	private func vc(color: UIColor) -> UIViewController {
		let vc = UIViewController()
		vc.loadViewIfNeeded()
		vc.view.backgroundColor = color
//		vc.modalPresentationStyle = .fullScreen
//		vc.modalTransitionStyle = .crossDissolve
		return vc
	}
	
}
