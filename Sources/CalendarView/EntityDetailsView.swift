//
//  EntityDetailsView.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 11.07.2025.
//

import SwiftUI

struct EntityDetailsView<Entity: CalendarEntity>: View {
    @Environment(\.calendarTheme) var theme
    @Environment(\.dismiss) var dismiss
    @Environment(CalendarViewModel.self) var viewModel

    @State var entity: Entity

    @State private var showDeleteAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                theme.main.background
                    .ignoresSafeArea()
                    .overlay {
                        VStack {
                            LinearGradient(gradient: Gradient(colors: [entity.calendarColor.opacity(0.5), Color.clear]), startPoint: .top, endPoint: .bottom)
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

                        Spacer().frame(height: 15)
                    }
                }
                .padding(.horizontal, 16)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("\(entity.typeString) Details")
                        .libraryFont(17, .semibold)
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: "chevron.left")

                            Text(entity.startDate.shortDateFormat)
                                .libraryFont(17)
                        }
                        .opacity(0.6)
                    }
                }
                .removeSharedBackground()

                if entity.isLocalEntity {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink("Edit") {
                            EditEntityView(entity: entity) { editedEntity in
                                let oldEntity = entity
                                self.entity = editedEntity
                                await viewModel.update(editedEntity, oldCalendarID: oldEntity.calendarID, oldStartDate: oldEntity.startDate)
                            }
                        }
                        .libraryFont(17, theme.main.text)
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
        VStack(alignment: .leading, spacing: 12) {
            Text(entity.title)
                .libraryFont(20, .semibold)

            headerDateTextView
                .libraryFont(13)
                .opacity(0.6)

            Text("Repeats \(entity.repeatType.rawValue)")
                .libraryFont(13)
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
                .libraryFont(17)

            Spacer()

            Color(entity.calendarColor)
                .frame(width: 16, height: 16)
                .cornerRadius(8)

            Text(entity.calendarName)
                .libraryFont(17)
                .opacity(0.6)
        }
    }

    private var descriptionFieldView: some View {
        VStack(alignment: .leading) {
            Text("Description")
                .libraryFont(17)
                .padding(.top, 6)

            Text(entity.notes)
                .libraryFont(15)
                .padding(.vertical, 6)
        }
    }

    private var deleteButton: some View {
        Button {
            showDeleteAlert = true
        } label: {
            Text("Delete \(entity.typeString)")
                .libraryFont(15, theme.main.deleteText)
                .frame(maxWidth: .infinity)
        }
        .padding(.top, 12)
        .padding(.horizontal, 16)
    }

    private var separatorView: some View {
        theme.main.separator.frame(height: 1)
    }

    private func numberOfDaysBetween(_ from: Date, _ to: Date) -> Int {
        let numberOfDays = Calendar.current.dateComponents([.day], from: from, to: to)
        return numberOfDays.day ?? 0
    }
}
