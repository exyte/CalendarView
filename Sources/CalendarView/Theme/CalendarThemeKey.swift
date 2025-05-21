//
//  CalendarThemeKey.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 20.05.2025.
//

import SwiftUI

public extension EnvironmentValues {
    #if swift(>=6.0)
    @Entry var calendarTheme = CalendarTheme()
    #else
    var calendarTheme: CalendarTheme {
        get { self[CalendarThemeKey.self] }
        set { self[CalendarThemeKey.self] = newValue }
    }
    #endif
}

#if swift(<6.0)
@preconcurrency public struct CalendarThemeKey: EnvironmentKey {
    public static let defaultValue = CalendarTheme(main: .init(), year: .init())
}
#endif

public extension View {
    func calendarTheme(_ theme: CalendarTheme) -> some View {
        self.environment(\.calendarTheme, theme)
    }
}
