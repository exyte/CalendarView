//
//  DayInWeekSwitcher.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 17.04.2025.
//

import SwiftUI

/// Select a day from a week, scroll between weeks
struct DayInWeekSwitcher<WeekSwitcherDay: View>: View {
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
                weekSwitcherDayBuilder(WeekSwitcherDayBuilderParams(day: selectedDate, isSelected: true, isToday: true, monthDisplayMode: false))
            }

            switch calendarDisplayMode {
            case .day:
                fullWeekView(monthDisplayMode: false)
            case .threeDays:
                threeDayWeekView
            case .month:
                fullWeekView(monthDisplayMode: true)
            }
        }
    }

    @ViewBuilder
    func fullWeekView(monthDisplayMode: Bool) -> some View {
        GeometryReader { g in
            createSimpleInfiniteTableView(items: $items) { item in
                HStack(spacing: 0) {
                    let startOfWeek = selectedDate.startOfWeek(customizationParams.firstDayOfWeek).startOfDay.adding(.day, value: item*7)
                    ForEach(0..<7, id: \.self) { i in
                        dayView(startDay: startOfWeek, index: i, monthDisplayMode: monthDisplayMode)
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
            createSimpleInfiniteTableView(items: $items) { item in
                dayView(startDay: selectedDate, index: item, monthDisplayMode: false)
            }
            .scrollLayout(.horizontal)
            .scrollMode(scrollMode: .paged(g.size.width / 3))
            .willDisplayItem { item in
                anchorDate = selectedDate.startOfDay.adding(.day, value: item)
            }
            .reloadTrigger(updateID: tableUpdateID)
            .id(tableUpdateID)
        }
        .frame(height: daySize?.height)
        .padding(.leading, hoursLabelsInset)
    }

    @ViewBuilder
    private func dayView(startDay: Date, index: Int, monthDisplayMode: Bool) -> some View {
        let day = startDay.adding(.day, value: index)
        let isSelected = calendar.isDate(day, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(day)

        weekSwitcherDayBuilder(WeekSwitcherDayBuilderParams(day: day, isSelected: isSelected, isToday: isToday, monthDisplayMode: monthDisplayMode))
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
