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
    @Environment(CalendarViewModel.self) var viewModel

    @Binding var fullscreenDate: Date
    @Binding var anchorDate: Date // first day of currently on screen week. selectedData could be off screen, so need to track this through another variable

    var calendarDisplayMode: CalendarDisplayMode
    @ViewBuilder var weekSwitcherDayBuilder: (WeekSwitcherDayBuilderParams) -> WeekSwitcherDay

    @State private var weekCellsModel = WeekCellsModel()

    @State private var daySize: CGSize?
    @State private var items = Array(-5...5)
    @State private var pageItems = Array(-1...1)
    @State private var tableUpdateID = UUID()

    private var calendar: Calendar { Calendar.current }

    var body: some View {
        ZStack {
            MeasuringTrickView(size: $daySize) {
                weekSwitcherDayBuilder(WeekSwitcherDayBuilderParams(viewModel: weekCellsModel, day: fullscreenDate, monthDisplayMode: false))
            }

            switch calendarDisplayMode {
            case .day, .twoDays:
                fullWeekView
            case .threeDays:
                fullWeekView
            case .month:
                weekdaysOnlyView
            }
        }
        .onAppear {
            self.weekCellsModel.date = fullscreenDate
        }
        .onChange(of: fullscreenDate) { _, _ in
            self.weekCellsModel.date = fullscreenDate
            pageItems = Array(-1...1)
            items = Array(-5...5)
            tableUpdateID = UUID()
        }
    }

    @ViewBuilder
    var fullWeekView: some View {
        GeometryReader { g in
            createSimpleInfiniteTableView(items: customizationParams.isDayInWeekSwitcherPagingEnabled ? $pageItems : $items) { item in
                HStack(spacing: 0) {
                    let startOfWeek = fullscreenDate.startOfWeek(customizationParams.firstDayOfWeek).startOfDay.adding(.day, value: item*7)
                    ForEach(0..<7, id: \.self) { i in
                        dayView(startDay: startOfWeek, index: i, monthDisplayMode: false)
                    }
                }
            }
            .scrollLayout(.horizontal)
            .scrollMode(scrollMode: .paged(g.size.width))
            .isPagingEnabled(customizationParams.isDayInWeekSwitcherPagingEnabled)
            .willDisplayItem { item in
                anchorDate = fullscreenDate.startOfWeek(customizationParams.firstDayOfWeek).startOfDay.adding(.day, value: item*7)
            }
            .reloadTrigger(updateID: tableUpdateID)
        }
        .frame(height: daySize?.height)
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
        .frame(height: daySize?.height)
    }

    @ViewBuilder
    private func dayView(startDay: Date, index: Int, monthDisplayMode: Bool) -> some View {
        let day = startDay.adding(.day, value: index)

        weekSwitcherDayBuilder(WeekSwitcherDayBuilderParams(viewModel: weekCellsModel, day: day, monthDisplayMode: monthDisplayMode))
            .greedyWidth()
            .applyIf(!monthDisplayMode) {
                $0.simultaneousGesture(
                    TapGesture().onEnded {
                        self.fullscreenDate = day
                        self.weekCellsModel.date = day
                    }
                )
            }
    }
}

@Observable
class WeekCellsModel {
    var date: Date?
}
