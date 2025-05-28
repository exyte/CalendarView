//
//  DefaultHeaderView.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 29.04.2025.
//

import SwiftUI
import AnchoredPopup

public struct DefaultHeaderView: View {
    @Environment(\.calendarTheme) private var theme

    @Binding var selectedDate: Date
    @Binding var displayMode: CalendarDisplayMode
    var tapFilterCalendarsClosure: ()->()

    public init(selectedDate: Binding<Date>, displayMode: Binding<CalendarDisplayMode>, tapFilterCalendarsClosure: @escaping ()->()) {
        self._selectedDate = selectedDate
        self._displayMode = displayMode
        self.tapFilterCalendarsClosure = tapFilterCalendarsClosure
    }

    @State private var showMonthPicker = false

    public var body: some View {
        HStack {
            Button {
                showMonthPicker = true
            } label: {
                HStack {
                    Text(selectedDate.formatted("MMMM, yyyy"))
                        .systemFont(15, .semibold, theme.header.text)
                    Image(systemName: "chevron.down")
                        .foregroundStyle(theme.header.text)
                }
            }

            Spacer()

            displayModeSwitcher

            Button {
                tapFilterCalendarsClosure()
            } label: {
                Image(.filters)
            }
            .styleLikeButton()
        }
        .padding(.horizontal, 10)
        .sheet(isPresented: $showMonthPicker) {
            MonthSwitcher(date: selectedDate.startOfYear) { month in
                selectedDate = month
                displayMode = .month
                showMonthPicker = false
            }
        }
    }

    var displayModeSwitcher: some View {
        ZStack {
            switch displayMode {
            case .day:
                Image(.day)
            case .threeDays:
                Image(.three)
            case .month:
                Image(.month)
            }
        }
        .styleLikeButton()
        .useAsPopupAnchor(id: "displayMode") {
            VStack(alignment: .leading) {
                makeModeSwitcherButton("Month", .month, .month)
                makeModeSwitcherButton("Day", .day, .day)
                makeModeSwitcherButton("3 Day", .three, .threeDays)
            }
            .padding(18, 10)
            .background(RoundedRectangle.styled(20, .white))
        } customize: {
            $0.position(.anchorRelative(.topLeading))
                .background(.none)
        }
    }

    func makeModeSwitcherButton(_ title: String, _ image: ImageResource, _ mode: CalendarDisplayMode) -> some View {
        Button {
            displayMode = mode
        } label: {
            HStack {
                Image(image).renderingMode(.template)
                Text(title)
            }
        }
        .foregroundStyle(displayMode == mode ? theme.main.text : theme.main.secondaryText)
    }
}

fileprivate extension View {
    func styleLikeButton() -> some View {
        self.padding(5)
            .background(Circle().styled(.white.opacity(0.12), border: .white.opacity(0.4), 0.5))
    }
}
