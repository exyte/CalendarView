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
    public var tapSelectDisplayModeClosure: ()->()
    public var tapFilterCalendarsClosure: ()->()
}

public class CalendarViewCustomizationParams {
    public var hoursToFit: Int = 12
    public var hourLabelFormat: String = "h a"
    public var firstDayOfWeek: Int?

    public var horSpacing: CGFloat = 4
    public var verSpacing: CGFloat = 4
    public var headerBackground: HeaderBackground = .color(.named("headerBG"))
}

public struct CalendarView<DayEvent: View, MonthDay: View, WeekSwitcherDay: View, Header: View>: View {

    @ViewBuilder var dayEventBuilder: (any CalendarEntity) -> DayEvent
    @ViewBuilder var monthDayBuilder: (MonthDayBuilderParams) -> MonthDay
    @ViewBuilder var weekSwitcherDayBuilder: (WeekSwitcherDayBuilderParams) -> WeekSwitcherDay
    @ViewBuilder var headerBuilder: (HeaderBuilderParams) -> Header

    public init(
        dayEventBuilder: @escaping (_ calendarEvent: any CalendarEntity) -> DayEvent = {
            DefaultDayEventView(entity: $0)
        },
        monthDayBuilder: @escaping (_ params: MonthDayBuilderParams) -> MonthDay = {
            DefaultMonthDayView(date: $0.date, events: $0.events)
        },
        weekSwitcherDayBuilder: @escaping (_ params: WeekSwitcherDayBuilderParams) -> WeekSwitcherDay = {
            DefaultWeekSwitcherDayView(day: $0.day, isSelected: $0.isSelected, isToday: $0.isToday)
        },
        headerBuilder: @escaping (_ params: HeaderBuilderParams) -> Header = {
            DefaultHeaderView(selectedDate: $0.selectedDate, displayMode: $0.displayMode, tapFilterCalendarsClosure: $0.tapFilterCalendarsClosure)
        }
    ) {
        self.dayEventBuilder = dayEventBuilder
        self.monthDayBuilder = monthDayBuilder
        self.weekSwitcherDayBuilder = weekSwitcherDayBuilder
        self.headerBuilder = headerBuilder
    }

    @Environment(\.calendarTheme) var theme

    @State var viewModel = CalendarViewModel()

    @BindableValue var selectedDate: Date = Date()
    @BindableValue var displayMode: CalendarDisplayMode = .day

    @State var showCalendarFilters = false
    @State var updateID = UUID() // triggers downstream updates

    // layout helpers
    @State var hoursLabelsInset: CGFloat = 0

    var customizationParams = CalendarViewCustomizationParams()

    public var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                headerBuilder(HeaderBuilderParams(
                    selectedDate: $selectedDate,
                    displayMode: $displayMode,
                    tapSelectDisplayModeClosure: {
                        AnchoredPopup.launchGrowingAnimation(id: "displayMode")
                    },
                    tapFilterCalendarsClosure: {
                        showCalendarFilters = true
                    })
                )

                WeekDaysSwitcher(selectedDate: $selectedDate, calendarDisplayMode: displayMode, hoursLabelsInset: hoursLabelsInset, weekSwitcherDayBuilder: weekSwitcherDayBuilder)
                    .padding(8)
            }
            .background {
                HeaderBackgroundView(background: customizationParams.headerBackground)
            }

            switch displayMode {
            case .day, .threeDays:
                DayLayout(selectedDate: $selectedDate, hoursLabelsInset: $hoursLabelsInset, daysCount: displayMode == .day ? 1 : 3, events: viewModel.events, reminders: viewModel.reminders, updateID: updateID, dayEventBuilder: dayEventBuilder)
                    .padding(.top, 8)
                    .background(theme.day.background)
            case .month:
                MonthLayout(selectedDate: $selectedDate, calendarDisplayMode: $displayMode, events: viewModel.events, reminders: viewModel.reminders, updateID: updateID, monthDayBuilder: monthDayBuilder)
                    .padding(.top, 8)
                    .background(theme.month.background)
            }
        }
        .environment(\.calendarCustomizationParams, customizationParams)
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

    // can't move this one to an extension, because _selectedDate is always private
    public func selectedDate(_ binding: Binding<Date>) -> CalendarView {
        var copy = self
        copy._selectedDate.bind(binding)
        return copy
    }

    public func displayMode(_ binding: Binding<CalendarDisplayMode>) -> CalendarView {
        var copy = self
        copy._displayMode.bind(binding)
        return copy
    }
}

public enum CalendarDisplayMode: Sendable {
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
