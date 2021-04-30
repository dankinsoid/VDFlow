//
//  FlowBuilder.swift
//  FlowStart
//
//  Created by Daniil on 27.10.2020.
//

import Foundation

@resultBuilder
public struct FlowBuilder {
	
	@inline(__always)
	public static func buildBlock() -> EmptyComponent {
		EmptyComponent()
	}
	
	@inline(__always)
	public static func buildBlock<F: FlowComponent>(_ component: F) -> F {
		component
	}
	
	@inline(__always)
	public static func buildBlock<F1: FlowComponent, F2: FlowComponent>(_ f1: F1, _ f2: F2) -> FlowTuple<F1, F2> {
		FlowTuple(f1, f2)
	}
	
	@inline(__always)
	public static func buildBlock<F1: FlowComponent, F2: FlowComponent, F3: FlowComponent>(_ f1: F1, _ f2: F2, _ f3: F3) -> FlowTuple<F1, FlowTuple<F2, F3>> {
		FlowTuple(f1, FlowTuple(f2, f3))
	}
	
	@inline(__always)
	public static func buildBlock<F1: FlowComponent, F2: FlowComponent, F3: FlowComponent, F4: FlowComponent>(_ f1: F1, _ f2: F2, _ f3: F3, _ f4: F4) -> FlowTuple<F1, FlowTuple<F2, FlowTuple<F3, F4>>> {
		FlowTuple(f1, FlowTuple(f2, FlowTuple(f3, f4)))
	}
	
	@inline(__always)
	public static func buildBlock<F1: FlowComponent, F2: FlowComponent, F3: FlowComponent, F4: FlowComponent, F5: FlowComponent>(_ f1: F1, _ f2: F2, _ f3: F3, _ f4: F4, _ f5: F5) -> FlowTuple<F1, FlowTuple<F2, FlowTuple<F3, FlowTuple<F4, F5>>>> {
		FlowTuple(f1, FlowTuple(f2, FlowTuple(f3, FlowTuple(f4, f5))))
	}
	
	@inline(__always)
	public static func buildBlock<F1: FlowComponent, F2: FlowComponent, F3: FlowComponent, F4: FlowComponent, F5: FlowComponent, F6: FlowComponent>(_ f1: F1, _ f2: F2, _ f3: F3, _ f4: F4, _ f5: F5, _ f6: F6) -> FlowTuple<F1, FlowTuple<F2, FlowTuple<F3, FlowTuple<F4, FlowTuple<F5, F6>>>>> {
		FlowTuple(f1, FlowTuple(f2, FlowTuple(f3, FlowTuple(f4, FlowTuple(f5, f6)))))
	}
	
	@inline(__always)
	public static func buildBlock<F1: FlowComponent, F2: FlowComponent, F3: FlowComponent, F4: FlowComponent, F5: FlowComponent, F6: FlowComponent, F7: FlowComponent>(_ f1: F1, _ f2: F2, _ f3: F3, _ f4: F4, _ f5: F5, _ f6: F6, _ f7: F7) -> FlowTuple<F1, FlowTuple<F2, FlowTuple<F3, FlowTuple<F4, FlowTuple<F5, FlowTuple<F6, F7>>>>>> {
		FlowTuple(f1, FlowTuple(f2, FlowTuple(f3, FlowTuple(f4, FlowTuple(f5, FlowTuple(f6, f7))))))
	}
	
	@inline(__always)
	public static func buildBlock<F1: FlowComponent, F2: FlowComponent, F3: FlowComponent, F4: FlowComponent, F5: FlowComponent, F6: FlowComponent, F7: FlowComponent, F8: FlowComponent>(_ f1: F1, _ f2: F2, _ f3: F3, _ f4: F4, _ f5: F5, _ f6: F6, _ f7: F7, _ f8: F8) -> FlowTuple<F1, FlowTuple<F2, FlowTuple<F3, FlowTuple<F4, FlowTuple<F5, FlowTuple<F6, FlowTuple<F7, F8>>>>>>> {
		FlowTuple(f1, FlowTuple(f2, FlowTuple(f3, FlowTuple(f4, FlowTuple(f5, FlowTuple(f6, FlowTuple(f7, f8)))))))
	}
	
	@inline(__always)
	public static func buildBlock<F1: FlowComponent, F2: FlowComponent, F3: FlowComponent, F4: FlowComponent, F5: FlowComponent, F6: FlowComponent, F7: FlowComponent, F8: FlowComponent, F9: FlowComponent>(_ f1: F1, _ f2: F2, _ f3: F3, _ f4: F4, _ f5: F5, _ f6: F6, _ f7: F7, _ f8: F8, _ f9: F9) -> FlowTuple<F1, FlowTuple<F2, FlowTuple<F3, FlowTuple<F4, FlowTuple<F5, FlowTuple<F6, FlowTuple<F7, FlowTuple<F8, F9>>>>>>>> {
		FlowTuple(f1, FlowTuple(f2, FlowTuple(f3, FlowTuple(f4, FlowTuple(f5, FlowTuple(f6, FlowTuple(f7, FlowTuple(f8, f9))))))))
	}
	
	@inline(__always)
	public static func buildBlock<F1: FlowComponent, F2: FlowComponent, F3: FlowComponent, F4: FlowComponent, F5: FlowComponent, F6: FlowComponent, F7: FlowComponent, F8: FlowComponent, F9: FlowComponent, F10: FlowComponent>(_ f1: F1, _ f2: F2, _ f3: F3, _ f4: F4, _ f5: F5, _ f6: F6, _ f7: F7, _ f8: F8, _ f9: F9, _ f10: F10) -> FlowTuple<F1, FlowTuple<F2, FlowTuple<F3, FlowTuple<F4, FlowTuple<F5, FlowTuple<F6, FlowTuple<F7, FlowTuple<F8, FlowTuple<F9, F10>>>>>>>>> {
		FlowTuple(f1, FlowTuple(f2, FlowTuple(f3, FlowTuple(f4, FlowTuple(f5, FlowTuple(f6, FlowTuple(f7, FlowTuple(f8, FlowTuple(f9, f10)))))))))
	}
	
	@inline(__always)
	public static func buildBlock<F1: FlowComponent, F2: FlowComponent, F3: FlowComponent, F4: FlowComponent, F5: FlowComponent, F6: FlowComponent, F7: FlowComponent, F8: FlowComponent, F9: FlowComponent, F10: FlowComponent, F11: FlowComponent>(_ f1: F1, _ f2: F2, _ f3: F3, _ f4: F4, _ f5: F5, _ f6: F6, _ f7: F7, _ f8: F8, _ f9: F9, _ f10: F10, _ f11: F11) -> FlowTuple<F1, FlowTuple<F2, FlowTuple<F3, FlowTuple<F4, FlowTuple<F5, FlowTuple<F6, FlowTuple<F7, FlowTuple<F8, FlowTuple<F9, FlowTuple<F10, F11>>>>>>>>>> {
		FlowTuple(f1, FlowTuple(f2, FlowTuple(f3, FlowTuple(f4, FlowTuple(f5, FlowTuple(f6, FlowTuple(f7, FlowTuple(f8, FlowTuple(f9, FlowTuple(f10, f11))))))))))
	}
	
	@inline(__always)
	public static func buildBlock<F1: FlowComponent, F2: FlowComponent, F3: FlowComponent, F4: FlowComponent, F5: FlowComponent, F6: FlowComponent, F7: FlowComponent, F8: FlowComponent, F9: FlowComponent, F10: FlowComponent, F11: FlowComponent, F12: FlowComponent>(_ f1: F1, _ f2: F2, _ f3: F3, _ f4: F4, _ f5: F5, _ f6: F6, _ f7: F7, _ f8: F8, _ f9: F9, _ f10: F10, _ f11: F11, _ f12: F12) -> FlowTuple<F1, FlowTuple<F2, FlowTuple<F3, FlowTuple<F4, FlowTuple<F5, FlowTuple<F6, FlowTuple<F7, FlowTuple<F8, FlowTuple<F9, FlowTuple<F10, FlowTuple<F11, F12>>>>>>>>>>> {
		FlowTuple(f1, FlowTuple(f2, FlowTuple(f3, FlowTuple(f4, FlowTuple(f5, FlowTuple(f6, FlowTuple(f7, FlowTuple(f8, FlowTuple(f9, FlowTuple(f10, FlowTuple(f11, f12)))))))))))
	}
	
	@inline(__always)
	public static func buildBlock<F1: FlowComponent, F2: FlowComponent, F3: FlowComponent, F4: FlowComponent, F5: FlowComponent, F6: FlowComponent, F7: FlowComponent, F8: FlowComponent, F9: FlowComponent, F10: FlowComponent, F11: FlowComponent, F12: FlowComponent, F13: FlowComponent>(_ f1: F1, _ f2: F2, _ f3: F3, _ f4: F4, _ f5: F5, _ f6: F6, _ f7: F7, _ f8: F8, _ f9: F9, _ f10: F10, _ f11: F11, _ f12: F12, _ f13: F13) -> FlowTuple<F1, FlowTuple<F2, FlowTuple<F3, FlowTuple<F4, FlowTuple<F5, FlowTuple<F6, FlowTuple<F7, FlowTuple<F8, FlowTuple<F9, FlowTuple<F10, FlowTuple<F11, FlowTuple<F12, F13>>>>>>>>>>>> {
		FlowTuple(f1, FlowTuple(f2, FlowTuple(f3, FlowTuple(f4, FlowTuple(f5, FlowTuple(f6, FlowTuple(f7, FlowTuple(f8, FlowTuple(f9, FlowTuple(f10, FlowTuple(f11, FlowTuple(f12, f13))))))))))))
	}
	
	@inline(__always)
	public static func buildBlock<F1: FlowComponent, F2: FlowComponent, F3: FlowComponent, F4: FlowComponent, F5: FlowComponent, F6: FlowComponent, F7: FlowComponent, F8: FlowComponent, F9: FlowComponent, F10: FlowComponent, F11: FlowComponent, F12: FlowComponent, F13: FlowComponent, F14: FlowComponent>(_ f1: F1, _ f2: F2, _ f3: F3, _ f4: F4, _ f5: F5, _ f6: F6, _ f7: F7, _ f8: F8, _ f9: F9, _ f10: F10, _ f11: F11, _ f12: F12, _ f13: F13, _ f14: F14) -> FlowTuple<F1, FlowTuple<F2, FlowTuple<F3, FlowTuple<F4, FlowTuple<F5, FlowTuple<F6, FlowTuple<F7, FlowTuple<F8, FlowTuple<F9, FlowTuple<F10, FlowTuple<F11, FlowTuple<F12, FlowTuple<F13, F14>>>>>>>>>>>>> {
		FlowTuple(f1, FlowTuple(f2, FlowTuple(f3, FlowTuple(f4, FlowTuple(f5, FlowTuple(f6, FlowTuple(f7, FlowTuple(f8, FlowTuple(f9, FlowTuple(f10, FlowTuple(f11, FlowTuple(f12, FlowTuple(f13, f14)))))))))))))
	}
	
	@inline(__always)
	public static func buildBlock<F1: FlowComponent, F2: FlowComponent, F3: FlowComponent, F4: FlowComponent, F5: FlowComponent, F6: FlowComponent, F7: FlowComponent, F8: FlowComponent, F9: FlowComponent, F10: FlowComponent, F11: FlowComponent, F12: FlowComponent, F13: FlowComponent, F14: FlowComponent, F15: FlowComponent>(_ f1: F1, _ f2: F2, _ f3: F3, _ f4: F4, _ f5: F5, _ f6: F6, _ f7: F7, _ f8: F8, _ f9: F9, _ f10: F10, _ f11: F11, _ f12: F12, _ f13: F13, _ f14: F14, _ f15: F15) -> FlowTuple<F1, FlowTuple<F2, FlowTuple<F3, FlowTuple<F4, FlowTuple<F5, FlowTuple<F6, FlowTuple<F7, FlowTuple<F8, FlowTuple<F9, FlowTuple<F10, FlowTuple<F11, FlowTuple<F12, FlowTuple<F13, FlowTuple<F14, F15>>>>>>>>>>>>>> {
		FlowTuple(f1, FlowTuple(f2, FlowTuple(f3, FlowTuple(f4, FlowTuple(f5, FlowTuple(f6, FlowTuple(f7, FlowTuple(f8, FlowTuple(f9, FlowTuple(f10, FlowTuple(f11, FlowTuple(f12, FlowTuple(f13, FlowTuple(f14, f15))))))))))))))
	}
	
	@inline(__always)
	public static func buildBlock<F1: FlowComponent, F2: FlowComponent, F3: FlowComponent, F4: FlowComponent, F5: FlowComponent, F6: FlowComponent, F7: FlowComponent, F8: FlowComponent, F9: FlowComponent, F10: FlowComponent, F11: FlowComponent, F12: FlowComponent, F13: FlowComponent, F14: FlowComponent, F15: FlowComponent, F16: FlowComponent>(_ f1: F1, _ f2: F2, _ f3: F3, _ f4: F4, _ f5: F5, _ f6: F6, _ f7: F7, _ f8: F8, _ f9: F9, _ f10: F10, _ f11: F11, _ f12: F12, _ f13: F13, _ f14: F14, _ f15: F15, _ f16: F16) -> FlowTuple<F1, FlowTuple<F2, FlowTuple<F3, FlowTuple<F4, FlowTuple<F5, FlowTuple<F6, FlowTuple<F7, FlowTuple<F8, FlowTuple<F9, FlowTuple<F10, FlowTuple<F11, FlowTuple<F12, FlowTuple<F13, FlowTuple<F14, FlowTuple<F15, F16>>>>>>>>>>>>>>> {
		FlowTuple(f1, FlowTuple(f2, FlowTuple(f3, FlowTuple(f4, FlowTuple(f5, FlowTuple(f6, FlowTuple(f7, FlowTuple(f8, FlowTuple(f9, FlowTuple(f10, FlowTuple(f11, FlowTuple(f12, FlowTuple(f13, FlowTuple(f14, FlowTuple(f15, f16)))))))))))))))
	}
	
	@inline(__always)
	public static func buildBlock<F1: FlowComponent, F2: FlowComponent, F3: FlowComponent, F4: FlowComponent, F5: FlowComponent, F6: FlowComponent, F7: FlowComponent, F8: FlowComponent, F9: FlowComponent, F10: FlowComponent, F11: FlowComponent, F12: FlowComponent, F13: FlowComponent, F14: FlowComponent, F15: FlowComponent, F16: FlowComponent, F17: FlowComponent>(_ f1: F1, _ f2: F2, _ f3: F3, _ f4: F4, _ f5: F5, _ f6: F6, _ f7: F7, _ f8: F8, _ f9: F9, _ f10: F10, _ f11: F11, _ f12: F12, _ f13: F13, _ f14: F14, _ f15: F15, _ f16: F16, _ f17: F17) -> FlowTuple<F1, FlowTuple<F2, FlowTuple<F3, FlowTuple<F4, FlowTuple<F5, FlowTuple<F6, FlowTuple<F7, FlowTuple<F8, FlowTuple<F9, FlowTuple<F10, FlowTuple<F11, FlowTuple<F12, FlowTuple<F13, FlowTuple<F14, FlowTuple<F15, FlowTuple<F16, F17>>>>>>>>>>>>>>>> {
		FlowTuple(f1, FlowTuple(f2, FlowTuple(f3, FlowTuple(f4, FlowTuple(f5, FlowTuple(f6, FlowTuple(f7, FlowTuple(f8, FlowTuple(f9, FlowTuple(f10, FlowTuple(f11, FlowTuple(f12, FlowTuple(f13, FlowTuple(f14, FlowTuple(f15, FlowTuple(f16, f17))))))))))))))))
	}
	
	@inline(__always)
	public static func buildBlock<F1: FlowComponent, F2: FlowComponent, F3: FlowComponent, F4: FlowComponent, F5: FlowComponent, F6: FlowComponent, F7: FlowComponent, F8: FlowComponent, F9: FlowComponent, F10: FlowComponent, F11: FlowComponent, F12: FlowComponent, F13: FlowComponent, F14: FlowComponent, F15: FlowComponent, F16: FlowComponent, F17: FlowComponent, F18: FlowComponent>(_ f1: F1, _ f2: F2, _ f3: F3, _ f4: F4, _ f5: F5, _ f6: F6, _ f7: F7, _ f8: F8, _ f9: F9, _ f10: F10, _ f11: F11, _ f12: F12, _ f13: F13, _ f14: F14, _ f15: F15, _ f16: F16, _ f17: F17, _ f18: F18) -> FlowTuple<F1, FlowTuple<F2, FlowTuple<F3, FlowTuple<F4, FlowTuple<F5, FlowTuple<F6, FlowTuple<F7, FlowTuple<F8, FlowTuple<F9, FlowTuple<F10, FlowTuple<F11, FlowTuple<F12, FlowTuple<F13, FlowTuple<F14, FlowTuple<F15, FlowTuple<F16, FlowTuple<F17, F18>>>>>>>>>>>>>>>>> {
		FlowTuple(f1, FlowTuple(f2, FlowTuple(f3, FlowTuple(f4, FlowTuple(f5, FlowTuple(f6, FlowTuple(f7, FlowTuple(f8, FlowTuple(f9, FlowTuple(f10, FlowTuple(f11, FlowTuple(f12, FlowTuple(f13, FlowTuple(f14, FlowTuple(f15, FlowTuple(f16, FlowTuple(f17, f18)))))))))))))))))
	}
	
	@inline(__always)
	public static func buildBlock<F1: FlowComponent, F2: FlowComponent, F3: FlowComponent, F4: FlowComponent, F5: FlowComponent, F6: FlowComponent, F7: FlowComponent, F8: FlowComponent, F9: FlowComponent, F10: FlowComponent, F11: FlowComponent, F12: FlowComponent, F13: FlowComponent, F14: FlowComponent, F15: FlowComponent, F16: FlowComponent, F17: FlowComponent, F18: FlowComponent, F19: FlowComponent>(_ f1: F1, _ f2: F2, _ f3: F3, _ f4: F4, _ f5: F5, _ f6: F6, _ f7: F7, _ f8: F8, _ f9: F9, _ f10: F10, _ f11: F11, _ f12: F12, _ f13: F13, _ f14: F14, _ f15: F15, _ f16: F16, _ f17: F17, _ f18: F18, _ f19: F19) -> FlowTuple<F1, FlowTuple<F2, FlowTuple<F3, FlowTuple<F4, FlowTuple<F5, FlowTuple<F6, FlowTuple<F7, FlowTuple<F8, FlowTuple<F9, FlowTuple<F10, FlowTuple<F11, FlowTuple<F12, FlowTuple<F13, FlowTuple<F14, FlowTuple<F15, FlowTuple<F16, FlowTuple<F17, FlowTuple<F18, F19>>>>>>>>>>>>>>>>>> {
		FlowTuple(f1, FlowTuple(f2, FlowTuple(f3, FlowTuple(f4, FlowTuple(f5, FlowTuple(f6, FlowTuple(f7, FlowTuple(f8, FlowTuple(f9, FlowTuple(f10, FlowTuple(f11, FlowTuple(f12, FlowTuple(f13, FlowTuple(f14, FlowTuple(f15, FlowTuple(f16, FlowTuple(f17, FlowTuple(f18, f19))))))))))))))))))
	}

	@inline(__always)
	public static func buildOptional<F: FlowComponent>(_ component: F?) -> OptionalFlow<F> {
		OptionalFlow(component)
	}
	
	@inline(__always)
	public static func buildEither<F: FlowComponent>(first: F) -> F {
		first
	}
	
	@inline(__always)
	public static func buildEither<F: FlowComponent>(second: F) -> F {
		second
	}
	
	@inline(__always)
	public static func buildArray<F: FlowComponent>(_ components: [F]) -> ArrayFlow<F> {
		ArrayFlow(components)
	}
	
	@inline(__always)
	public static func buildExpression<T: UIViewControllerConvertable>(_ expression: @escaping @autoclosure () -> T) -> VC<T> {
		VC(expression)
	}
	
	@inline(__always)
	public static func buildExpression<F: FlowComponent>(_ expression: F) -> F {
		expression
	}
	
	@inline(__always)
	public static func buildLimitedAvailability<F: FlowComponent>(_ component: F) -> F {
		component
	}
}
