//
//  DayInMonthSwitcher.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 18.06.2025.
//

import SwiftUI

/// Select a day from a month, scroll between months
struct DayInMonthSwitcher<MonthDay: View>: View {
    @Environment(\.calendarTheme) var theme
    @Environment(CalendarViewModel.self) var viewModel

    @Binding var fullscreenDate: Date
    @Binding var calendarDisplayMode: CalendarDisplayMode
    @ViewBuilder var monthDayBuilder: (MonthDayBuilderParams) -> MonthDay

    @State private var items: [Int] = []
    @State private var models: [Int: MonthCellModel] = [:]
    @State private var dateInterval = DateInterval(start: Date(), end: Date())
    @State private var tableUpdateID = UUID()

    @State private var monthCellSize: CGSize?

    let today = Date()

    var body: some View {
        GeometryReader { g in
            InfiniteTableView(data: $items, cellModels: $models) { direction, pageSize in
                switch direction {
                case .backward:
                    guard let first = items.first else { return }
                    for offset in 1...pageSize {
                        let item = first - offset
                        items.insert(item, at: 0)
                        models[item] = MonthCellModel(id: item)
                    }
                case .forward:
                    guard let last = items.last else { return }
                    for offset in 1...pageSize {
                        let item = last + offset
                        items.append(item)
                        models[item] = MonthCellModel(id: item)
                    }
                }
            } content: { item, model in
                VStack(alignment: .leading, spacing: 0) {
                    let monthDate = fullscreenDate.startOfMonth.adding(.month, value: item)
                    let isCurrentMonth = monthDate.startOfMonth == today.startOfMonth
                    Text(monthDate.formatted("MMMM, y")).systemFont(32, .semibold, isCurrentMonth ? theme.year.todayText : theme.year.monthText)
                        .padding(16, 10)

                    MonthLayout(date: monthDate, viewModel: model, monthDayBuilder: monthDayBuilder) { day in
                        fullscreenDate = day
                        calendarDisplayMode = .day
                    }
                }
                .frame(height: g.size.height)
                .background(theme.month.background)
            }
            .reloadTrigger(updateID: tableUpdateID)
            .scrollMode(scrollMode: .free(monthCellSize?.height))
            .willDisplayItem { item in
                Task { @MainActor in
                    let monthDate = fullscreenDate.startOfMonth.adding(.month, value: item)
                    let interval = DateInterval(start: monthDate.adding(.month, value: -1), end: monthDate.adding(.month, value: 2))
                    if dateInterval == interval { return }
                    await viewModel.fetch(interval)
                    // viewModel.events is now up to date — distribute to the three visible models
                    models[item-1]?.events = eventsFor(monthDate.adding(.month, value: -1))
                    models[item]?.events = eventsFor(monthDate)
                    models[item+1]?.events = eventsFor(monthDate.adding(.month, value: 1))
                    dateInterval = interval
                }
            }
        }
        .onChange(of: fullscreenDate, initial: true) {
            Task {
                items = Array(-3...3)
                models.removeAll()
                for item in items {
                    models[item] = MonthCellModel(id: item)
                }
                tableUpdateID = UUID()
                await viewModel.fetch(DateInterval(start: fullscreenDate.startOfMonth, end: fullscreenDate.startOfMonth.adding(.month, value: 1)))
                models[0]?.events = viewModel.events
            }
        }
        .onDisappear {
            viewModel.resetCache()
            items.removeAll()
            models.removeAll()
        }
        .background {
            MeasuringTrickView(size: $monthCellSize) {
                MonthLayout(date: Date(), viewModel: MonthCellModel(id: 0), monthDayBuilder: monthDayBuilder, didSelectDay: {_ in})
            }
        }
    }

    func eventsFor(_ date: Date) -> [CalendarEvent] {
        viewModel.events.filter { $0.startDate.startOfMonth == date }
    }

    func remindersFor(_ date: Date) -> [CalendarReminder] {
        viewModel.reminders.filter { $0.startDate.startOfMonth == date }
    }
}

@Observable
class MonthCellModel: Identifiable {
    let id: Int

    var events: [CalendarEvent] = []

    init(id: Int) {
        self.id = id
    }
}
