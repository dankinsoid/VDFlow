import Foundation
import SwiftUI
@testable import VDFlow
import XCTest

final class VDFlowTestsCase: XCTestCase {

	func testMacros() {
		var value = TabSteps()
		XCTAssertEqual(value.selected, nil)
		value.tab3.screen2.text2.select()
		XCTAssertEqual(value.selected, .tab3)
		XCTAssertEqual(value.tab3.selected, .screen2)
		XCTAssertEqual(value.tab3.screen2.selected, .text2)
		value.selected = .tab2
		XCTAssertEqual(value.selected, .tab2)
	}
}

struct T: View {

	@StateStep var step: TabSteps

	var body: some View {
		Text("Hello, World!")
			.onAppear {}
	}
}

@Steps
public struct TabSteps {
	public var tab1
	public var tab2 = 0
	public var tab3 = NavigationSteps(.screen1)
}

@Steps
public struct NavigationSteps {
	public var screen1
	public var screen2 = PickerSteps(.text1)
}

@Steps
public struct PickerSteps {
	public var text1
	public var text2
}
