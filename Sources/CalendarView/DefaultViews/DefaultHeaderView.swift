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

    var params: HeaderBuilderParams

    public init(params: HeaderBuilderParams) {
        self.params = params
    }

    @State private var showMonthPicker = false

    public var body: some View {
        HStack {
            Button {
                showMonthPicker = true
            } label: {
                HStack {
                    Text(params.anchorDate.formatted("MMMM, yyyy"))
                        .systemFont(15, .semibold, theme.header.text)
                    Image(systemName: "chevron.down")
                        .foregroundStyle(theme.header.text)
                }
            }

            Spacer()

            displayModeSwitcher

            Button {
                params.tapFilterCalendarsClosure()
            } label: {
                Image(.filters)
            }
            .styleLikeButton()
        }
        .padding(.horizontal, 10)
        .sheet(isPresented: $showMonthPicker) {
            MonthSwitcher(date: params.selectedDate.wrappedValue.startOfYear) { month in
                params.selectedDate.wrappedValue = month
                params.displayMode.wrappedValue = .month
                showMonthPicker = false
            }
        }
    }

    var displayModeSwitcher: some View {
        ZStack {
            switch params.displayMode.wrappedValue {
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
            params.displayMode.wrappedValue = mode
        } label: {
            HStack {
                Image(image).renderingMode(.template)
                Text(title)
            }
        }
        .foregroundStyle(params.displayMode.wrappedValue == mode ? theme.main.text : theme.main.secondaryText)
    }
}

fileprivate extension View {
    func styleLikeButton() -> some View {
        self.padding(5)
            .background(Circle().styled(.white.opacity(0.12), border: .white.opacity(0.4), 0.5))
    }
}
