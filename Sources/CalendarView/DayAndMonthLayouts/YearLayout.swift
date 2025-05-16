//
//  YearLayout.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 14.05.2025.
//

import SwiftUI

struct YearLayout: View {
    var date: Date // Jan 1st of some year
    var didSelectMonth: (Int)->()

    let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
    let today = Date()

    var body: some View {
        VStack(alignment: .leading) {
            let isCurrentYear = date.getYear() == today.getYear()
            Text(date.formatted("yyyy")).systemFont(32, .semibold, isCurrentYear ? .accentColor : .black)

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(0..<12) { i in
                    Button {
                        didSelectMonth(i+1)
                    } label: {
                        if isCurrentYear, i == today.getMonth() {
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

struct YearMonthLayout: View {
    var date: Date // 1st of some month

    let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    // count of empty spaces for days of week before 1st of the month
    var inset: Int {
        let startOfWeek = date.startOfWeek
        var count = date.getWeekday() - startOfWeek.getWeekday()
        if count < 0 {
            count += 7
        }
        return count
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(date.formatted("MMM")).systemFont(20, .semibold)

            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(0..<inset, id: \.self) { _ in
                    Color.clear
                }

                let maxMonthDay = date.maxMonthDay
                ForEach(1...maxMonthDay, id: \.self) { day in
                    Text("\(day)").systemFont(8)
                }
            }
        }
    }
}

struct YearCurrentMonthLayout: View {
    var date: Date // 1st of some month

    let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    let today = Date()

    // count of empty spaces for days of week before 1st of the month
    var inset: Int {
        let startOfWeek = date.startOfWeek
        var count = date.getWeekday() - startOfWeek.getWeekday()
        if count < 0 {
            count += 7
        }
        return count
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(date.formatted("MMM")).systemFont(20, .semibold, .accentColor)

            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(0..<inset, id: \.self) { _ in
                    Color.clear
                }

                let maxMonthDay = date.maxMonthDay
                ForEach(1...maxMonthDay, id: \.self) { day in
                    Text("\(day)").systemFont(8)
                        .applyIf(day == today.getDay()) {
                            $0.padding(2)
                                .background(Circle().colored(.accentColor))
                        }
                }
            }
        }
    }
}
