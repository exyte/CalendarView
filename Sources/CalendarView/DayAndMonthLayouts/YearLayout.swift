//
//  YearLayout.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 14.05.2025.
//

import SwiftUI

struct YearLayout: View {
    @Environment(\.calendarTheme) var theme

    var date: Date // Jan 1st of some year
    var didSelectMonth: (Int)->()

    let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
    let today = Date()

    var body: some View {
        VStack(alignment: .leading) {
            let isCurrentYear = date.getYear() == today.getYear()
            Text(date.formatted("y")).libraryFont(32, .semibold, isCurrentYear ? theme.year.todayText : theme.year.monthText)

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(0..<12) { i in
                    Button {
                        didSelectMonth(i+1)
                    } label: {
                        YearMonthLayout(
                            date: date.adding(.month, value: i),
                            isCurrentMonth: isCurrentYear && (i+1 == today.getMonth())
                        )
                        .frame(maxHeight: .infinity, alignment: .top)
                    }
                }
            }
        }
    }
}

struct YearMonthLayout: View, Identifiable {
    @Environment(\.calendarTheme) var theme
    @Environment(\.calendarCustomizationParams) var customizationParams

    let id = UUID()
    var date: Date // 1st of some month
    var isCurrentMonth: Bool = false

    private let today = Date()
    let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    // number of empty spaces for days of week before 1st of the month
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
            Text(date.formatted("MMM"))
                .libraryFont(20, .semibold, isCurrentMonth ? theme.year.todayText : theme.year.monthText)

            LazyVGrid(columns: columns, spacing: 4) {
                let maxMonthDay = date.maxMonthDay
                let totalCount = inset + maxMonthDay

                ForEach(0..<totalCount, id: \.self) { index in
                    if index < inset {
                        Color.clear
                    } else {
                        let day = index - inset + 1
                        let isToday = isCurrentMonth && day == today.getDay()

                        Text("\(day)")
                            .libraryFont(8, isToday ? .white : theme.year.dateText)
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
}
