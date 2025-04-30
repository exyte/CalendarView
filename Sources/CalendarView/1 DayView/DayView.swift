//
//  DayView.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 14.04.2025.
//

import SwiftUI

public struct DayView<Content: View>: View {
    var events: [CalendarEvent]
    @Binding var selectedDate: Date
    var updateID: UUID
    var horSpacing: CGFloat
    var verSpacing: CGFloat
    var hoursToFit: Int
    @ViewBuilder var dayEventBuilder: (CalendarEvent)->Content

    var firstOccupiedHour: Int {
        events.map { $0.startDate.getHour() } .min { $0 < $1 } ?? 0
    }

    public var body: some View {
        GeometryReader { global in
            ScrollViewReader { proxy in
                ScrollView {
                    HStack {
                        VStack {
                            ForEach(0..<25, id: \.self) { i in
                                Text("\(i):00")
                                    .frame(height: global.size.height / CGFloat(hoursToFit), alignment: .top)
                                    .id(i)
                            }
                        }

                        GeometryReader { g in
                            DayEventsLayout(events: events, size: g.size, horSpacing: horSpacing, verSpacing: verSpacing, dayEventBuilder: dayEventBuilder)
                        }
                    }
                }
                .onChange(of: updateID) {
                    proxy.scrollTo(firstOccupiedHour, anchor: .top)
                }
            }
        }
    }
}
