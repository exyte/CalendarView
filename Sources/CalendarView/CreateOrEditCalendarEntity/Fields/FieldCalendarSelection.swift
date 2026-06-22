//
//  FieldCalendarSelection.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 07.07.2025.
//

import SwiftUI

struct FieldCalendarSelection: View {
    @Environment(CalendarViewModel.self) var viewModel
    @Binding var selectedCalendar: ProviderCalendar?

    @State var showSelectionPopup: Bool = false

    var body: some View {
        HStack(alignment: .top) {
            HStack(spacing: 0) {
                Text("Calendar")
                    .systemFont(17, .regular)

                Text("*")
                    .systemFont(17, .regular, .red)
                    .padding(.leading, 4)

                Spacer()
            }

            Spacer()

            if let title = selectedCalendar?.title {
                Text(title)
                    .frame(height: 34)
                    .padding(.horizontal, 12)
                    .background(Color(selectedCalendar?.color ?? .clear).opacity(0.3))
                    .cornerRadius(17)
            } else {
                Text("Not selected")
                    .systemFont(17, .regular, Color.named("appGrey"))
            }

            Image(.rightArrow)
                .frame(width: 24, height: 24)
                .foregroundStyle(Color.named("appLightGrey"))
        }
        .contentShape(Rectangle())
        .onTapGesture {
            showSelectionPopup = true
        }
        .scrollPopup(isPresented: $showSelectionPopup) {
            CalendarSelectionPopupView(selectedCalendar: $selectedCalendar)
        } header: {
            PopupHeaderView()
        } customize: {
            $0
                .closeOnTap(false)
                .closeOnTapOutside(true)
                .dragToDismiss(true)
                .backgroundColor(.black.opacity(0.5))
        }
    }
}

struct CalendarSelectionPopupView: View {
    @Environment(\.popupDismiss) var dismiss
    @Environment(CalendarViewModel.self) var viewModel

    @Binding var selectedCalendar: ProviderCalendar?

    @State var calendars: [ProviderCalendar] = []
    @State var showCreateCalendar = false
    @State var id = UUID()
    @State var size: CGSize = .zero

    var body: some View {
        VStack(spacing: 20) {
            Text("Select calendar")
                .systemFont(20, .semibold)

            ForEach(calendars) { calendar in
                HStack {
                    Circle()
                        .foregroundStyle(calendar.color)
                        .size(10)

                    Text(calendar.title)

                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedCalendar = calendar
                    dismiss?()
                }
            }
        }
        .sizeGetter($size)
        .onChange(of: viewModel.calendars, initial: true) { _, newValue in
            //withAnimation { // animation breaks height
                calendars = newValue
            //}
        }
        .greedyWidth()
        .padding(16, 10)
        .padding(.bottom, 30)
        .background(.white)
    }
}
