//
//  EditEntityFieldsView.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 18.06.2026.
//

import SwiftUI

struct EditEntityFieldsView<Entity: CalendarEntity>: View {

    @Binding var entity: Entity

    @State var selectedCalendar: ProviderCalendar?

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
                    FieldTimeAndDate(isAllDay: eventBinding.isAllDay, startDate: $entity.startDate, endDate: eventBinding.endDate)
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
            }
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
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
