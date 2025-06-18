//
//  Untitled.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 17.04.2025.
//

import SwiftUI

struct WeekDaysSwitcher<WeekSwitcherDay: View>: View {
    @Environment(\.calendarTheme) private var theme
    @Environment(\.calendarCustomizationParams) var customizationParams

    @Binding var selectedDate: Date
    @Binding var anchorDate: Date // first day of currently on screen week. selectedData could be off screen, so need to track this through another variable

    var calendarDisplayMode: CalendarDisplayMode
    var hoursLabelsInset: CGFloat
    @ViewBuilder var weekSwitcherDayBuilder: (WeekSwitcherDayBuilderParams) -> WeekSwitcherDay

    private var calendar: Calendar { Calendar.current }

    @State private var daySize: CGSize?
    @State private var items = Array(-5...5)
    @State private var tableUpdateID = UUID() // triggers table update

    var body: some View {
        ZStack {
            MeasuringTrickView(size: $daySize) {
                weekSwitcherDayBuilder(WeekSwitcherDayBuilderParams(day: selectedDate, isSelected: true, isToday: true))
            }

            switch calendarDisplayMode {
            case .day:
                fullWeekView
            case .threeDays:
                threeDayWeekView
            case .month:
                weekdaysOnlyView
            }
        }
    }

    @ViewBuilder
    var fullWeekView: some View {
        GeometryReader { g in
            createSimpleTableView(items: $items) { item in
                HStack(spacing: 0) {
                    let startOfWeek = selectedDate.startOfWeek(customizationParams.firstDayOfWeek).startOfDay.adding(.day, value: item*7)
                    ForEach(0..<7, id: \.self) { i in
                        dayView(startDay: startOfWeek, index: i)
                    }
                }
            }
            .scrollLayout(.horizontal)
            .scrollMode(scrollMode: .paged(g.size.width))
            .willDisplayItem { item in
                anchorDate = selectedDate.startOfWeek(customizationParams.firstDayOfWeek).startOfDay.adding(.day, value: item*7)
            }
            .reloadTrigger(updateID: tableUpdateID) // trigger new table recentering when new date is selected...
            .id(tableUpdateID) // ...+ have to rerender the whole thing to pass updated selectedDate into otherwise cached cells
        }
        .frame(height: daySize?.height)
    }

    var threeDayWeekView: some View {
        GeometryReader { g in
            createSimpleTableView(items: $items) { item in
                dayView(startDay: selectedDate, index: item)
            }
            .scrollLayout(.horizontal)
            .scrollMode(scrollMode: .paged(g.size.width / 3))
            .willDisplayItem { item in
                anchorDate = selectedDate.startOfDay.adding(.day, value: item)
            }
            .reloadTrigger(updateID: tableUpdateID)
        }
        .frame(height: daySize?.height)
        .padding(.leading, hoursLabelsInset)
    }

    @ViewBuilder
    var weekdaysOnlyView: some View {
        let startOfWeek = Date().startOfWeek(customizationParams.firstDayOfWeek)
        HStack(spacing: 8) {
            ForEach(0..<7, id: \.self) { i in
                let day = startOfWeek.adding(.day, value: i)
                Text(day.formatted("EEE"))
                    .systemFont(15, theme.week.text)
                    .greedyWidth()
            }
        }
        .frame(height: daySize?.height)
    }

    @ViewBuilder
    private func dayView(startDay: Date, index: Int) -> some View {
        let day = startDay.adding(.day, value: index)
        let isSelected = calendar.isDate(day, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(day)

        weekSwitcherDayBuilder(WeekSwitcherDayBuilderParams(day: day, isSelected: isSelected, isToday: isToday))
            .simultaneousGesture(
                TapGesture().onEnded {
                    self.selectedDate = day
                    self.items = Array(-5...5)
                    self.tableUpdateID = UUID()
                }
            )
        .greedyWidth()
    }
}

public struct DefaultWeekSwitcherDayView: View {
    @Environment(\.calendarTheme) private var theme

    var day: Date
    var isSelected: Bool
    var isToday: Bool

    var isWeekend: Bool { day.isWeekend }

    public init(day: Date, isSelected: Bool, isToday: Bool) {
        self.day = day
        self.isSelected = isSelected
        self.isToday = isToday
    }

    public var body: some View {
        let textColor =
        isSelected && isToday ? theme.week.todaySelectedText :
        isSelected ? theme.week.selectedText :
        isToday ? theme.week.todayText :
        isWeekend ? theme.week.weekendText :
        theme.week.text

        let bgColor =
        isSelected && isToday ? theme.week.todaySelectedBackground :
        isSelected ? theme.week.selectedBackground :
        isToday ? theme.week.todayBackground :
        theme.week.background

        VStack(spacing: 10) {
            Text(day.formatted("EEE")).font(.system(size: 15))
                .systemFont(15, isWeekend ? theme.week.weekendText : theme.week.text)
                .lineLimit(1)
            Text(day.formatted("d")).font(.system(size: 17, weight: .semibold))
                .systemFont(17, .semibold, textColor)
                .lineLimit(1)
                .padding(8)
                .background(bgColor)
                .clipShape(Circle())
        }
    }
}
