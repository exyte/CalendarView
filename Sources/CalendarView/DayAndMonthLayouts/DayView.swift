//
//  DayView.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 14.04.2025.
//

import SwiftUI

public struct DayView<Content: View>: View {
    @Binding var selectedDate: Date
    var daysCount: Int
    var events: [CalendarEvent]
    var updateID: UUID
    var customizationParams: CalendarViewCustomizationParams
    @ViewBuilder var dayEventBuilder: (CalendarEvent)->Content

    init(selectedDate: Binding<Date>, daysCount: Int, events: [CalendarEvent], updateID: UUID, customizationParams: CalendarViewCustomizationParams, dayEventBuilder: @escaping (CalendarEvent) -> Content) {
        self._selectedDate = selectedDate
        self.daysCount = daysCount
        self.events = events
        self.updateID = updateID
        self.customizationParams = customizationParams
        self.dayEventBuilder = dayEventBuilder

        let isAllDayGrouped = Dictionary(grouping: events, by: \.isAllDay)
        self.allDayEvents = isAllDayGrouped[true] ?? []
        let nonAllDayEvents = isAllDayGrouped[false] ?? []
        self.eventsByDay = daysCount == 1 ? [selectedDate.wrappedValue: nonAllDayEvents] : nonAllDayEvents.groupedByDay()
    }

    var firstOccupiedHour: Int {
        events.map { $0.startDate.getHour() } .min { $0 < $1 } ?? 0
    }

    var allDayEvents: [CalendarEvent]
    var eventsByDay: [Date: [CalendarEvent]] = [:]

    public var body: some View {
        VStack {
            // all day events
            if !allDayEvents.isEmpty {
                HStack {
                    Text("all-day")
                    ForEach(allDayEvents) { event in
                        dayEventBuilder(event)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
            }

            // events by hour
            GeometryReader { global in
                ScrollViewReader { proxy in
                    ScrollView {
                        HStack {
                            VStack(alignment: .trailing) {
                                ForEach(0..<25, id: \.self) { i in
                                    Text("\(i):00")
                                        .frame(height: global.size.height / CGFloat(customizationParams.hoursToFit), alignment: .top)
                                        .id(i)
                                        .padding(.leading, 9)
                                }
                            }

                            ForEach(0..<daysCount, id: \.self) { i in
                                Color("appLightGrey", bundle: .module).frame(width: 1)
                                GeometryReader { g in
                                    let date = selectedDate.adding(.day, value: i)
                                    DayEventsLayout(events: eventsByDay[date] ?? [], size: g.size, horSpacing: customizationParams.horSpacing, verSpacing: customizationParams.verSpacing, dayEventBuilder: dayEventBuilder)
                                }
                                .padding(.trailing, 9)
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
}

extension Sequence where Element == CalendarEvent {
    func groupedByDay() -> [Date: [CalendarEvent]] {
        Dictionary(grouping: self) {
            $0.startDate.startOfDay
        }
    }
}
