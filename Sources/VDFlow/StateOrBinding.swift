//
//  File.swift
//  
//
//  Created by Данил Войдилов on 22.08.2021.
//

import SwiftUI

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
@propertyWrapper
enum StateOrBinding<Value>: DynamicProperty {
    
    case binding(Binding<Value>), state(State<Value>)
    
		var wrappedValue: Value {
        get {
            switch self {
            case .binding(let binding): return binding.wrappedValue
            case .state(let state): return state.wrappedValue
            }
        }
        nonmutating set {
            switch self {
            case .binding(let binding): binding.wrappedValue = newValue
            case .state(let state): state.wrappedValue = newValue
            }
        }
    }
    
		var projectedValue: Binding<Value> {
        switch self {
        case .binding(let binding): return binding
        case .state(let state): return state.projectedValue
        }
    }
    
		init(wrappedValue: Value) {
        self = .state(.init(wrappedValue: wrappedValue))
    }
    
		static func state(_ wrappedValue: Value) -> StateOrBinding {
        .state(.init(wrappedValue: wrappedValue))
    }
}
