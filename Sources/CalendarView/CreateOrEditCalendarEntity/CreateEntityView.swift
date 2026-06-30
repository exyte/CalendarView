//
//  CreateEntityView.swift
//  Jaye
//
//  Created by Exyte on 01.04.2025.
//

import SwiftUI

struct CreateEntityView: View {
    @Environment(\.calendarTheme) var theme
    @Environment(\.dismiss) private var dismiss

    var shouldSave: (any CalendarEntity) async -> ()

    @State private var eventType: EntityType = .event
    @State private var event: CalendarEvent
    @State private var reminder: CalendarReminder

    init(fullscreenDate: Date, shouldSave: @escaping (any CalendarEntity) async -> ()) {
        self.shouldSave = shouldSave
        let now = Date()
        let startDate = fullscreenDate.startOfDay.setHour(to: now.getHour()).setMinute(to: now.getMinute())
        self._event = State(wrappedValue: CalendarEvent(startDate: startDate))
        self._reminder = State(wrappedValue: CalendarReminder(startDate: startDate))
    }

    var saveEnabled: Bool {
        !event.title.isEmpty && !event.calendarID.isEmpty
    }

    var body: some View {
        VStack {
            CloseSaveHeaderView(title: "New", saveButtonEnabled: saveEnabled) {
                if event.isAllDay {
                    event.stripTime()
                }
                await shouldSave(eventType == .event ? event : reminder)
            }

            ButtonsSwitcher(selection: $eventType)
                .padding(.horizontal, 16)

            if eventType == .event {
                EditEntityFieldsView(entity: $event)
            } else {
                EditEntityFieldsView(entity: $reminder)
            }
        }
        .background(theme.main.background)
    }
}

struct ButtonsSwitcher<Enum: Hashable & CaseIterable>: View {
    @Environment(\.calendarTheme) var theme

    @Binding var selection: Enum
    var additionalActionClosure: () -> () = {}

    var body: some View {
        HStack(spacing: 8) {
            ForEach(Array(Enum.allCases), id: \.self) { tab in
                Button {
                    additionalActionClosure()
                    withAnimation {
                        selection = tab
                    }
                } label: {
                    Text("\(tab)".capitalized)
                        .padding(10, 8)
                        .greedyWidth()
                        .background {
                            Capsule().foregroundStyle(selection == tab ? theme.main.switcherSelectedBackground : .clear)
                        }
                }
            }
        }
        .libraryFont(14, .semibold)
        .greedyWidth()
        .padding(2)
        .background {
            Capsule().foregroundStyle(theme.main.fieldBackground)
        }
    }
}

fileprivate extension CalendarEntity {
    mutating func syncFields<T: CalendarEntity>(from other: T) {
        self.calendarID = other.calendarID
        self.title = other.title
        self.notes = other.notes
        self.calendarColor = other.calendarColor
        self.calendarName = other.calendarName
        self.startDate = other.startDate
        self.repeatType = other.repeatType
        self.alertType = other.alertType
        self.priorityType = other.priorityType
        self.vibrationType = other.vibrationType
    }
}
