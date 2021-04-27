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
	public static func buildBlock<F1: FlowComponent, F2: FlowComponent>(_ f1: F1, _ f2: F2) -> FlowPare<F1, F2> {
		FlowPare(f1, f2)
	}
	
	@inline(__always)
	public static func buildBlock<F1: FlowComponent, F2: FlowComponent, F3: FlowComponent>(_ f1: F1, _ f2: F2, _ f3: F3) -> FlowPare<F1, FlowPare<F2, F3>> {
		FlowPare(f1, FlowPare(f2, f3))
	}
	
	@inline(__always)
	public static func buildBlock<F1: FlowComponent, F2: FlowComponent, F3: FlowComponent, F4: FlowComponent>(_ f1: F1, _ f2: F2, _ f3: F3, _ f4: F4) -> FlowPare<F1, FlowPare<F2, FlowPare<F3, F4>>> {
		FlowPare(f1, FlowPare(f2, FlowPare(f3, f4)))
	}
	
	@inline(__always)
	public static func buildBlock<F1: FlowComponent, F2: FlowComponent, F3: FlowComponent, F4: FlowComponent, F5: FlowComponent>(_ f1: F1, _ f2: F2, _ f3: F3, _ f4: F4, _ f5: F5) -> FlowPare<F1, FlowPare<F2, FlowPare<F3, FlowPare<F4, F5>>>> {
		FlowPare(f1, FlowPare(f2, FlowPare(f3, FlowPare(f4, f5))))
	}
	
	@inline(__always)
	public static func buildBlock<F1: FlowComponent, F2: FlowComponent, F3: FlowComponent, F4: FlowComponent, F5: FlowComponent, F6: FlowComponent>(_ f1: F1, _ f2: F2, _ f3: F3, _ f4: F4, _ f5: F5, _ f6: F6) -> FlowPare<F1, FlowPare<F2, FlowPare<F3, FlowPare<F4, FlowPare<F5, F6>>>>> {
		FlowPare(f1, FlowPare(f2, FlowPare(f3, FlowPare(f4, FlowPare(f5, f6)))))
	}
	
	@inline(__always)
	public static func buildBlock<F1: FlowComponent, F2: FlowComponent, F3: FlowComponent, F4: FlowComponent, F5: FlowComponent, F6: FlowComponent, F7: FlowComponent>(_ f1: F1, _ f2: F2, _ f3: F3, _ f4: F4, _ f5: F5, _ f6: F6, _ f7: F7) -> FlowPare<F1, FlowPare<F2, FlowPare<F3, FlowPare<F4, FlowPare<F5, FlowPare<F6, F7>>>>>> {
		FlowPare(f1, FlowPare(f2, FlowPare(f3, FlowPare(f4, FlowPare(f5, FlowPare(f6, f7))))))
	}
	
	@inline(__always)
	public static func buildBlock<F1: FlowComponent, F2: FlowComponent, F3: FlowComponent, F4: FlowComponent, F5: FlowComponent, F6: FlowComponent, F7: FlowComponent, F8: FlowComponent>(_ f1: F1, _ f2: F2, _ f3: F3, _ f4: F4, _ f5: F5, _ f6: F6, _ f7: F7, _ f8: F8) -> FlowPare<F1, FlowPare<F2, FlowPare<F3, FlowPare<F4, FlowPare<F5, FlowPare<F6, FlowPare<F7, F8>>>>>>> {
		FlowPare(f1, FlowPare(f2, FlowPare(f3, FlowPare(f4, FlowPare(f5, FlowPare(f6, FlowPare(f7, f8)))))))
	}
	
	@inline(__always)
	public static func buildBlock<F1: FlowComponent, F2: FlowComponent, F3: FlowComponent, F4: FlowComponent, F5: FlowComponent, F6: FlowComponent, F7: FlowComponent, F8: FlowComponent, F9: FlowComponent>(_ f1: F1, _ f2: F2, _ f3: F3, _ f4: F4, _ f5: F5, _ f6: F6, _ f7: F7, _ f8: F8, _ f9: F9) -> FlowPare<F1, FlowPare<F2, FlowPare<F3, FlowPare<F4, FlowPare<F5, FlowPare<F6, FlowPare<F7, FlowPare<F8, F9>>>>>>>> {
		FlowPare(f1, FlowPare(f2, FlowPare(f3, FlowPare(f4, FlowPare(f5, FlowPare(f6, FlowPare(f7, FlowPare(f8, f9))))))))
	}
	
	@inline(__always)
	public static func buildBlock<F1: FlowComponent, F2: FlowComponent, F3: FlowComponent, F4: FlowComponent, F5: FlowComponent, F6: FlowComponent, F7: FlowComponent, F8: FlowComponent, F9: FlowComponent, F10: FlowComponent>(_ f1: F1, _ f2: F2, _ f3: F3, _ f4: F4, _ f5: F5, _ f6: F6, _ f7: F7, _ f8: F8, _ f9: F9, _ f10: F10) -> FlowPare<F1, FlowPare<F2, FlowPare<F3, FlowPare<F4, FlowPare<F5, FlowPare<F6, FlowPare<F7, FlowPare<F8, FlowPare<F9, F10>>>>>>>>> {
		FlowPare(f1, FlowPare(f2, FlowPare(f3, FlowPare(f4, FlowPare(f5, FlowPare(f6, FlowPare(f7, FlowPare(f8, FlowPare(f9, f10)))))))))
	}
	
	@inline(__always)
	public static func buildBlock<F1: FlowComponent, F2: FlowComponent, F3: FlowComponent, F4: FlowComponent, F5: FlowComponent, F6: FlowComponent, F7: FlowComponent, F8: FlowComponent, F9: FlowComponent, F10: FlowComponent, F11: FlowComponent>(_ f1: F1, _ f2: F2, _ f3: F3, _ f4: F4, _ f5: F5, _ f6: F6, _ f7: F7, _ f8: F8, _ f9: F9, _ f10: F10, _ f11: F11) -> FlowPare<F1, FlowPare<F2, FlowPare<F3, FlowPare<F4, FlowPare<F5, FlowPare<F6, FlowPare<F7, FlowPare<F8, FlowPare<F9, FlowPare<F10, F11>>>>>>>>>> {
		FlowPare(f1, FlowPare(f2, FlowPare(f3, FlowPare(f4, FlowPare(f5, FlowPare(f6, FlowPare(f7, FlowPare(f8, FlowPare(f9, FlowPare(f10, f11))))))))))
	}
	
	@inline(__always)
	public static func buildBlock<F1: FlowComponent, F2: FlowComponent, F3: FlowComponent, F4: FlowComponent, F5: FlowComponent, F6: FlowComponent, F7: FlowComponent, F8: FlowComponent, F9: FlowComponent, F10: FlowComponent, F11: FlowComponent, F12: FlowComponent>(_ f1: F1, _ f2: F2, _ f3: F3, _ f4: F4, _ f5: F5, _ f6: F6, _ f7: F7, _ f8: F8, _ f9: F9, _ f10: F10, _ f11: F11, _ f12: F12) -> FlowPare<F1, FlowPare<F2, FlowPare<F3, FlowPare<F4, FlowPare<F5, FlowPare<F6, FlowPare<F7, FlowPare<F8, FlowPare<F9, FlowPare<F10, FlowPare<F11, F12>>>>>>>>>>> {
		FlowPare(f1, FlowPare(f2, FlowPare(f3, FlowPare(f4, FlowPare(f5, FlowPare(f6, FlowPare(f7, FlowPare(f8, FlowPare(f9, FlowPare(f10, FlowPare(f11, f12)))))))))))
	}
	
	@inline(__always)
	public static func buildBlock<F1: FlowComponent, F2: FlowComponent, F3: FlowComponent, F4: FlowComponent, F5: FlowComponent, F6: FlowComponent, F7: FlowComponent, F8: FlowComponent, F9: FlowComponent, F10: FlowComponent, F11: FlowComponent, F12: FlowComponent, F13: FlowComponent>(_ f1: F1, _ f2: F2, _ f3: F3, _ f4: F4, _ f5: F5, _ f6: F6, _ f7: F7, _ f8: F8, _ f9: F9, _ f10: F10, _ f11: F11, _ f12: F12, _ f13: F13) -> FlowPare<F1, FlowPare<F2, FlowPare<F3, FlowPare<F4, FlowPare<F5, FlowPare<F6, FlowPare<F7, FlowPare<F8, FlowPare<F9, FlowPare<F10, FlowPare<F11, FlowPare<F12, F13>>>>>>>>>>>> {
		FlowPare(f1, FlowPare(f2, FlowPare(f3, FlowPare(f4, FlowPare(f5, FlowPare(f6, FlowPare(f7, FlowPare(f8, FlowPare(f9, FlowPare(f10, FlowPare(f11, FlowPare(f12, f13))))))))))))
	}
	
	@inline(__always)
	public static func buildBlock<F1: FlowComponent, F2: FlowComponent, F3: FlowComponent, F4: FlowComponent, F5: FlowComponent, F6: FlowComponent, F7: FlowComponent, F8: FlowComponent, F9: FlowComponent, F10: FlowComponent, F11: FlowComponent, F12: FlowComponent, F13: FlowComponent, F14: FlowComponent>(_ f1: F1, _ f2: F2, _ f3: F3, _ f4: F4, _ f5: F5, _ f6: F6, _ f7: F7, _ f8: F8, _ f9: F9, _ f10: F10, _ f11: F11, _ f12: F12, _ f13: F13, _ f14: F14) -> FlowPare<F1, FlowPare<F2, FlowPare<F3, FlowPare<F4, FlowPare<F5, FlowPare<F6, FlowPare<F7, FlowPare<F8, FlowPare<F9, FlowPare<F10, FlowPare<F11, FlowPare<F12, FlowPare<F13, F14>>>>>>>>>>>>> {
		FlowPare(f1, FlowPare(f2, FlowPare(f3, FlowPare(f4, FlowPare(f5, FlowPare(f6, FlowPare(f7, FlowPare(f8, FlowPare(f9, FlowPare(f10, FlowPare(f11, FlowPare(f12, FlowPare(f13, f14)))))))))))))
	}
	
	@inline(__always)
	public static func buildBlock<F1: FlowComponent, F2: FlowComponent, F3: FlowComponent, F4: FlowComponent, F5: FlowComponent, F6: FlowComponent, F7: FlowComponent, F8: FlowComponent, F9: FlowComponent, F10: FlowComponent, F11: FlowComponent, F12: FlowComponent, F13: FlowComponent, F14: FlowComponent, F15: FlowComponent>(_ f1: F1, _ f2: F2, _ f3: F3, _ f4: F4, _ f5: F5, _ f6: F6, _ f7: F7, _ f8: F8, _ f9: F9, _ f10: F10, _ f11: F11, _ f12: F12, _ f13: F13, _ f14: F14, _ f15: F15) -> FlowPare<F1, FlowPare<F2, FlowPare<F3, FlowPare<F4, FlowPare<F5, FlowPare<F6, FlowPare<F7, FlowPare<F8, FlowPare<F9, FlowPare<F10, FlowPare<F11, FlowPare<F12, FlowPare<F13, FlowPare<F14, F15>>>>>>>>>>>>>> {
		FlowPare(f1, FlowPare(f2, FlowPare(f3, FlowPare(f4, FlowPare(f5, FlowPare(f6, FlowPare(f7, FlowPare(f8, FlowPare(f9, FlowPare(f10, FlowPare(f11, FlowPare(f12, FlowPare(f13, FlowPare(f14, f15))))))))))))))
	}
	
	@inline(__always)
	public static func buildBlock<F1: FlowComponent, F2: FlowComponent, F3: FlowComponent, F4: FlowComponent, F5: FlowComponent, F6: FlowComponent, F7: FlowComponent, F8: FlowComponent, F9: FlowComponent, F10: FlowComponent, F11: FlowComponent, F12: FlowComponent, F13: FlowComponent, F14: FlowComponent, F15: FlowComponent, F16: FlowComponent>(_ f1: F1, _ f2: F2, _ f3: F3, _ f4: F4, _ f5: F5, _ f6: F6, _ f7: F7, _ f8: F8, _ f9: F9, _ f10: F10, _ f11: F11, _ f12: F12, _ f13: F13, _ f14: F14, _ f15: F15, _ f16: F16) -> FlowPare<F1, FlowPare<F2, FlowPare<F3, FlowPare<F4, FlowPare<F5, FlowPare<F6, FlowPare<F7, FlowPare<F8, FlowPare<F9, FlowPare<F10, FlowPare<F11, FlowPare<F12, FlowPare<F13, FlowPare<F14, FlowPare<F15, F16>>>>>>>>>>>>>>> {
		FlowPare(f1, FlowPare(f2, FlowPare(f3, FlowPare(f4, FlowPare(f5, FlowPare(f6, FlowPare(f7, FlowPare(f8, FlowPare(f9, FlowPare(f10, FlowPare(f11, FlowPare(f12, FlowPare(f13, FlowPare(f14, FlowPare(f15, f16)))))))))))))))
	}
	
	@inline(__always)
	public static func buildBlock<F1: FlowComponent, F2: FlowComponent, F3: FlowComponent, F4: FlowComponent, F5: FlowComponent, F6: FlowComponent, F7: FlowComponent, F8: FlowComponent, F9: FlowComponent, F10: FlowComponent, F11: FlowComponent, F12: FlowComponent, F13: FlowComponent, F14: FlowComponent, F15: FlowComponent, F16: FlowComponent, F17: FlowComponent>(_ f1: F1, _ f2: F2, _ f3: F3, _ f4: F4, _ f5: F5, _ f6: F6, _ f7: F7, _ f8: F8, _ f9: F9, _ f10: F10, _ f11: F11, _ f12: F12, _ f13: F13, _ f14: F14, _ f15: F15, _ f16: F16, _ f17: F17) -> FlowPare<F1, FlowPare<F2, FlowPare<F3, FlowPare<F4, FlowPare<F5, FlowPare<F6, FlowPare<F7, FlowPare<F8, FlowPare<F9, FlowPare<F10, FlowPare<F11, FlowPare<F12, FlowPare<F13, FlowPare<F14, FlowPare<F15, FlowPare<F16, F17>>>>>>>>>>>>>>>> {
		FlowPare(f1, FlowPare(f2, FlowPare(f3, FlowPare(f4, FlowPare(f5, FlowPare(f6, FlowPare(f7, FlowPare(f8, FlowPare(f9, FlowPare(f10, FlowPare(f11, FlowPare(f12, FlowPare(f13, FlowPare(f14, FlowPare(f15, FlowPare(f16, f17))))))))))))))))
	}
	
	@inline(__always)
	public static func buildBlock<F1: FlowComponent, F2: FlowComponent, F3: FlowComponent, F4: FlowComponent, F5: FlowComponent, F6: FlowComponent, F7: FlowComponent, F8: FlowComponent, F9: FlowComponent, F10: FlowComponent, F11: FlowComponent, F12: FlowComponent, F13: FlowComponent, F14: FlowComponent, F15: FlowComponent, F16: FlowComponent, F17: FlowComponent, F18: FlowComponent>(_ f1: F1, _ f2: F2, _ f3: F3, _ f4: F4, _ f5: F5, _ f6: F6, _ f7: F7, _ f8: F8, _ f9: F9, _ f10: F10, _ f11: F11, _ f12: F12, _ f13: F13, _ f14: F14, _ f15: F15, _ f16: F16, _ f17: F17, _ f18: F18) -> FlowPare<F1, FlowPare<F2, FlowPare<F3, FlowPare<F4, FlowPare<F5, FlowPare<F6, FlowPare<F7, FlowPare<F8, FlowPare<F9, FlowPare<F10, FlowPare<F11, FlowPare<F12, FlowPare<F13, FlowPare<F14, FlowPare<F15, FlowPare<F16, FlowPare<F17, F18>>>>>>>>>>>>>>>>> {
		FlowPare(f1, FlowPare(f2, FlowPare(f3, FlowPare(f4, FlowPare(f5, FlowPare(f6, FlowPare(f7, FlowPare(f8, FlowPare(f9, FlowPare(f10, FlowPare(f11, FlowPare(f12, FlowPare(f13, FlowPare(f14, FlowPare(f15, FlowPare(f16, FlowPare(f17, f18)))))))))))))))))
	}
	
	@inline(__always)
	public static func buildBlock<F1: FlowComponent, F2: FlowComponent, F3: FlowComponent, F4: FlowComponent, F5: FlowComponent, F6: FlowComponent, F7: FlowComponent, F8: FlowComponent, F9: FlowComponent, F10: FlowComponent, F11: FlowComponent, F12: FlowComponent, F13: FlowComponent, F14: FlowComponent, F15: FlowComponent, F16: FlowComponent, F17: FlowComponent, F18: FlowComponent, F19: FlowComponent>(_ f1: F1, _ f2: F2, _ f3: F3, _ f4: F4, _ f5: F5, _ f6: F6, _ f7: F7, _ f8: F8, _ f9: F9, _ f10: F10, _ f11: F11, _ f12: F12, _ f13: F13, _ f14: F14, _ f15: F15, _ f16: F16, _ f17: F17, _ f18: F18, _ f19: F19) -> FlowPare<F1, FlowPare<F2, FlowPare<F3, FlowPare<F4, FlowPare<F5, FlowPare<F6, FlowPare<F7, FlowPare<F8, FlowPare<F9, FlowPare<F10, FlowPare<F11, FlowPare<F12, FlowPare<F13, FlowPare<F14, FlowPare<F15, FlowPare<F16, FlowPare<F17, FlowPare<F18, F19>>>>>>>>>>>>>>>>>> {
		FlowPare(f1, FlowPare(f2, FlowPare(f3, FlowPare(f4, FlowPare(f5, FlowPare(f6, FlowPare(f7, FlowPare(f8, FlowPare(f9, FlowPare(f10, FlowPare(f11, FlowPare(f12, FlowPare(f13, FlowPare(f14, FlowPare(f15, FlowPare(f16, FlowPare(f17, FlowPare(f18, f19))))))))))))))))))
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
}
