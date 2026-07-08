//
//  PublicInit.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 29.06.2026.
//

import SwiftUI

public struct CalendarViewCustomizationParams {
    public var hoursToFit: CGFloat = 12
    public var hourLabelFormat: String = "h a"
    public var firstDayOfWeek: Int?
    public var isDayInWeekSwitcherPagingEnabled: Bool = true

    public var horSpacing: CGFloat = 4
    public var verSpacing: CGFloat = 4

    public var headerBackground: HeaderBackground = .color(Color(.appAccentLight), 10)
    public var eventDetailsClosure: ((any CalendarEntity)->())?

    public var customFontName: String? = nil
    public var useDynamicType: Bool = false
}

public struct CalendarDefaults {
    public static let defaultProviders: [CalendarsProvider] = [AppleCalendarsProvider(), LocalCalendarsProvider()]
}

public struct MonthDayBuilderParams {
    public var date: Date
    public var events: [any CalendarEntity]
    public var viewHeight: CGFloat
}

public struct WeekSwitcherDayBuilderParams {
    public var day: Date
    public var monthDisplayMode: Bool
    public var fullscreenDate: Date
}

/// `fullscreenDate` - date displayed in DayLayout (leftmost one in 2-3 days mode)
///  note: makes little sense for month mode, since selecting any date there leads to .day mode, with selected date as fullscreenDate
/// `anchorDate` - date around which current time interval is calculated
/// - e.g. mode = .month, anchorDate = March 3rd, displayed time interval = March 1st - March 31st
/// - e.g. mode = .3days, anchorDate = March 3rd, displayed time interval = March 3st - March 5th
public struct HeaderBuilderParams {
    public var fullscreenDate: Binding<Date>
    public var anchorDate: Binding<Date>
    public var displayMode: Binding<CalendarDisplayMode>
    public var tapSelectDisplayModeClosure: ()->()
    public var tapFilterCalendarsClosure: ()->()
    public var tapAddEventClosure: ()->()
    public var tapGoToTodayClosure: ()->() = {}

    @MainActor public func defaultWeekSwitcher() -> some View {
        DayInWeekSwitcher(
            fullscreenDate: fullscreenDate,
            anchorDate: anchorDate,
            calendarDisplayMode: displayMode.wrappedValue,
            weekSwitcherDayBuilder: { DefaultDayInWeekView(params: $0) }
        )
    }

    @MainActor public func defaultWeekSwitcher<WeekSwitcherDay: View>(
        @ViewBuilder weekSwitcherDayBuilder: @escaping (WeekSwitcherDayBuilderParams) -> WeekSwitcherDay
    ) -> some View {
        DayInWeekSwitcher(
            fullscreenDate: fullscreenDate,
            anchorDate: anchorDate,
            calendarDisplayMode: displayMode.wrappedValue,
            weekSwitcherDayBuilder: weekSwitcherDayBuilder
        )
    }
}
