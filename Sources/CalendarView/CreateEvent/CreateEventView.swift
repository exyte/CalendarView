//
//  CreateEventView.swift
//  Jaye
//
//  Created by Exyte on 01.04.2025.
//

import SwiftUI

struct CreateOrEditEventView<Entity: CalendarEntity>: View {
    @Environment(\.calendarTheme) private var theme
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: CalendarViewModel

    @State var saveNewEvent: (()->())?
    @State var saveDisabled: Bool = false

    var entity: Binding<Entity>?
    var didEditEntity: (()->())?

    var isEdit: Bool {
        entity != nil
    }

    var body: some View {
        NavigationStack {
            headerView

            Group {
                if let entity {
                    EditCalendarEntityView(entity: entity)
                } else {
                    CreateEventView(saveNewEvent: $saveNewEvent, saveDisabled: $saveDisabled)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
        }
        .background(theme.main.background)
    }

    var headerView: some View {
        ZStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(.cross)
                }
                .frame(width: 44, height: 44)
                .background(Circle().styled(theme.button.background))

                Spacer()

                Button {
                    if isEdit {
                        dismiss()
                        didEditEntity?()
                    } else {
                        saveNewEvent?()
                    }
                } label: {
                    Image(.checkmark)
                        .resizable()
                        .frame(width: 14, height: 12)
                }
                .frame(width: 44, height: 44)
                .background(Circle().styled(saveDisabled ? theme.button.disabled : theme.button.accent))
                .disabled(saveDisabled)
            }

            Text(isEdit ? "Edit" : "New").systemFont(17, .semibold, theme.main.text)
        }
        .padding(16)
        .overlay {
            VStack {
                Capsule()
                    .frame(width: 36, height: 5)
                    .foregroundStyle(theme.main.secondaryText)
                    .padding(.top, 5)

                Spacer()
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

    @Binding var saveNewEvent: (()->())?
    @Binding var saveDisabled: Bool

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
            saveDisabled = event.title.isEmpty || event.calendarID.isEmpty
        }
        .onChange(of: reminder) {
            event.syncFields(from: reminder)
            saveDisabled = event.title.isEmpty || event.calendarID.isEmpty
        }
        .onAppear {
            saveDisabled = true
            saveNewEvent = {
                Task {
                    dismiss()
                    isEvent ? await viewModel.addEvent(event) : await viewModel.addReminder(reminder)
                }
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
                HStack(spacing: 0) {
                    Text("Title")
                        .systemFont(15, .regular)

                    Text("*")
                        .systemFont(15, .regular, .red)
                        .padding(.leading, 4)

                    Spacer()
                }

                TextField("Event title...", text: $entity.title)
                    .systemFont(20, .semibold)

                separatorView

                if let eventBinding {
                    FieldTimeAndDate(isAllDay: eventBinding.isAllDay, startsDay: $entity.startDate, endsDay: eventBinding.endDate)
                } else {
                    FieldTimeOrDate(type: .date, date: $entity.startDate)
                    FieldTimeOrDate(type: .time, date: $entity.startDate)
                }
                
                separatorView

                FieldCalendarSelection(selectedCalendar: $selectedCalendar)

                FieldEnumPicker(eventFieldType: .repeatField, currentValue: $entity.repeatType)

                if entity as? CalendarEvent == nil {
                    FieldEnumPicker(eventFieldType: .priority, currentValue: $entity.priorityType)
                }
                
                separatorView

                FieldDescription(description: $entity.notes)
                
                separatorView
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
                entity.calendarName = selectedCalendar.title
            }
        }
    }

    var separatorView: some View {
        Color.named("appLightGrey")
            .frame(height: 1)
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

extension CreateOrEditEventView where Entity == CalendarEvent {
    init() {
        self.init(entity: nil)
    }
}
