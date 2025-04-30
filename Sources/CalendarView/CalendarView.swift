//
//  CalendarView.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 17.04.2025.
//

import SwiftUI
import AnchoredPopup

public struct CalendarView<DayEvent: View, MonthDay: View, WeekSwitcherDay: View, Header: View>: View {
    @ViewBuilder var dayEventBuilder: (CalendarEvent) -> DayEvent

    @ViewBuilder var monthDayBuilder: (
        _ date: Date,
        _ events: [CalendarEvent]
    ) -> MonthDay

    @ViewBuilder var weekSwitcherDayBuilder: (
        _ day: Date,
        _ isSelected: Bool,
        _ isToday: Bool
    ) -> WeekSwitcherDay

    @ViewBuilder var headerBuilder: (
        _ selectedDate: Binding<Date>,
        _ displayMode: Binding<CalendarDisplayMode>,
        _ tapSelectDisplayModeClosure: @escaping ()->(),
        _ tapFilterCalendarsClosure: @escaping ()->()
    ) -> Header

    public init(
        dayEventBuilder: @escaping (CalendarEvent) -> DayEvent = { DefaultDayEventView($0) },
        monthDayBuilder: @escaping (Date, [CalendarEvent]) -> MonthDay = { DefaultMonthDayView(date: $0, events: $1) },
        weekSwitcherDayBuilder: @escaping (Date, Bool, Bool) -> WeekSwitcherDay = { DefaultWeekSwitcherDayView(day: $0, isSelected: $1, isToday: $2) },
        headerBuilder: @escaping (Binding<Date>, Binding<CalendarDisplayMode>, @escaping ()->(), @escaping  ()->()) -> Header = { s, d, _, _ in
            DefaultHeaderView(selectedDate: s, displayMode: d)
        }
    ) {
        self.dayEventBuilder = dayEventBuilder
        self.monthDayBuilder = monthDayBuilder
        self.weekSwitcherDayBuilder = weekSwitcherDayBuilder
        self.headerBuilder = headerBuilder

     //   self._selectedDate = .constant(.now.startOfDay)
    }

    @StateObject var viewModel = CalendarViewModel()

    @State var selectedDate: Date = .now.startOfDay
    @State var displayMode: CalendarDisplayMode = .day
    @State var updateID = UUID() // triggers downstream updates

    // customization

    var hoursToFit: Int = 12

    public var body: some View {
        VStack {
            headerBuilder($selectedDate, $displayMode) {
                AnchoredPopup.launchGrowingAnimation(id: "displayMode")
            } _: {

            }

            WeekDaysSwitcher(selectedDate: $selectedDate, anchorDate: selectedDate, calendarDisplayMode: displayMode, weekSwitcherDayBuilder: weekSwitcherDayBuilder)

            if displayMode == .day {
                DayView(events: viewModel.events, selectedDate: $selectedDate, updateID: updateID, horSpacing: 4, verSpacing: 4, hoursToFit: hoursToFit, dayEventBuilder: dayEventBuilder)
            } else if displayMode == .month {
                MonthView(events: viewModel.events, selectedDate: $selectedDate, calendarDisplayMode: $displayMode, updateID: updateID, monthDayBuilder: monthDayBuilder)
            }
        }
        .onChange(of: selectedDate, initial: true) {
            updateData()
        }
        .onChange(of: displayMode) {
            updateData()
        }
    }

    func updateData() {
        Task {
            await viewModel.fetch(displayMode.interval(selectedDate))
            updateID = UUID()
        }
    }

//        public func selectedDate(_ selectedDate: Binding<Date>) -> CalendarView {
//            var calendar = self
//            calendar._selectedDate = selectedDate
//            return calendar
//        }
}

public enum CalendarDisplayMode {
    case day, threeDays, month

    func interval(_ start: Date) -> DateInterval {
        switch self {
        case .day:
            DateInterval(start: start, end: start.adding(.day, value: 1))
        case .threeDays:
            DateInterval(start: start, end: start.adding(.day, value: 3))
        case .month:
            DateInterval(start: start.startOfMonth, end: start.adding(.month, value: 1))
        }
    }
}
