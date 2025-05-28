//
//  ContentView.swift
//  CalendarViewExample
//
//  Created by Alisa Mylnikova on 14.04.2025.
//

import SwiftUI
import CalendarView

struct ContentView: View {

    @State var a = Date().setMonth(to: 6).setDayOfMonth(to: 18)
    @State var mode = CalendarDisplayMode.day

    @State var b = false

    var body: some View {
        CalendarView()
//        { calendarEvent in
//            ZStack {
//                Rectangle().foregroundStyle(.red.opacity(0.1))
//                Text(calendarEvent.title)
//            }
//        } monthDayBuilder: { params in
//            Text(params.date.formatted(date: .abbreviated, time: .omitted))
//        } weekSwitcherDayBuilder: { params in
//            Text(params.day.formatted("d.MM"))
//                .foregroundStyle(params.isToday ? .blue : .black)
//        } headerBuilder: { params in
//            HStack {
//                Button("Show calendars") {
//                    params.tapFilterCalendarsClosure()
//                }
//                Button("Toggle mode") {
//                    params.displayMode.wrappedValue = params.displayMode.wrappedValue == .month ? .day : .month
//                }
//            }
//        }

        //.selectedDate($a)
        .firstDayOfWeek(2)
        .hourLabelFormat("HH:mm")
        .headerBackground {
            GeometryReader { geo in
                ZStack(alignment: .top) {
                    Image(.headerBG)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipShape(
                            RoundedCorner(radius: 24, corners: [.bottomLeft, .bottomRight])
                        )
                }
            }
        }
    }
}
