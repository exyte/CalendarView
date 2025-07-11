//
//  EventDetailsView.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 11.07.2025.
//

import SwiftUI

struct EventDetailsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: CalendarViewModel

    let entity: any CalendarEntity
    @State private var editableEntity: any CalendarEntity

    init(entity: any CalendarEntity) {
        self.entity = entity
        self._editableEntity = State(initialValue: entity)
    }

    var body: some View {
        NavigationStack {
            VStack {
                Text(entity.title)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Event Details")
                        .systemFont(17, .semibold)
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .systemFont(17)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink("Edit") {
                        if let event = editableEntity as? CalendarEvent,
                           let binding = bindingForEditableEntity(as: CalendarEvent.self) {
                            CreateOrEditEventView(entity: binding) {
                                Task {
                                    await viewModel.updateEvent(event, oldStartDate: entity.startDate)
                                }
                            }
                        } else if let reminder = editableEntity as? CalendarReminder,
                                  let binding = bindingForEditableEntity(as: CalendarReminder.self) {
                            CreateOrEditEventView(entity: binding) {
                                Task {
                                    await viewModel.updateReminder(reminder, oldStartDate: entity.startDate)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private func bindingForEditableEntity<T: CalendarEntity>(as type: T.Type) -> Binding<T>? {
        guard let casted = editableEntity as? T else { return nil }
        return Binding(
            get: { casted },
            set: { newValue in editableEntity = newValue }
        )
    }
}
