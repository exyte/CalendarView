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

    @Binding var selectedDate: Date
    @Binding var calendarDisplayMode: CalendarDisplayMode
    var events: [CalendarEvent]
    var reminders: [CalendarReminder]
    @ViewBuilder var monthDayBuilder: (MonthDayBuilderParams) -> MonthDay

    @State private var items: [Int] = Array(-3...3)

    let today = Date()

    var body: some View {
        GeometryReader { g in
            createSimpleInfiniteTableView(items: $items) { item in
                VStack(alignment: .leading, spacing: 0) {
                    let monthDate = selectedDate.startOfMonth.adding(.month, value: item)
                    let isCurrentMonth = monthDate.startOfMonth == today.startOfMonth
                    Text(monthDate.formatted("MMMM, y")).systemFont(32, .semibold, isCurrentMonth ? theme.year.todayText : theme.year.monthText)

                    MonthLayout(date: monthDate, events: events, reminders: reminders, monthDayBuilder: monthDayBuilder) { day in
                        selectedDate = day
                        calendarDisplayMode = .day
                    }
                }
                .frame(height: g.size.height)
                .padding(.horizontal, 16)
                .background(theme.month.background)
            }
        }
    }
}
