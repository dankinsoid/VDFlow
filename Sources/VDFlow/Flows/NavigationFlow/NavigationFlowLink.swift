//
//  File.swift
//  
//
//  Created by Данил Войдилов on 05.12.2021.
//

#if canImport(UIKit)
import SwiftUI

public struct NavigationFlowLink<Label: View, Destination: View>: View {
	
	public let destination: Destination
	public let label: Label
	@StateOrBinding private var isActive: Bool
	@Environment(\.tag) var tag
	@Environment(\.navigationFlowEnvironment) private var parentEnvironment
	@Environment(\.isInsideNavigationFlow) private var isInside
	@State private var navigationEnvironment = NavigationFlowEnvironment()
	@State private var id = UUID()
	private var tags: NavigationTag {
		NavigationTag(tags: tag.tags + [id])
	}
	private var environment: NavigationFlowEnvironment {
		let result = navigationEnvironment
		result.update = parentEnvironment.update
		return result
	}
	
	fileprivate init(isActive: StateOrBinding<Bool>, @ViewBuilder destination: () -> Destination, @ViewBuilder label: () -> Label) {
		self.destination = destination()
		self.label = label()
		self._isActive = isActive
	}
	
	public init(isActive: Binding<Bool>, @ViewBuilder destination: () -> Destination, @ViewBuilder label: () -> Label) {
		self.init(isActive: .binding(isActive), destination: destination, label: label)
	}
	
	public init(@ViewBuilder destination: () -> Destination, @ViewBuilder label: () -> Label) {
		self.init(isActive: .state(false), destination: destination, label: label)
	}
	
	public init<H: Hashable>(tag: H, selection: Binding<H?>, @ViewBuilder destination: () -> Destination, @ViewBuilder label: () -> Label) {
		self.init(
			isActive: Binding(
				get: { selection.wrappedValue == tag },
				set: { selection.wrappedValue = $0 ? tag : nil }
			),
			destination: destination,
			label: label
		)
	}
	
	public var body: some View {
		if isInside {
			Button {
				isActive.toggle()
			} label: {
				label
			}
		} else {
			NavigationLink {
				pushView
			} label: {
				label
			}
		}
	}
	
	private var pushView: some View {
		destination
			.environment(\.tag, tags)
			.environment(\.isInsideNavigationFlow, isInside)
			.environment(\.navigationFlowEnvironment, environment)
	}
}

extension NavigationFlowLink where Label == Text {
	
	public init(_ titleKey: LocalizedStringKey, isActive: Binding<Bool>, @ViewBuilder destination: () -> Destination) {
		self.init(isActive: isActive, destination: destination) {
			Text(titleKey)
		}
	}
	
	public init<S: StringProtocol>(_ title: S, isActive: Binding<Bool>, @ViewBuilder destination: () -> Destination) {
		self.init(isActive: isActive, destination: destination) {
			Text(title)
		}
	}
	
	public init(_ titleKey: LocalizedStringKey, @ViewBuilder destination: () -> Destination) {
		self.init(destination: destination) {
			Text(titleKey)
		}
	}
	
	public init<S: StringProtocol>(_ title: S, @ViewBuilder destination: () -> Destination) {
		self.init(destination: destination) {
			Text(title)
		}
	}
}

extension NavigationFlowLink {
	
	public init<Dest: View, T, D>(step: StateStep<T>.StepBinding<D>, @ViewBuilder destination: () -> Dest, @ViewBuilder label: () -> Label) where Destination == NavigationStepDestionation<Dest, D> {
		self.init(isActive: step.rootBinding[isSelected: step.keyPath]) {
			NavigationStepDestionation(content: destination(), stepBinding: step.binding)
		} label: {
			label()
		}
	}
}
#endif
