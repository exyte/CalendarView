//
//  CreateEventView.swift
//  Jaye
//
//  Created by Exyte on 01.04.2025.
//

import SwiftUI

struct CreateEventView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: CalendarViewModel

    @State private var isEvent: Bool = true
    @State private var event: CalendarEvent = CalendarEvent()
    @State private var reminder: CalendarReminder = CalendarReminder()

    @State var saveEnabled: Bool = false

    var body: some View {
        VStack {
            CreateOrEditEventHeaderView(rightButtonEnabled: $saveEnabled, title: "New") {
                Task {
                    isEvent ? await viewModel.addEvent(event) : await viewModel.addReminder(reminder)
                }
            }

            eventTypeSwitcher

            if isEvent {
                EditCalendarEntityView(entity: $event)
            } else {
                EditCalendarEntityView(entity: $reminder)
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
                    .systemFont(15, .semibold)
                    .frame(height: 32)
                    .greedyWidth()
                    .background(isEvent ? Color.white : Color.clear)
                    .cornerRadius(16)
                    .padding(3)
            }

            Button {
                self.isEvent = false
            } label: {
                Text("Reminder")
                    .systemFont(15, .semibold)
                    .frame(height: 32)
                    .greedyWidth()
                    .background(!isEvent ? Color.white : Color.clear)
                    .cornerRadius(16)
                    .padding(3)
            }
        }
        .greedyWidth()
        .background(Color.named("appLightGrey"))
        .frame(height: 36)
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
