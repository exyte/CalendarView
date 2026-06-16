//
//  MonthLayout.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 24.04.2025.
//

import SwiftUI

public struct MonthLayout<MonthDay: View>: View {
    @Environment(\.calendarTheme) private var theme
    @Environment(\.calendarCustomizationParams) var customizationParams

    var date: Date
    @ObservedObject var viewModel: MonthCellModel /// use @ObservedObject to force swiftUI update flow on UIKit components
    @ViewBuilder var monthDayBuilder: (MonthDayBuilderParams) -> MonthDay
    var didSelectDay: (Date)->()

    let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    let today = Date()

    var startOfMonth: Date {
        date.startOfMonth
    }

    // count of empty spaces for days of week before 1st of the month
    var inset: Int {
        let startOfWeek = startOfMonth.startOfWeek(customizationParams.firstDayOfWeek)
        var count = startOfMonth.getWeekday() - startOfWeek.getWeekday()
        if count < 0 {
            count += 7
        }
        return count
    }

    public var body: some View {
        GeometryReader { g in
            let numberOfRows = numberOfCalendarRows()
            let rowHeight = g.size.height/CGFloat(numberOfRows)

            LazyVGrid(columns: columns, spacing: 0) {
                let maxMonthDay = startOfMonth.daysInMonth
                let allCells: [AnyView] = (0..<inset + maxMonthDay).map { index in
                    if index < inset {
                        return AnyView(Color.clear)
                    } else {
                        let date = startOfMonth.adding(.day, value: index - inset)
                        return AnyView(
                            Button {
                                didSelectDay(date)
                            } label: {
                                monthDayBuilder(MonthDayBuilderParams(date: date, events: eventsFor(date), viewHeight: rowHeight))
                                    .frame(height: rowHeight)
                            }
                        )
                    }
                }

                ForEach(allCells.indices, id: \.self) { i in
                    allCells[i]
                }
            }
            .frame(height: g.size.height)
        }
    }

    func eventsFor(_ date: Date) -> [any CalendarEntity] {
        var allDayEvents = viewModel.events
            .filter { $0.isAllDay }
            .filter{ $0.startDate.startOfDay <= date && $0.endDate >= date }
        let events = viewModel.events
            .filter { !$0.isAllDay && $0.startDate.startOfDay == date }
        allDayEvents.append(contentsOf: events)
        return allDayEvents
    }

    func numberOfCalendarRows() -> Int {
        let calendar = Calendar.current
        let firstDayOfWeek = customizationParams.firstDayOfWeek ?? calendar.firstWeekday
        let startOfMonth = date.startOfMonth
        let daysInMonth = startOfMonth.daysInMonth

        // First day of week of this month (e.g. 2 for Monday)
        let weekdayOfFirst = calendar.component(.weekday, from: startOfMonth)

        // Calculate offset based on custom first day of week
        var leadingEmptyDays = weekdayOfFirst - firstDayOfWeek
        if leadingEmptyDays < 0 {
            leadingEmptyDays += 7
        }

        let totalItems = leadingEmptyDays + daysInMonth
        return Int(ceil(Double(totalItems) / 7.0))
    }
}
