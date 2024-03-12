import Foundation
import XCTest
@testable import VDFlow
import SwiftUI

final class VDFlowTestsCase: XCTestCase {
    
    func testMacros() {
        var value = TabSteps()
        print(value.selected)
        value.tab3.screen2.text2.select()
        print(value.selected)
    }
}

struct T: View {

    @StateStep var step: TabSteps

    var body: some View {
        Text("Hello, World!")
            .onAppear {
            }
    }
}

@Steps
public struct TabSteps {
    public var tab1
    public var tab2 = 0
    public var tab3 = NavigationSteps()
}

@Steps
public struct NavigationSteps {
    public var screen1
    public var screen2 = PickerSteps()
}

@Steps
public struct PickerSteps {
    public var text1
    public var text2
}
