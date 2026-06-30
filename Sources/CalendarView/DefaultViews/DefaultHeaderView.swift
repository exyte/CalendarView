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
    @Environment(\.calendarCustomizationParams) var customizationParams
    @Environment(CalendarViewModel.self) var viewModel

    var params: HeaderBuilderParams

    @State private var showMonthPicker = false

    private static let today = Date().startOfDay

    public init(params: HeaderBuilderParams) {
        self.params = params
    }

    public var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 20) {
                monthAndButtonsView
                    .padding(.horizontal, 16)
                params.defaultWeekSwitcher()
                    .padding(.horizontal, 4)
            }
            .padding(.bottom, 10)
            .background {
                HeaderBackgroundView(background: customizationParams.headerBackground)
            }

            if params.displayMode.wrappedValue != .month {
                dateAndEventsCountView
            }
        }
    }

    var monthAndButtonsView: some View {
        HStack {
            Button {
                showMonthPicker = true
            } label: {
                HStack {
                    Text(params.anchorDate.wrappedValue.formatted("MMMM, yyyy"))
                        .libraryFont(15, .semibold, theme.header.text)
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
        .sheet(isPresented: $showMonthPicker) {
            MonthInYearSwitcher(date: params.fullscreenDate.wrappedValue.startOfYear) { month in
                params.fullscreenDate.wrappedValue = month
                params.displayMode.wrappedValue = .month
                showMonthPicker = false
            }
        }
    }

    var dateAndEventsCountView: some View {
        HStack {
            Text(params.fullscreenDate.wrappedValue.formatted("d MMMM yyyy"))
                .libraryFont(13, theme.main.text)

            if params.fullscreenDate.wrappedValue.startOfDay == Self.today {
                Text("(Today)")
                    .libraryFont(13, .semibold, theme.main.text)
            }

            Spacer()

            Circle()
                .frame(width: 8, height: 8)
                .foregroundStyle(theme.main.accent)

            Text("\(viewModel.getEventsAndRemindersCount(from: params.fullscreenDate.wrappedValue, displayMode: params.displayMode.wrappedValue, fullscreenDate: params.fullscreenDate.wrappedValue)) Events")
                .libraryFont(13, .semibold, theme.main.accent)
        }
        .padding(16)
        .background {
            theme.main.background
                .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 3)
        }
    }

    var displayModeSwitcher: some View {
        Image(params.displayMode.wrappedValue.icon)
            .recolor(theme.header.text)
            .styleLikeButton()
            .useAsPopupAnchor(id: "displayMode") {
                VStack(alignment: .leading) {
                    ForEach(CalendarDisplayMode.allCases, id: \.self) {
                        makeModeSwitcherButton($0)
                    }
                }
                .padding(18, 10)
                .background(RoundedRectangle.styled(20, theme.main.cardBackground))
            } customize: {
                $0.position(.anchorRelative(.topLeading))
                    .closeOnTapOutside(true)
            }
    }

    func makeModeSwitcherButton(_ mode: CalendarDisplayMode) -> some View {
        Button {
            params.displayMode.wrappedValue = mode
        } label: {
            HStack {
                Image(mode.icon).renderingMode(.template)
                Text(mode.title)
            }
        }
        .foregroundStyle(params.displayMode.wrappedValue == mode ? theme.main.text : theme.main.secondaryText)
    }
}

fileprivate struct LikeButtonStyle: ViewModifier {
    @Environment(\.calendarTheme) var theme

    func body(content: Content) -> some View {
        content
            .padding(8)
            .background(Circle().styled(theme.header.buttonBackground, border: theme.header.buttonBorder, 0.5))
    }
}

fileprivate extension View {
    func styleLikeButton() -> some View {
        modifier(LikeButtonStyle())
    }
}
