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
        return;
        XCTAssertEqual(value.tab3.selected, .screen2)

        value.tab3.$none.select()
        XCTAssertEqual(value.tab3.selected, nil)
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
