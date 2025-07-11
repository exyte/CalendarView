//
//  CalendarThemeKey.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 20.05.2025.
//

import SwiftUI

// MARK: - Theme

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

// MARK: - CustomizationParams

public extension EnvironmentValues {
    #if swift(>=6.0)
    @Entry var calendarCustomizationParams = CalendarViewCustomizationParams()
    #else
    var calendarCustomizationParams: CalendarViewCustomizationParams {
        get { self[CalendarCustomizationParamsKey.self] }
        set { self[CalendarCustomizationParamsKey.self] = newValue }
    }
    #endif
}

#if swift(<6.0)
@preconcurrency public struct CalendarCustomizationParamsKey: EnvironmentKey {
    nonisolated(unsafe) public static let defaultValue = CalendarViewCustomizationParams()
}
#endif

public extension EnvironmentValues {
    #if swift(>=6.0)
    @Entry var showEventDetailsClosure = (any CalendarEntity)->()
    #else
    var showEventDetailsClosure: (any CalendarEntity)->() {
        get { self[ShowEventDetailsClosureKey.self] }
        set { self[ShowEventDetailsClosureKey.self] = newValue }
    }
    #endif
}

#if swift(<6.0)
@preconcurrency public struct ShowEventDetailsClosureKey: EnvironmentKey {
    nonisolated(unsafe) public static let defaultValue = {(_: any CalendarEntity) in}
}
#endif
