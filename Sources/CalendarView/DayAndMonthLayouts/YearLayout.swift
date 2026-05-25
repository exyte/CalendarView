//
//  YearLayout.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 14.05.2025.
//

import SwiftUI

struct YearLayout: View {
    @Environment(\.calendarTheme) private var theme

    var date: Date // Jan 1st of some year
    var didSelectMonth: (Int)->()

    let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
    let today = Date()

    var body: some View {
        VStack(alignment: .leading) {
            let isCurrentYear = date.getYear() == today.getYear()
            Text(date.formatted("y")).systemFont(32, .semibold, isCurrentYear ? theme.year.todayText : theme.year.monthText)

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(0..<12) { i in
                    Button {
                        didSelectMonth(i+1)
                    } label: {
                        if isCurrentYear, i+1 == today.getMonth() {
                            YearCurrentMonthLayout(date: date.adding(.month, value: i))
                                .frame(maxHeight: .infinity, alignment: .top)
                        } else {
                            YearMonthLayout(date: date.adding(.month, value: i))
                                .frame(maxHeight: .infinity, alignment: .top)
                        }
                    }
                }
            }
        }
    }
}

struct YearMonthLayout: View, Identifiable {
    @Environment(\.calendarTheme) private var theme
    @Environment(\.calendarCustomizationParams) var customizationParams

    let id = UUID()
    var date: Date // 1st of some month

    let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    // count of empty spaces for days of week before 1st of the month
    var inset: Int {
        let startOfWeek = date.startOfWeek(customizationParams.firstDayOfWeek)
        var count = date.getWeekday() - startOfWeek.getWeekday()
        if count < 0 {
            count += 7
        }
        return count
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(date.formatted("MMM")).systemFont(20, .semibold, theme.year.monthText)

            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(0..<inset, id: \.self) { _ in
                    Color.clear
                }

                let maxMonthDay = date.maxMonthDay
                ForEach(1...maxMonthDay, id: \.self) { day in
                    Text("\(day)").systemFont(8, theme.year.dateText)
                        .id(UUID())
                }
            }
        }
    }
}

struct YearCurrentMonthLayout: View, Identifiable {
    @Environment(\.calendarTheme) private var theme
    @Environment(\.calendarCustomizationParams) var customizationParams

    let id = UUID()
    var date: Date // 1st of some month

    let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    let today = Date()

    // count of empty spaces for days of week before 1st of the month
    var inset: Int {
        let startOfWeek = date.startOfWeek(customizationParams.firstDayOfWeek)
        var count = date.getWeekday() - startOfWeek.getWeekday()
        if count < 0 {
            count += 7
        }
        return count
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(date.formatted("MMM")).systemFont(20, .semibold, theme.year.todayText)

            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(0..<inset, id: \.self) { _ in
                    Color.clear
                }

                let maxMonthDay = date.maxMonthDay
                ForEach(1...maxMonthDay, id: \.self) { day in
                    let isToday = day == today.getDay()
                    Text("\(day)").systemFont(8, isToday ? .white : theme.year.dateText)
                        .id(UUID())
                        .applyIf(isToday) {
                            $0
                                .frame(width: 14, height: 14)
                                .background(Circle().styled(theme.year.todayText))
                        }
                }
            }
        }
    }
}
