//
//  CreateEntityView.swift
//  Jaye
//
//  Created by Exyte on 01.04.2025.
//

import SwiftUI

struct CreateEntityView: View {
    @Environment(\.dismiss) private var dismiss

    var shouldSave: (any CalendarEntity) async -> ()

    @State private var eventType: EntityType = .event
    @State private var event = CalendarEvent()
    @State private var reminder = CalendarReminder()

    var saveEnabled: Bool {
        !event.title.isEmpty && !event.calendarID.isEmpty
    }

    var body: some View {
        VStack {
            CloseSaveHeaderView(title: "New", saveButtonEnabled: saveEnabled) {
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
    }
}

struct ButtonsSwitcher<Enum: Hashable & CaseIterable>: View {
    @Binding var selection: Enum
    var additionalActionClosure: () -> () = {}

    var body: some View {
        HStack(spacing: 8) {
            ForEach(Array(Enum.allCases), id: \.self) { tab in
                Button("\(tab)".capitalized) {
                    additionalActionClosure()
                    withAnimation {
                        selection = tab
                    }
                }
                .greedyWidth()
                .padding(10, 8)
                .background {
                    Capsule().foregroundStyle(selection == tab ? Color.white : Color.clear)
                }
            }
        }
        .systemFont(14, .semibold)
        .greedyWidth()
        .padding(2)
        .background {
            Capsule().foregroundStyle(Color(.appGrey5))
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
