//
//  CreateEventView.swift
//  Jaye
//
//  Created by Exyte on 01.04.2025.
//

import SwiftUI

struct CreateOrEditEventView<Entity: CalendarEntity>: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: CalendarViewModel

    var entity: Binding<Entity>?
    var didEditEntity: (()->())?

    var isEdit: Bool {
        entity != nil
    }

    var body: some View {
        NavigationStack {
            Group {
                if let entity {
                    EditCalendarEntityView(entity: entity)
                } else {
                    CreateEventView()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("New")
                        .systemFont(17, .semibold)
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .systemFont(17)
                    }
                }

                if isEdit {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            Task {
                                dismiss()
                                didEditEntity?()
                            }
                        } label: {
                            Text("Save")
                        }
                    }
                }
            }
        }
    }
}

struct CreateEventView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: CalendarViewModel

    @State private var isEvent: Bool = true
    @State private var event: CalendarEvent = CalendarEvent()
    @State private var reminder: CalendarReminder = CalendarReminder()

    var body: some View {
        VStack {
            eventTypeSwitcher

            if isEvent {
                EditCalendarEntityView(entity: $event)
            } else {
                EditCalendarEntityView(entity: $reminder)
            }
        }
        .onChange(of: event) {
            reminder.syncFields(from: event)
        }
        .onChange(of: reminder) {
            event.syncFields(from: reminder)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task {
                        dismiss()
                        isEvent ? await viewModel.addEvent(event) : await viewModel.addReminder(reminder)
                    }
                } label: {
                    Text("Create")
                        .systemFont(17, .semibold, event.title.isEmpty || event.calendarID.isEmpty ? .gray : .blue.opacity(1))
                }
                .disabled(event.title.isEmpty || event.calendarID.isEmpty)
            }
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
                    .background(isEvent ? Color.blue.opacity(0.3) : Color.clear)
                    .cornerRadius(6)
                    .padding(2)
            }
            .padding(.leading, 3)

            Button {
                self.isEvent = false
            } label: {
                Text("Reminder")
                    .systemFont(15, .semibold)
                    .frame(height: 32)
                    .greedyWidth()
                    .background(!isEvent ? Color.blue.opacity(0.3) : Color.clear)
                    .cornerRadius(6)
                    .padding(2)
            }
            .padding(.trailing, 3)
        }
        .greedyWidth()
        .background(.blue.opacity(0.1))
        .frame(height: 38)
        .cornerRadius(8)
        .padding(.horizontal, 8)
    }
}

struct EditCalendarEntityView<Entity: CalendarEntity>: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var entity: Entity

    @State private var selectedCalendar: ProviderCalendar?

    var eventBinding: Binding<CalendarEvent>? {
        guard let event = entity as? CalendarEvent else { return nil }

        return Binding<CalendarEvent>(
            get: { event },
            set: { newValue in
                if let updated = newValue as? Entity {
                    entity = updated
                }
            }
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                TextField("Title*", text: $entity.title)
                
                Color.blue.opacity(0.3)
                    .frame(height: 1)

                if let eventBinding {
                    FieldTimeAndDate(isAllDay: eventBinding.isAllDay, startsDay: $entity.startDate, endsDay: eventBinding.endDate)
                } else {
                    FieldTimeOrDate(type: .date, date: $entity.startDate)
                    FieldTimeOrDate(type: .time, date: $entity.startDate)
                }
                
                Color.blue.opacity(0.3)
                    .frame(height: 1)

                FieldCalendarSelection(selectedCalendar: $selectedCalendar)

                FieldEnumPicker(eventFieldType: .repeatField, currentValue: $entity.repeatType)

                if let _ = entity as? CalendarEvent { } else {
                    FieldEnumPicker(eventFieldType: .priority, currentValue: $entity.priorityType)
                }
                
                Color.blue.opacity(0.3)
                    .frame(height: 1)
                
                FieldDescription(description: $entity.notes)
                
                Color.blue.opacity(0.3)
                    .frame(height: 1)
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
        }
        .greedyWidth()
        .padding(16)
        .onChange(of: selectedCalendar) {
            if let selectedCalendar {
                entity.calendarID = selectedCalendar.id
                entity.calendarColor = selectedCalendar.color
            }
        }
    }
}

fileprivate extension CalendarEntity {
    mutating func syncFields<T: CalendarEntity>(from other: T) {
        self.calendarID = other.calendarID
        self.title = other.title
        self.notes = other.notes
        self.calendarColor = other.calendarColor
        self.startDate = other.startDate
        self.repeatType = other.repeatType
        self.alertType = other.alertType
        self.priorityType = other.priorityType
        self.vibrationType = other.vibrationType
    }
}

extension CreateOrEditEventView where Entity == CalendarEvent {
    init() {
        self.init(entity: nil)
    }
}
