//
//  CalendarView.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 17.04.2025.
//

import SwiftUI
import AnchoredPopup

public struct MonthDayBuilderParams {
    public var date: Date
    public var events: [CalendarEvent]
}

public struct WeekSwitcherDayBuilderParams {
    public var day: Date
    public var isSelected: Bool
    public var isToday: Bool
}

public struct HeaderBuilderParams {
    public var selectedDate: Binding<Date>
    public var displayMode: Binding<CalendarDisplayMode>
    public var showCalendarFilters: Binding<Bool>
    public var tapSelectDisplayModeClosure: ()->()
    public var tapFilterCalendarsClosure: ()->()
}

public struct CalendarViewCustomizationParams {
    public var hoursToFit: Int = 12
    public var horSpacing: CGFloat = 4
    public var verSpacing: CGFloat = 4
}

public struct CalendarView<DayEvent: View, MonthDay: View, WeekSwitcherDay: View, Header: View>: View {

    @ViewBuilder var dayEventBuilder: (CalendarEvent) -> DayEvent
    @ViewBuilder var monthDayBuilder: (MonthDayBuilderParams) -> MonthDay
    @ViewBuilder var weekSwitcherDayBuilder: (WeekSwitcherDayBuilderParams) -> WeekSwitcherDay
    @ViewBuilder var headerBuilder: (HeaderBuilderParams) -> Header

    public init(
        dayEventBuilder: @escaping (CalendarEvent) -> DayEvent = {
            DefaultDayEventView($0)
        },
        monthDayBuilder: @escaping (MonthDayBuilderParams) -> MonthDay = {
            DefaultMonthDayView(date: $0.date, events: $0.events)
        },
        weekSwitcherDayBuilder: @escaping (WeekSwitcherDayBuilderParams) -> WeekSwitcherDay = {
            DefaultWeekSwitcherDayView(day: $0.day, isSelected: $0.isSelected, isToday: $0.isToday)
        },
        headerBuilder: @escaping (HeaderBuilderParams) -> Header = {
            DefaultHeaderView(selectedDate: $0.selectedDate, displayMode: $0.displayMode, showCalendarFilters: $0.showCalendarFilters)
        }
    ) {
        self.dayEventBuilder = dayEventBuilder
        self.monthDayBuilder = monthDayBuilder
        self.weekSwitcherDayBuilder = weekSwitcherDayBuilder
        self.headerBuilder = headerBuilder
    }

    @StateObject var viewModel = CalendarViewModel()

    @State var selectedDate: Date = .now.startOfDay
    @State var displayMode: CalendarDisplayMode = .day
    @State var showCalendarFilters = false
    @State var updateID = UUID() // triggers downstream updates

    @State var customizationParams = CalendarViewCustomizationParams()

    public var body: some View {
        VStack {
            headerBuilder(HeaderBuilderParams(
                selectedDate: $selectedDate,
                displayMode: $displayMode,
                showCalendarFilters: $showCalendarFilters,
                tapSelectDisplayModeClosure: {
                    AnchoredPopup.launchGrowingAnimation(id: "displayMode")
                },
                tapFilterCalendarsClosure: {

                })
            )

            WeekDaysSwitcher(selectedDate: $selectedDate, anchorDate: selectedDate, calendarDisplayMode: displayMode, weekSwitcherDayBuilder: weekSwitcherDayBuilder)

            switch displayMode {
            case .day, .threeDays:
                DayView(selectedDate: $selectedDate, daysCount: displayMode == .day ? 1 : 3, events: viewModel.events, updateID: updateID, customizationParams: customizationParams, dayEventBuilder: dayEventBuilder)
            case .month:
                MonthView(selectedDate: $selectedDate, calendarDisplayMode: $displayMode, events: viewModel.events, updateID: updateID, monthDayBuilder: monthDayBuilder)
            }
        }
        .onChange(of: selectedDate, initial: true) {
            updateData()
        }
        .onChange(of: displayMode) {
            updateData()
        }
        .sheet(isPresented: $showCalendarFilters) {
            updateData() // onDismiss
        } content: {
            SelectCalendarsView(viewModel: viewModel)
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
        let start = start.startOfDay
        return switch self {
        case .day:
            DateInterval(start: start, end: start.adding(.day, value: 1))
        case .threeDays:
            DateInterval(start: start, end: start.adding(.day, value: 3))
        case .month:
            DateInterval(start: start.startOfMonth, end: start.adding(.month, value: 1))
        }
    }
}
