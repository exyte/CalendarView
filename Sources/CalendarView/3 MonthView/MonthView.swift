//
//  MonthView.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 24.04.2025.
//

import SwiftUI

public struct MonthView<MonthDay: View>: View {
    var events: [CalendarEvent]
    @Binding var selectedDate: Date
    @Binding var calendarDisplayMode: CalendarDisplayMode
    var updateID: UUID
    @ViewBuilder var monthDayBuilder: (Date, [CalendarEvent]) -> MonthDay

    let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    var startOfMonth: Date {
        selectedDate.startOfMonth
    }

    // count of empty spaces for days of week before 1st of the month
    var inset: Int {
        let startOfWeek = startOfMonth.startOfWeek
        var count = startOfMonth.getWeekday() - startOfWeek.getWeekday()
        if count < 0 {
            count += 7
        }
        return count
    }

    public var body: some View {
        GeometryReader { g in
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(0..<inset, id: \.self) { _ in
                    Color.clear
                }

                ForEach(0..<startOfMonth.daysInMonth, id: \.self) { index in
                    let date = startOfMonth.adding(.day, value: index)
                    Button {
                        selectedDate = date
                        calendarDisplayMode = .day
                    } label: {
                        monthDayBuilder(date, eventsFor(date))
                            .frame(height: g.size.height/6)
                    }
                }
            }
            .frame(height: g.size.height)
        }
    }

    func eventsFor(_ date: Date) -> [CalendarEvent] {
        events.filter { $0.startDate.startOfDay == date }
    }
}
