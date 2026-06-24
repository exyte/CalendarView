//
//  EditEntityFieldsView.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 18.06.2026.
//

import SwiftUI

struct EditEntityFieldsView<Entity: CalendarEntity>: View {
    @Environment(CalendarViewModel.self) var viewModel

    @Binding var entity: Entity

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

    var calendarBinding: Binding<ProviderCalendar?> {
        Binding<ProviderCalendar?>(
            get: { viewModel.calendars.first { $0.id == entity.calendarID } },
            set: { newValue in
                if let selectedCalendar = newValue {
                    entity.calendarID = selectedCalendar.id
                    entity.calendarColor = selectedCalendar.color
                    entity.calendarName = selectedCalendar.title
                }
            }
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack(spacing: 4) {
                    Text("Title")
                        .systemFont(15, .appBlack2, 0.6)
                    Text("*")
                        .systemFont(15, .red)
                    Spacer()
                }

                TextField("\(entity.typeString) title...", text: $entity.title)
                    .systemFont(20, .semibold, .appBlack2)

                separatorView

                if let eventBinding {
                    FieldTimeAndDate(isAllDay: eventBinding.isAllDay, startDate: $entity.startDate, endDate: eventBinding.endDate)
                } else {
                    FieldTimeOrDate(date: $entity.startDate)
                }

                separatorView

                FieldCalendarSelection(selectedCalendar: calendarBinding)

                separatorView

                FieldEnumPicker(selection: $entity.repeatType)
            }
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        .greedyWidth()
        .padding(16)
    }

    var separatorView: some View {
        Color(.appGrey4).frame(height: 1)
    }
}
