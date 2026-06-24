//
//  DayEventsLayout.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 14.04.2025.
//

import SwiftUI

struct DayEventsLayout<Content: View>: View {
    @Environment(\.showEventDetailsClosure) var showEventDetailsClosure

    var events: [CalendarEvent] = []
    var reminders: [CalendarReminder] = []
    var size: CGSize
    var horSpacing: CGFloat
    var verSpacing: CGFloat
    @ViewBuilder var dayEventBuilder: (any CalendarEntity)->Content

    private var eventFrames: [CGRect] = []
    private var reminderFrames: [CGRect] = []

    init(events: [CalendarEvent], reminders: [CalendarReminder], size: CGSize, horSpacing: CGFloat, verSpacing: CGFloat, dayEventBuilder: @escaping (any CalendarEntity) -> Content) {
        self.events = events.sorted(by: [
            ArrayUtils.cmp(\.duration),
            ArrayUtils.cmp(\.title),
            ArrayUtils.cmp(\.id)
        ])
        self.reminders = reminders
        self.size = size
        self.horSpacing = horSpacing
        self.verSpacing = verSpacing
        self.dayEventBuilder = dayEventBuilder

        (self.eventFrames, self.reminderFrames) = recalculateFrames()
    }

    public func recalculateFrames() -> ([CGRect], [CGRect]) {
        var eventFrames = [CGRect]()
        var reminderFrames = [CGRect]()
        var eventColumns = [Int]()
        var eventCountInRow = [Int]()
        var reminderColumns = [Int]()
        var reminderCountInRow = [Int]()

        var space = PartiallyOccupiedSpace()

        for event in events {
            let column = space.occupyFirstFreeSpace(with: NSRange(event))
            eventColumns.append(column)
        }

        for reminder in reminders {
            let column = space.occupyFirstFreeSpace(with: NSRange(reminder))
            reminderColumns.append(column)
        }
        
        for event in events {
            let count = space.countEventsInRow(with: NSRange(event))
            eventCountInRow.append(count)
        }
        
        for reminder in reminders {
            let count = space.countEventsInRow(with: NSRange(reminder))
            reminderCountInRow.append(count)
        }

        for i in 0..<events.count {
            let columnsCount = CGFloat(eventCountInRow[i])
            let columnWidth = (size.width - horSpacing * (columnsCount - 1)) / columnsCount
            let rowHeight = (size.height - verSpacing * 24) / 25
            let deltaX = columnWidth + horSpacing
            let deltaY = rowHeight + verSpacing
            
            let event = events[i]
            let column = CGFloat(eventColumns[i])
            eventFrames.append(CGRect(x: deltaX * column, y: deltaY * startCoeff(event), width: columnWidth, height: deltaY * durationCoeff(event) - verSpacing))
        }

        for i in 0..<reminders.count {
            let columnsCount = CGFloat(reminderCountInRow[i])
            let columnWidth = (size.width - horSpacing * (columnsCount - 1)) / columnsCount
            let rowHeight = (size.height - verSpacing * 24) / 25
            let deltaX = columnWidth + horSpacing
            let deltaY = rowHeight + verSpacing
            
            let reminder = reminders[i]
            let column = CGFloat(reminderColumns[i])
            reminderFrames.append(CGRect(x: deltaX * column, y: deltaY * startCoeff(reminder), width: columnWidth, height: deltaY - verSpacing))
        }
        return (eventFrames, reminderFrames)
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(eventFrames.indices, id: \.self) { i in
                let event = events[i]
                let frame = eventFrames[i]
                dayEventBuilder(event)
                    .position(x: frame.midX, y: frame.midY)
                    .frame(width: frame.width, height: frame.height)
                    .onTapGesture {
                        showEventDetailsClosure(event)
                    }
            }

            ForEach(reminderFrames.indices, id: \.self) { i in
                let reminder = reminders[i]
                let frame = reminderFrames[i]
                dayEventBuilder(reminder)
                    .position(x: frame.midX, y: frame.midY)
                    .frame(width: frame.width, height: frame.height)
                    .onTapGesture {
                        showEventDetailsClosure(reminder)
                    }
            }
        }
        .transaction { $0.disablesAnimations = true }
        .animation(nil)
    }

    func durationCoeff(_ event: CalendarEvent) -> CGFloat {
        event.duration / CGFloat(60 * 60)
    }

    func startCoeff(_ event: CalendarEvent) -> CGFloat {
        CGFloat((event.startDate.getHour() * 60 + event.startDate.getMinute())) / CGFloat(60)
    }

    func startCoeff(_ reminder: CalendarReminder) -> CGFloat {
        CGFloat((reminder.startDate.getHour() * 60 + reminder.startDate.getMinute())) / CGFloat(60)
    }
}

fileprivate struct PartiallyOccupiedSpace {
    var occupiedColumns: [PartiallyOccupiedColumn] = []

    mutating func occupyFirstFreeSpace(with range: NSRange) -> Int {
        for index in occupiedColumns.indices {
            if occupiedColumns[index].occupyFirstFreeSpace(with: range) {
                return index
            }
        }

        let newColumn = PartiallyOccupiedColumn(occupiedRanges: [range])
        occupiedColumns.append(newColumn)
        return occupiedColumns.count - 1
    }
    
    func countEventsInRow(with range: NSRange) -> Int {
        occupiedColumns.filter { $0.isRangeInThisColumn(with: range) }.count
    }
}

fileprivate struct PartiallyOccupiedColumn {
    var occupiedRanges: [NSRange]

    mutating func occupyFirstFreeSpace(with range: NSRange) -> Bool {
        for occupied in occupiedRanges {
            if occupied.intersects(range) {
                return false
            }
        }
        occupiedRanges.append(range)
        return true
    }
    
    func isRangeInThisColumn(with range: NSRange) -> Bool {
        occupiedRanges.contains { $0.intersects(range) }
    }
}

extension NSRange {
    init(_ event: CalendarEvent) {
        self.init(event.startDate, event.endDate)
    }

    init(_ reminder: CalendarReminder) {
        self.init(reminder.startDate, reminder.startDate.adding(.hour, value: 1))
    }

    init(_ startDate: Date, _ endDate: Date) {
        let calendar = Calendar.current

        // Start of the day for the event
        let baseDay = calendar.startOfDay(for: startDate)

        // Minutes since the start of that base day
        let startMinutes = calendar.dateComponents([.minute], from: baseDay, to: startDate).minute!
        let endMinutes = calendar.dateComponents([.minute], from: baseDay, to: endDate).minute!

        self = NSRange(location: startMinutes, length: endMinutes - startMinutes)
    }

    var end: Int {
        location + length
    }

    func intersects(_ other: NSRange) -> Bool {
        self.location < other.end && other.location < self.end
    }
}
