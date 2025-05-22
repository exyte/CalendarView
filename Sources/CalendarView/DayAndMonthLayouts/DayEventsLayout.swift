//
//  DayEventsLayout.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 14.04.2025.
//

import SwiftUI

struct DayEventsLayout<Content: View>: View {
    var events: [CalendarEvent] = []
    var size: CGSize
    var horSpacing: CGFloat
    var verSpacing: CGFloat
    @ViewBuilder var dayEventBuilder: (CalendarEvent)->Content

    var frames: [CGRect] = []

    init(events: [CalendarEvent], size: CGSize, horSpacing: CGFloat, verSpacing: CGFloat, dayEventBuilder: @escaping (CalendarEvent) -> Content) {
        self.events = events.sorted(by: \.duration)
        self.size = size
        self.horSpacing = horSpacing
        self.verSpacing = verSpacing
        self.dayEventBuilder = dayEventBuilder

        self.frames = recalculateFrames()
    }

    public func recalculateFrames() -> [CGRect] {
        var frames = [CGRect]()
        var columns = [Int]()

        var space = PartiallyOccupiedSpace()
        for event in events {
            let column = space.occupyFirstFreeSpace(with: event)
            columns.append(column)
        }

        let columnsCount = CGFloat(space.occupiedColumns.count)
        let columnWidth = (size.width - horSpacing * (columnsCount - 1)) / columnsCount
        let rowHeight = (size.height - verSpacing * 24) / 25
        let deltaX = columnWidth + horSpacing
        let deltaY = rowHeight + verSpacing

        for i in 0..<events.count {
            let event = events[i]
            //print(event.title, deltaY, deltaY * event.startCoeff, deltaY * event.durationCoeff - verSpacing)
            let column = CGFloat(columns[i])
            frames.append(CGRect(x: deltaX * column, y: deltaY * startCoeff(event), width: columnWidth, height: deltaY * durationCoeff(event) - verSpacing))
        }
        return frames
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(frames.indices, id: \.self) { i in
                let event = events[i]
                let frame = frames[i]
                dayEventBuilder(event)
                    .position(x: frame.midX, y: frame.midY)
                    .frame(width: frame.width, height: frame.height)
            }
        }
    }

    func durationCoeff(_ event: CalendarEvent) -> CGFloat {
        event.duration / CGFloat(60 * 60)
    }

    func startCoeff(_ event: CalendarEvent) -> CGFloat {
        CGFloat((event.startDate.getHour() * 60 + event.startDate.getMinute())) / CGFloat(60)
    }
}

fileprivate struct PartiallyOccupiedSpace {
    var occupiedColumns: [PartiallyOccupiedColumn] = []

    mutating func occupyFirstFreeSpace(with event: CalendarEvent) -> Int {
        for index in occupiedColumns.indices {
            if occupiedColumns[index].occupyFirstFreeSpace(with: event) {
                return index
            }
        }

        let newColumn = PartiallyOccupiedColumn(occupiedRanges: [NSRange(event)])
        occupiedColumns.append(newColumn)
        return occupiedColumns.count - 1
    }
}

fileprivate struct PartiallyOccupiedColumn {
    var occupiedRanges: [NSRange]

    mutating func occupyFirstFreeSpace(with event: CalendarEvent) -> Bool {
        let eventRange = NSRange(event)
        for occupied in occupiedRanges {
            if occupied.intersects(eventRange) {
                return false
            }
        }
        occupiedRanges.append(eventRange)
        return true
    }
}

extension NSRange {
    init(_ event: CalendarEvent) {
        self.init(event.startDate, event.endDate)
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
