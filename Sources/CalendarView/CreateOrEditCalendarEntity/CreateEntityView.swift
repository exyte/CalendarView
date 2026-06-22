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

    @State var saveEnabled = false
    @State var isEvent = true
    @State var event = CalendarEvent()
    @State var reminder = CalendarReminder()

    var body: some View {
        VStack {
            CreateOrEditEntityHeaderView(title: "New", saveButtonEnabled: saveEnabled) {
                await shouldSave(isEvent ? event : reminder)
            }

            eventTypeSwitcher

            if isEvent {
                EditEntityFieldsView(entity: $event)
            } else {
                EditEntityFieldsView(entity: $reminder)
            }
        }
        .onChange(of: event) {
            reminder.syncFields(from: event)
            saveEnabled = !event.title.isEmpty && !event.calendarID.isEmpty
        }
        .onChange(of: reminder) {
            event.syncFields(from: reminder)
            saveEnabled = !event.title.isEmpty && !event.calendarID.isEmpty
        }
        .onAppear {
            saveEnabled = false
        }
    }

    var eventTypeSwitcher: some View {
        HStack {
            Button {
                self.isEvent = true
            } label: {
                Text("Event")
                    .greedyWidth()
                    .background(isEvent ? Color.white : Color.clear)
                    .cornerRadius(16)
                    .padding(3, 10)
            }

            Button {
                self.isEvent = false
            } label: {
                Text("Reminder")
                    .greedyWidth()
                    .background(!isEvent ? Color.white : Color.clear)
                    .cornerRadius(16)
                    .padding(3, 10)
            }
        }
        .systemFont(15, .semibold)
        .greedyWidth()
        .background(Color.named("appLightGrey"))
        .cornerRadius(18)
        .padding(.horizontal, 16)
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
