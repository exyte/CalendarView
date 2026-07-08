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
    @Environment(MonthScrollCoordinator.self) var monthCoordinator

    @Binding var fullscreenDate: Date
    @Binding var anchorDate: Date // first day of currently on screen week

    var calendarDisplayMode: CalendarDisplayMode
    @ViewBuilder var weekSwitcherDayBuilder: (WeekSwitcherDayBuilderParams) -> WeekSwitcherDay

    @State private var daySize: CGSize?
    @State private var monthDaySize: CGSize?
    @State private var contentHeight: CGFloat?
    @State private var weekItems = [0]
    @State private var tableUpdateID = UUID()

    var body: some View {
        ZStack(alignment: .top) {
            FinalMeasuringTrickView(size: $daySize) {
                weekSwitcherDayBuilder(WeekSwitcherDayBuilderParams(day: fullscreenDate, monthDisplayMode: false, fullscreenDate: fullscreenDate))
            }

            FinalMeasuringTrickView(size: $monthDaySize) {
                weekSwitcherDayBuilder(WeekSwitcherDayBuilderParams(day: fullscreenDate, monthDisplayMode: true, fullscreenDate: fullscreenDate))
            }

            if daySize != nil {
                mainWeekView
            }
        }
        .frame(height: contentHeight)
        .clipped()
        .onChange(of: calendarDisplayMode) { _, newMode in
            withAnimation(.default) {
                contentHeight = newMode == .month ? (monthDaySize?.height ?? daySize?.height) : daySize?.height
            }
        }
        .onChange(of: daySize) { _, newSize in
            contentHeight = calendarDisplayMode == .month ? (monthDaySize?.height ?? newSize?.height) : newSize?.height
        }
        .onChange(of: monthDaySize) { _, newSize in
            contentHeight = calendarDisplayMode == .month ? (newSize?.height ?? daySize?.height) : daySize?.height
        }
        .onChange(of: fullscreenDate) { _, _ in
            weekItems = [0]
            tableUpdateID = UUID()
        }
        .onChange(of: monthCoordinator.scrollToTodayToken) {
            weekItems = [0]
            tableUpdateID = UUID()
        }
    }

    @ViewBuilder
    var mainWeekView: some View {
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
                    dayView(startDay: startOfWeek, index: i)
                }
            }
        }
        .id(tableUpdateID)
        .allowsHitTesting(calendarDisplayMode != .month)
    }

    @ViewBuilder
    private func dayView(startDay: Date, index: Int) -> some View {
        let day = startDay.adding(.day, value: index)
        let monthDisplayMode = calendarDisplayMode == .month

        weekSwitcherDayBuilder(WeekSwitcherDayBuilderParams(day: day, monthDisplayMode: monthDisplayMode, fullscreenDate: fullscreenDate))
            .greedyWidth()
            .simultaneousGesture(
                TapGesture().onEnded {
                    guard !monthDisplayMode else { return }
                    self.fullscreenDate = day
                }
            )
    }
}
