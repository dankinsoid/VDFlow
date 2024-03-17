import Foundation
import SwiftUI
@testable import VDFlow
import XCTest

final class VDFlowTestsCase: XCTestCase {

	func testSelectedOfStaticFunc() {
		var value: TabSteps = .tab3(.screen2(.text2))
		XCTAssertEqual(value.selected, .tab3)

		value = .tab1
		XCTAssertEqual(value.selected, .tab1)

		value = .tab3(.screen2(.text2))
		XCTAssertEqual(value.selected, .tab3)
		XCTAssertEqual(value.tab3.selected, .screen2)
		XCTAssertEqual(value.tab3.screen2.selected, .text2)
	}

	func testSelectedProperty() {
		var value: TabSteps = .tab3(.screen2(.text2))
		value.selected = .tab2
		XCTAssertEqual(value.selected, .tab2)
	}

	func testSelectedPropertyUpdatesParent() {
		var value: TabSteps = .tab2
		value.tab3.screen2.selected = .text1
		XCTAssertEqual(value.selected, .tab3)
	}

	func testStaticFuncDoesNotUpdateParent() {
		var value: TabSteps = .tab2
		value.tab3.screen2 = .text1
		XCTAssertEqual(value.selected, .tab2)
	}

	func testNestedSelectFuncUpdatesParent() {
		var value: TabSteps = .tab2
		value.tab3.screen2.$text1.select()
		XCTAssertEqual(value.selected, .tab3)
		XCTAssertEqual(value.tab3.selected, .screen2)

		value.tab3.$none.select()
		XCTAssertEqual(value.tab3.selected, nil)
	}

	func testStepMacro() {
		var value = OneStepSteps(someString: "SomeString")
		XCTAssertEqual(value.selected, nil)
		value.selected = .someStep
		XCTAssertEqual(value.selected, .someStep)
		value.selected = nil
		XCTAssertEqual(value.selected, nil)
		value.someStep.$text1.select()
		XCTAssertEqual(value.selected, .someStep)
	}
}

@Steps
public struct TabSteps {
	public var tab1
	public var tab2
	public var tab3: NavigationSteps = .screen1
}

@Steps
public struct NavigationSteps {
	public var screen1
	public var screen2: PickerSteps = .text1
	public var none
}

@Steps
public struct PickerSteps {
	public var text1
	public var text2
}

@Steps
public struct OneStepSteps {

	public lazy var someLazyInt = 0
	public var someString: String
	@Step var someStep: PickerSteps = .text1
}

struct SomeView: View {

	@StateStep var tabs: TabSteps = .tab1

	var body: some View {
		Picker(selection: $tabs.selected) {
			Text("Tab 1").step($tabs.$tab1)
			Text("Tab 2").step($tabs.$tab2)
			Text("Tab 3").step($tabs.$tab3)
		} label: {}
			.sheet(isPresented: $tabs.tab3.isSelected(.screen2)) {}
	}
}
