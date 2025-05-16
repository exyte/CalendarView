//
//  DefaultHeaderView.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 29.04.2025.
//

import SwiftUI
import AnchoredPopup

public struct DefaultHeaderView: View {
    @Binding var selectedDate: Date
    @Binding var displayMode: CalendarDisplayMode
    @Binding var showCalendarFilters: Bool

    public init(selectedDate: Binding<Date>, displayMode: Binding<CalendarDisplayMode>, showCalendarFilters: Binding<Bool>) {
        self._selectedDate = selectedDate
        self._displayMode = displayMode
        self._showCalendarFilters = showCalendarFilters
    }

    @State private var showMonthPicker = false

    public var body: some View {
        HStack {
            Button {
                showMonthPicker = true
            } label: {
                HStack {
                    Text(selectedDate.formatted("MMMM, yyyy"))
                    Image(systemName: "chevron.down")
                }
            }
            .foregroundStyle(.white)

            Spacer()

            displayModeSwitcher

            Button {
                showCalendarFilters = true
            } label: {
                Image(.filters)
            }
            .styleLikeButton()
        }
        .padding(10)
        .background(Color.green.opacity(0.5))
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
        .foregroundStyle(displayMode == mode ? Color("appBlack", bundle: .module) : Color("appGrey", bundle: .module))
    }
}

fileprivate extension View {
    func styleLikeButton() -> some View {
        self.padding(5)
            .background(Circle().colored(.white.opacity(0.12), border: .white.opacity(0.4), 0.5))
    }
}
