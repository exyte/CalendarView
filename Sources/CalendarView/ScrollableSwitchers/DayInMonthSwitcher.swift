//
//  DayInMonthSwitcher.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 18.06.2025.
//

import SwiftUI

/// Select a day from a month, scroll between months
struct DayInMonthSwitcher<MonthDay: View>: View {
    @Environment(\.calendarTheme) private var theme
    @EnvironmentObject var viewModel: CalendarViewModel

    @Binding var selectedDate: Date
    @Binding var calendarDisplayMode: CalendarDisplayMode
    @ViewBuilder var monthDayBuilder: (MonthDayBuilderParams) -> MonthDay

    @State private var items: [Int] = []
    @State private var models: [Int: MonthCellModel] = [:]
    @State private var dateInterval = DateInterval(start: Date(), end: Date())
    @State private var tableUpdateID = UUID()

    let today = Date()

    var body: some View {
        GeometryReader { g in
            InfiniteTableView(data: $items, cellModels: $models) { direction, pageSize in
                DispatchQueue.main.async {
                    switch direction {
                    case .backward:
                        for _ in 0..<pageSize {
                            let item = items.first! - 1
                            items.insert(item, at: 0)
                            models[item] = MonthCellModel(id: item)
                        }
                    case .forward:
                        for _ in 0..<pageSize {
                            let item = items.last! + 1
                            items.append(item)
                            models[item] = MonthCellModel(id: item)
                        }
                    }
                }
            } content: { item, model in
                VStack(alignment: .leading, spacing: 0) {
                    let monthDate = selectedDate.startOfMonth.adding(.month, value: item)
                    let isCurrentMonth = monthDate.startOfMonth == today.startOfMonth
                    Text(monthDate.formatted("MMMM, y")).systemFont(32, .semibold, isCurrentMonth ? theme.year.todayText : theme.year.monthText)
                        .padding(16, 10)

                    MonthLayout(date: monthDate, viewModel: model, monthDayBuilder: monthDayBuilder) { day in
                        selectedDate = day
                        calendarDisplayMode = .day
                    }
                }
                .frame(height: g.size.height)
                .background(theme.month.background)
            }
            .reloadTrigger(updateID: tableUpdateID)
            .willDisplayItem { item in
                Task.detached {
                    let monthDate = await selectedDate.startOfMonth.adding(.month, value: item)
                    let interval = DateInterval(start: monthDate.adding(.month, value: -1), end: monthDate.adding(.month, value: 2))
                    if await dateInterval == interval { return }
                    await viewModel.fetch(interval)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { ///?????
                        models[item-1]?.events = eventsFor(monthDate.adding(.month, value: -1))
                        models[item]?.events = eventsFor(monthDate)
                        models[item+1]?.events = eventsFor(monthDate.adding(.month, value: 1))
                        //reloadItemsSubject.send(toReload)
                        dateInterval = interval
                    }
                }
            }
        }
//        .task {
//            items = Array(-3...3)
//            for item in items {
//                models[item] = MonthCellModel(id: item)
//            }
//            await viewModel.fetch(DateInterval(start: selectedDate.startOfMonth, end: selectedDate.startOfMonth.adding(.month, value: 1)))
//            models[0]?.events = viewModel.events
//        }
        .onChange(of: selectedDate, initial: true) {
            Task {
                items = Array(-3...3)
                models.removeAll()
                for item in items {
                    models[item] = MonthCellModel(id: item)
                }
                tableUpdateID = UUID()
                await viewModel.fetch(DateInterval(start: selectedDate.startOfMonth, end: selectedDate.startOfMonth.adding(.month, value: 1)))
                models[0]?.events = viewModel.events
            }
        }
        .onDisappear {
            viewModel.resetCache()
            items.removeAll()
            models.removeAll()
        }
    }

    func eventsFor(_ date: Date) -> [CalendarEvent] {
        viewModel.events.filter { $0.startDate.startOfMonth == date }
    }

    func remindersFor(_ date: Date) -> [CalendarReminder] {
        viewModel.reminders.filter { $0.startDate.startOfMonth == date }
    }
}

class MonthCellModel: ObservableObject, Identifiable {
    let id: Int

    @Published var events: [CalendarEvent] = []

    init(id: Int) {
        self.id = id
    }
}
