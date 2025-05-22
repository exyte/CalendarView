//
//  PublicAPI.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 30.04.2025.
//

import SwiftUI

extension CalendarView {

//    public func selectedDate(_ selectedDate: Binding<Date>) -> CalendarView {
//        var calendar = self
//        calendar._selectedDate = selectedDate
//        return calendar
//    }

    public func hoursToFit(_ hoursToFit: Int) -> CalendarView {
        if hoursToFit > 24 {
            print("Please specify hoursToFit's value less or equal to 24")
            return self
        }
        self.customizationParams.hoursToFit = hoursToFit
        return self
    }

    /// Background for header and week picker
    public func headerBackground(_ background: HeaderBackground) -> CalendarView {
        self.customizationParams.headerBackground = background
        return self
    }

    public func headerBackground<Content: View>(viewBuilder: @escaping () -> Content) -> CalendarView {
        self.customizationParams.headerBackground = HeaderBackground(viewBuilder: viewBuilder)
        return self
    }
}

public enum HeaderBackground {
    case none
    case color(Color)
    case view(AnyView)

    // Convenience initializer for `view` that automatically wraps the content in `AnyView`
    public init<Content: View>(viewBuilder: @escaping () -> Content) {
        self = .view(AnyView(viewBuilder()))
    }
}

struct HeaderBackgroundView: View {
    var background: HeaderBackground

    var body: some View {
        Group {
            switch background {
            case .none:
                EmptyView()
            case .color(let color):
                color
            case .view(let anyView):
                anyView
            }
        }
        .ignoresSafeArea()
    }
}
