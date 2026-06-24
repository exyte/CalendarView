//
//  DefaultHeaderView.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 29.04.2025.
//

import SwiftUI
import AnchoredPopup

public struct DefaultHeaderView: View {
    @Environment(\.calendarTheme) var theme

    var params: HeaderBuilderParams

    @State private var showMonthPicker = false

    public init(params: HeaderBuilderParams) {
        self.params = params
    }

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

            Button {
                params.tapAddEventClosure()
            } label: {
                Image(.add)
            }
            .padding(8)
            .background(Circle().styled(theme.button.accent))
        }
        .padding(.horizontal, 10)
        .sheet(isPresented: $showMonthPicker) {
            MonthInYearSwitcher(date: params.fullscreenDate.wrappedValue.startOfYear) { month in
                params.fullscreenDate.wrappedValue = month
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
            case .twoDays, .threeDays:
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
                makeModeSwitcherButton("2 Day", .three, .twoDays)
                makeModeSwitcherButton("3 Day", .three, .threeDays)
            }
            .padding(18, 10)
            .background(RoundedRectangle.styled(20, .white))
        } customize: {
            $0.position(.anchorRelative(.topLeading))
                .closeOnTapOutside(true)
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
        self.padding(8)
            .background(Circle().styled(.white.opacity(0.12), border: .white.opacity(0.4), 0.5))
    }
}
