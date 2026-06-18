//
//  EventDetailsView.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 11.07.2025.
//

import SwiftUI

struct EventDetailsView<Entity: CalendarEntity>: View {
    @Environment(\.calendarTheme) private var theme
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: CalendarViewModel

    var entity: Entity

    @State private var showDeleteAlert = false

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
                    headerView
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 16)

                    separatorView

                    calendarFieldView
                        .padding(.vertical, 6)

                    separatorView

                    // MARK: Description

                    if !entity.notes.isEmpty {
                        descriptionFieldView

                        separatorView
                    }

                    Spacer()

                    if entity.isLocalEntity {
                        deleteButton

                        Spacer()
                            .frame(height: 15)
                    }
                }
                .padding(.horizontal, 16)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Event Details")
                        .systemFont(17, .semibold)
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
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
                    }
                }
                .removeSharedBackground()

                if entity.isLocalEntity {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink("Edit") {
                            EditEntityView(entity: entity) { editedEntity in
                                await viewModel.update(editedEntity, oldStartDate: entity.startDate)
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
                    Task {
                        await viewModel.delete(entity)
                    }
                    dismiss()
                }
            }
        }
    }

    private var headerView: some View {
        VStack(alignment: .leading) {

            Text(entity.title)
                .systemFont(20, .semibold)
                .padding(.bottom, 8)

            headerDateTextView
                .systemFont(13, .regular)
                .opacity(0.6)

            Text("Repeats \(entity.repeatType.rawValue)")
                .systemFont(13, .regular)
                .padding(.top, 8)
        }
    }

    @ViewBuilder
    private var headerDateTextView: some View {
        if let event = entity as? CalendarEvent,
           numberOfDaysBetween(event.startDate, event.endDate) <= 1,
           event.isAllDay {
            Text(event.startDate.dateFullFormat)
            Text("All day")
        }
        else if let event = entity as? CalendarEvent,
                numberOfDaysBetween(event.startDate, event.endDate) <= 1 {
            Text(event.startDate.dateFullFormat)
            Text("From \(event.startDate.timeFormat) to \(event.endDate.timeFormat)")
        }
        else if let event = entity as? CalendarEvent {
            Text("From \(event.startDate.dateFormat) \(event.startDate.timeFormat)")
            Text("To \(event.endDate.dateFormat) \(event.endDate.timeFormat)")
        }
        else {
            Text(entity.startDate.dateFullFormat)
            Text("\(entity.startDate.timeFormat)")
        }
    }

    private var calendarFieldView: some View {
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
    }

    private var descriptionFieldView: some View {
        VStack(alignment: .leading) {
            Text("Description")
                .systemFont(17, .regular)
                .padding(.top, 6)

            Text(entity.notes)
                .systemFont(15, .regular)
                .padding(.vertical, 6)
        }
    }

    private var deleteButton: some View {
        Button {
            showDeleteAlert = true
        } label: {
            Text("Delete \(entity.entityType == .reminder ? "Reminder" : "Event")")
                .systemFont(15, .regular, .red)
                .frame(maxWidth: .infinity)
        }
        .padding(.top, 12)
        .padding(.horizontal, 16)
    }

    private var separatorView: some View {
        Color(.appLightGrey).frame(height: 1)
    }

    private func numberOfDaysBetween(_ from: Date, _ to: Date) -> Int {
        let numberOfDays = Calendar.current.dateComponents([.day], from: from, to: to)
        return numberOfDays.day ?? 0
    }
}
