//
//  DayInWeekSwitcher.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 17.04.2025.
//

import SwiftUI

/// Select a day from a week, scroll between weeks
struct DayInWeekSwitcher<WeekSwitcherDay: View>: View {
    @Environment(\.calendarTheme) var theme
    @Environment(\.calendarCustomizationParams) var customizationParams

    @Binding var fullscreenDate: Date
    @Binding var anchorDate: Date // first day of currently on screen week

    var calendarDisplayMode: CalendarDisplayMode
    @ViewBuilder var weekSwitcherDayBuilder: (WeekSwitcherDayBuilderParams) -> WeekSwitcherDay

    @State private var daySize: CGSize?
    @State private var weekItems = [0]
    @State private var tableUpdateID = UUID()

    var body: some View {
        ZStack {
            FinalMeasuringTrickView(size: $daySize) {
                weekSwitcherDayBuilder(WeekSwitcherDayBuilderParams(day: fullscreenDate, monthDisplayMode: false, fullscreenDate: fullscreenDate))
            }

            Group {
                if daySize != nil {
                    switch calendarDisplayMode {
                    case .day, .twoDays, .threeDays:
                        fullWeekView
                    case .month:
                        weekdaysOnlyView
                    }
                }
            }
            .frame(height: daySize?.height)
        }
        .onChange(of: fullscreenDate) { _, _ in
            weekItems = [0]
            tableUpdateID = UUID()
        }
    }

    @ViewBuilder
    var fullWeekView: some View {
        EndlessPager(items: $weekItems, onNeedMore: { edge in
            switch edge {
            case .leading:
                guard let first = weekItems.first else { return }
                weekItems.insert(contentsOf: (1...2).map { first - $0 }.reversed(), at: 0)
            case .trailing:
                guard let last = weekItems.last else { return }
                weekItems.append(contentsOf: (1...2).map { last + $0 })
            }
        }, onItemChanged: { item in
            anchorDate = fullscreenDate.startOfWeek(customizationParams.firstDayOfWeek).startOfDay.adding(.day, value: item * 7)
        }) { item in
            HStack(spacing: 0) {
                let startOfWeek = fullscreenDate.startOfWeek(customizationParams.firstDayOfWeek).startOfDay.adding(.day, value: item * 7)
                ForEach(0..<7, id: \.self) { i in
                    dayView(startDay: startOfWeek, index: i, monthDisplayMode: false)
                }
            }
        }
        .id(tableUpdateID)
    }

    @ViewBuilder
    var weekdaysOnlyView: some View {
        let startOfWeek = Date().startOfWeek(customizationParams.firstDayOfWeek)
        HStack(spacing: 8) {
            ForEach(0..<7, id: \.self) { i in
                dayView(startDay: startOfWeek, index: i, monthDisplayMode: true)
                    .greedyWidth()
            }
        }
    }

    @ViewBuilder
    private func dayView(startDay: Date, index: Int, monthDisplayMode: Bool) -> some View {
        let day = startDay.adding(.day, value: index)

        weekSwitcherDayBuilder(WeekSwitcherDayBuilderParams(day: day, monthDisplayMode: monthDisplayMode, fullscreenDate: fullscreenDate))
            .greedyWidth()
            .applyIf(!monthDisplayMode) {
                $0.simultaneousGesture(
                    TapGesture().onEnded {
                        self.fullscreenDate = day
                    }
                )
            }
    }
}
