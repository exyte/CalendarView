//
//  ContentView.swift
//  CalendarViewExample
//
//  Created by Alisa Mylnikova on 14.04.2025.
//

import SwiftUI
import CalendarView

struct ContentView: View {

    @State var date = Date().startOfDay
    @State var mode = CalendarDisplayMode.day

    var body: some View {
        CalendarView(providers: CalendarDefaults.defaultProviders)
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

        .fullscreenDate($date)
        .firstDayOfWeek(2)
        .hoursToFit(6)
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
        .ignoresSafeArea(edges: .bottom)
    }
}
