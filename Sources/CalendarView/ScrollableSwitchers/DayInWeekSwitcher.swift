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
    @EnvironmentObject var viewModel: CalendarViewModel

    @Binding var selectedDate: Date
    @Binding var anchorDate: Date // first day of currently on screen week. selectedData could be off screen, so need to track this through another variable

    var calendarDisplayMode: CalendarDisplayMode
    var hoursLabelsInset: CGFloat
    @ViewBuilder var weekSwitcherDayBuilder: (WeekSwitcherDayBuilderParams) -> WeekSwitcherDay

    @StateObject private var weekCellsModel = WeekCellsModel()

    @State private var daySize: CGSize?
    @State private var items = Array(-5...5)
    @State private var pageItems = Array(-1...1)
    @State private var tableUpdateID = UUID()

    private var calendar: Calendar { Calendar.current }

    var body: some View {
        ZStack {
            MeasuringTrickView(size: $daySize) {
                weekSwitcherDayBuilder(WeekSwitcherDayBuilderParams(viewModel: weekCellsModel, day: selectedDate, monthDisplayMode: false))
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
            self.weekCellsModel.selectedDate = selectedDate
        }
        .onChange(of: selectedDate) { _, _ in
            self.weekCellsModel.selectedDate = selectedDate
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
                    let startOfWeek = selectedDate.startOfWeek(customizationParams.firstDayOfWeek).startOfDay.adding(.day, value: item*7)
                    ForEach(0..<7, id: \.self) { i in
                        dayView(startDay: startOfWeek, index: i, monthDisplayMode: false)
                    }
                }
            }
            .scrollLayout(.horizontal)
            .scrollMode(scrollMode: .paged(g.size.width))
            .isPagingEnabled(customizationParams.isDayInWeekSwitcherPagingEnabled)
            .willDisplayItem { item in
                anchorDate = selectedDate.startOfWeek(customizationParams.firstDayOfWeek).startOfDay.adding(.day, value: item*7)
            }
            .reloadTrigger(updateID: tableUpdateID)
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
        }
        .frame(height: daySize?.height)
        .padding(.leading, hoursLabelsInset)
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
                        self.selectedDate = day
                        self.weekCellsModel.selectedDate = day
                    }
                )
            }
    }
}

class WeekCellsModel: ObservableObject {
    @Published var selectedDate: Date?
}
