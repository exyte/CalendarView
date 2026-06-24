//
//  DayEventsLayout.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 14.04.2025.
//

import SwiftUI

struct DayEventsLayout<Content: View>: View {
    @Environment(\.showEventDetailsClosure) var showEventDetailsClosure

    var events: [CalendarEvent]
    var reminders: [CalendarReminder]
    var oneHourHeight: CGFloat
    var horSpacing: CGFloat
    var verSpacing: CGFloat
    var trailingPadding: CGFloat
    @ViewBuilder var dayEventBuilder: (any CalendarEntity) -> Content

    private var sortedEvents: [CalendarEvent] {
        events.sorted(by: [
            ArrayUtils.cmp(\.startDate),
            ArrayUtils.cmp(\.duration, ascending: false),
            ArrayUtils.cmp(\.id),
        ])
    }

    var body: some View {
        let sorted = sortedEvents
        EventsPlacement(
            events: sorted,
            reminders: reminders,
            oneHourHeight: oneHourHeight,
            horSpacing: horSpacing,
            verSpacing: verSpacing,
            trailingPadding: trailingPadding
        ) {
            ForEach(sorted, id: \.id) { event in
                dayEventBuilder(event)
                    .onTapGesture {
                        showEventDetailsClosure(event)
                    }
            }
            ForEach(reminders, id: \.id) { reminder in
                dayEventBuilder(reminder)
                    .onTapGesture {
                        showEventDetailsClosure(reminder)
                    }
            }
        }
        .transaction { $0.disablesAnimations = true }
    }
}

// MARK: - Layout

fileprivate struct EventsPlacement: Layout {
    var events: [CalendarEvent]
    var reminders: [CalendarReminder]
    var oneHourHeight: CGFloat
    var horSpacing: CGFloat
    var verSpacing: CGFloat
    var trailingPadding: CGFloat

    struct Cache {
        var width: CGFloat = -1
        var frames: [CGRect] = []
    }

    private struct Pending {
        var type: EntityType
        var originalIndex: Int
        var range: NSRange
    }

    func makeCache(subviews: Subviews) -> Cache { Cache() }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
        let width = proposal.replacingUnspecifiedDimensions().width
        return CGSize(width: max(0, width), height: oneHourHeight * 25)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
        if cache.width != bounds.width || cache.frames.count != events.count + reminders.count {
            cache.frames = computeFrames(width: bounds.width)
            cache.width = bounds.width
        }
        for (i, subview) in subviews.enumerated() {
            guard i < cache.frames.count else { continue }
            let f = cache.frames[i]
            subview.place(
                at: CGPoint(x: bounds.minX + f.minX, y: bounds.minY + f.minY),
                anchor: .topLeading,
                proposal: ProposedViewSize(width: f.width, height: f.height)
            )
        }
    }

    private func computeFrames(width: CGFloat) -> [CGRect] {
        let usableWidth = max(0, width - trailingPadding)

        var pending: [Pending] = []
        pending.reserveCapacity(events.count + reminders.count)
        for (i, e) in events.enumerated() {
            pending.append(Pending(type: .event, originalIndex: i, range: NSRange(e)))
        }
        for (i, r) in reminders.enumerated() {
            pending.append(Pending(type: .reminder, originalIndex: i, range: NSRange(r)))
        }
        pending.sort {
            if $0.range.location != $1.range.location {
                return $0.range.location < $1.range.location
            }
            return $0.range.length > $1.range.length
        }

        var eventFrames = Array(repeating: CGRect.zero, count: events.count)
        var reminderFrames = Array(repeating: CGRect.zero, count: reminders.count)

        var i = 0
        while i < pending.count {
            var columnEndTime: [Int] = []
            var assignedColumns: [Int] = []
            var groupEnd = pending[i].range.end

            var j = i
            while j < pending.count && (j == i || pending[j].range.location < groupEnd) {
                let p = pending[j]
                var col = -1
                for c in 0..<columnEndTime.count where columnEndTime[c] <= p.range.location {
                    col = c
                    columnEndTime[c] = p.range.end
                    break
                }
                if col == -1 {
                    col = columnEndTime.count
                    columnEndTime.append(p.range.end)
                }
                assignedColumns.append(col)
                groupEnd = max(groupEnd, p.range.end)
                j += 1
            }

            let columnCount = max(1, columnEndTime.count)
            let columnWidth = max(0, (usableWidth - horSpacing * CGFloat(columnCount - 1)) / CGFloat(columnCount))
            let dx = columnWidth + horSpacing

            for k in i..<j {
                let p = pending[k]
                let col = assignedColumns[k - i]
                let startCoeff = CGFloat(p.range.location) / 60.0
                let y = oneHourHeight * startCoeff
                let x = dx * CGFloat(col)
                let height: CGFloat
                switch p.type {
                case .event:
                    let durationCoeff = CGFloat(p.range.length) / 60.0
                    height = max(0, oneHourHeight * durationCoeff - verSpacing)
                case .reminder:
                    height = max(0, oneHourHeight - verSpacing)
                }
                let rect = CGRect(x: x, y: y, width: columnWidth, height: height)
                switch p.type {
                case .event: eventFrames[p.originalIndex] = rect
                case .reminder: reminderFrames[p.originalIndex] = rect
                }
            }

            i = j
        }

        return eventFrames + reminderFrames
    }
}

// MARK: - Range helpers

extension NSRange {
    init(_ event: CalendarEvent) {
        self.init(event.startDate, event.endDate)
    }

    init(_ reminder: CalendarReminder) {
        self.init(reminder.startDate, reminder.startDate.adding(.hour, value: 1))
    }

    init(_ startDate: Date, _ endDate: Date) {
        let calendar = Calendar.current
        let baseDay = calendar.startOfDay(for: startDate)
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
