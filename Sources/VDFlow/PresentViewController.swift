//
//  File.swift
//  
//
//  Created by Данил Войдилов on 07.05.2021.
//

import UIKit

public final class PresentViewController: UIViewController {
	
	public var viewControllers: [UIViewController] {
		rootViewController.map { [$0] + allPresented } ?? allPresented
	}
	private var rootViewController: UIViewController?
	public var presentClosure: PresentClosure = { $0.present($1, animated: $2, completion: $3) }
	var onDidShow: ((UIViewController) -> Void)?
	private var isAppear = false
	private var isPresenting = false
	private let observingId = "PresentObserve"
	public var style: PresentFlowStyle?
	override public var preferredStatusBarStyle: UIStatusBarStyle { rootViewController?.preferredStatusBarStyle ?? .default }
	
	override public func viewDidLoad() {
		super.viewDidLoad()
		modalPresentationStyle = .overCurrentContext
	}
	
	public func set(_ viewControllers: [ObservableControllerType], animated: Bool, completion: (() -> Void)? = nil) {
		guard !viewControllers.isEmpty else {
			removeRoot()
			completion?()
			return
		}
		guard view?.window != nil,
			!isAppear && !(viewControllers + self.viewControllers).contains(where: { $0.isBeingPresented }) else {
			completion?()
			return
		}
		viewControllers.forEach(update)
		observe(viewControllers)
		set(root: viewControllers[0])
		isPresenting = true
		if viewControllers.count == 1 {
			dismissPresented(animated: animated) {[weak self] in
				self?.isPresenting = false
				completion?()
			}
			return
		}
		present(Array(viewControllers.dropFirst()), dismiss: true, animated: animated, presentClosure: presentClosure) {[weak self] in
			self?.isPresenting = false
			completion?()
		}
	}
	
	private func set(root: UIViewController) {
		guard rootViewController !== root else { return }
		removeRoot()
		loadViewIfNeeded()
		root.loadViewIfNeeded()
		root.view.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(root.view)
		root.view.frame = view.bounds
		root.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		root.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		root.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		root.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		addChild(root)
		root.didMove(toParent: self)
		rootViewController = root
	}
	
	private func removeRoot() {
		rootViewController?.removeFromParent()
		rootViewController?.view?.removeFromSuperview()
		rootViewController = nil
	}
	
	private func update(child: UIViewController) {
		switch style {
		case .native(let presentation, let transition):
			child.modalPresentationStyle = presentation
			child.modalTransitionStyle = transition
		case .delegate(let delegate):
			child.transitioningDelegate = delegate
		case .none:
			break
		}
	}
	
	private func observe(_ vcs: [ObservableControllerType]) {
		vcs.forEach(observe)
	}
	
	private func observe(_ vc: ObservableControllerType) {
		_ = vc.on(.didAppear, id: observingId) {[weak self] _ in
			self?.isAppear = false
			if self?.isPresenting == false {
				(self?.viewControllers.last).map { self?.onDidShow?($0) }
			}
		}
		_ = vc.on(.didDisappear, id: observingId) {[weak self] _ in
			self?.isAppear = false
			if self?.isPresenting == false {
				(self?.viewControllers.last).map { self?.onDidShow?($0) }
			}
		}
		_ = vc.on(.willAppear, id: observingId) {[weak self] _ in
			self?.isAppear = true
		}
		_ = vc.on(.willDisappear, id: observingId) {[weak self] _ in
			self?.isAppear = true
		}
	}
}
