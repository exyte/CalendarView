//
//  EventDetailsView.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 11.07.2025.
//

import SwiftUI

struct EventDetailsView: View {
    @Environment(\.calendarTheme) private var theme
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: CalendarViewModel

    let entity: any CalendarEntity
    @State private var editableEntity: any CalendarEntity

    @State private var showDeleteAlert = false

    init(entity: any CalendarEntity) {
        self.entity = entity
        self._editableEntity = State(initialValue: entity)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(theme.main.background)
                    .ignoresSafeArea()
                    .overlay {
                        VStack {
                            LinearGradient(gradient: Gradient(colors: [Color(entity.calendarColor).opacity(0.5), Color.clear]), startPoint: .top, endPoint: .bottom)
                                .frame(height: 250)
                                .ignoresSafeArea()

                            Spacer()
                        }
                    }
                
                VStack {
                    VStack(alignment: .leading) {

                        Text(entity.title)
                            .systemFont(20, .semibold)
                            .padding(.bottom, 8)

                        // MARK: Date

                        VStack(alignment: .leading) {
                            if let event = entity as? CalendarEvent {
                                if numberOfDaysBetween(event.startDate, event.endDate) <= 1 {
                                    Text(event.startDate.dateFullFormat)
                                        .systemFont(13, .regular)
                                        .opacity(0.6)

                                    if event.isAllDay {
                                        Text("All day")
                                            .systemFont(13, .regular)
                                            .opacity(0.6)
                                    } else {
                                        Text("From \(event.startDate.timeFormat) to \(event.endDate.timeFormat)")
                                            .systemFont(13, .regular)
                                            .opacity(0.6)
                                    }
                                } else {
                                    Text("From \(event.startDate.dateFormat) \(event.startDate.timeFormat)")
                                        .systemFont(13, .regular)
                                        .opacity(0.6)

                                    Text("To \(event.endDate.dateFormat) \(event.endDate.timeFormat)")
                                        .systemFont(13, .regular)
                                        .opacity(0.6)
                                }
                            } else {
                                Text(entity.startDate.dateFullFormat)
                                    .systemFont(13, .regular)
                                    .opacity(0.6)

                                Text("\(entity.startDate.timeFormat)")
                                    .systemFont(13, .regular)
                                    .opacity(0.6)
                            }

                            Text("Repeats \(entity.repeatType.rawValue)")
                                .systemFont(13, .regular)
                                .padding(.top, 8)
                        }

                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)

                    // MARK: Calendar

                    VStack {
                        separatorView

                        HStack {
                            Text("Calendar")
                                .systemFont(17, .regular)

                            Spacer()

                            Color(entity.calendarColor)
                                .frame(width: 16, height: 16)
                                .cornerRadius(8)

                            Text(entity.calendarName)
                                .systemFont(17, .regular)
                                .opacity(0.6)
                        }
                        .padding(.vertical, 6)

                        separatorView
                    }
                    .padding(.horizontal, 16)

                    // MARK: Description

                    if !entity.notes.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Description")
                                .systemFont(17, .regular)
                                .padding(.top, 6)

                            Text(entity.notes)
                                .systemFont(15, .regular)
                                .padding(.vertical, 6)

                            separatorView
                        }
                        .padding(.horizontal, 16)
                    }

                    Spacer()

                    if entity.isLocalEntity() {
                        Button {
                            showDeleteAlert = true
                        } label: {
                            Text("Delete \(entity.entityType == .reminder ? "Reminder" : "Event")")
                                .systemFont(15, .regular, .red)
                                .frame(maxWidth: .infinity)
                        }
                        .padding(.top, 12)
                        .padding(.horizontal, 16)
                        
                        Spacer()
                            .frame(height: 15)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Event Details")
                        .systemFont(17, .semibold)
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        HStack(spacing: 4) {
                            Image(.rightArrow)
                                .renderingMode(.template)
                                .foregroundColor(.black)
                                .rotationEffect(Angle(degrees: 180))

                            Text(entity.startDate.shortDateFormat)
                                .systemFont(17, .regular)
                                .padding(.trailing, 8)
                        }
                        .opacity(0.6)
                    })
                }
                .removeSharedBackground()

                if entity.isLocalEntity() {
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
                        .foregroundStyle(Color(theme.button.accent))
                    }
                    .removeSharedBackground()
                }
            }
            .alert("Are you sure you want to delete this event?", isPresented: $showDeleteAlert) {
                Button("No", role: .cancel) { }
                Button("Yes", role: .destructive) {
                    if let event = entity as? CalendarEvent {
                        Task{
                            await viewModel.deleteEvent(event)
                        }
                    } else if let reminder = entity as? CalendarReminder {
                        Task {
                            await viewModel.deleteReminder(reminder)
                        }
                    }
                    dismiss()
                }
            }
        }
    }

    private var separatorView: some View {
        Color(.appLightGrey).frame(height: 1)
    }

    private func bindingForEditableEntity<T: CalendarEntity>(as type: T.Type) -> Binding<T>? {
        guard let casted = editableEntity as? T else { return nil }
        return Binding(
            get: { casted },
            set: { newValue in editableEntity = newValue }
        )
    }

    private func numberOfDaysBetween(_ from: Date, _ to: Date) -> Int {
        let numberOfDays = Calendar.current.dateComponents([.day], from: from, to: to)

        return numberOfDays.day ?? 0
    }
}
