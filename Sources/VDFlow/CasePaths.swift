import SwiftUI

enum RootSteps {
    
    case first(First)
    case second(Second)
}

enum First {
    
    case wow
}

enum Second {
    
    case third(Third)
}

enum Third {
    
    case int
}
