//
//  BindableValue.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 15.04.2025.
//

import SwiftUI

@propertyWrapper
public struct BindableValue<Value: Sendable>: DynamicProperty, Sendable {
    @State private var internalValue: Value
    private var externalBinding: Binding<Value>?

    public var wrappedValue: Value {
        get { externalBinding?.wrappedValue ?? internalValue }
        nonmutating set {
            if let _ = externalBinding {
                externalBinding?.wrappedValue = newValue
            } else {
                internalValue = newValue
            }
        }
    }

    public var projectedValue: Binding<Value> {
        Binding(get: { self.wrappedValue }, set: { self.wrappedValue = $0 })
    }

    public init(wrappedValue: Value) {
        _internalValue = State(wrappedValue: wrappedValue)
        externalBinding = nil
    }

    public mutating func bind(_ binding: Binding<Value>) {
        self.externalBinding = binding
    }
}
