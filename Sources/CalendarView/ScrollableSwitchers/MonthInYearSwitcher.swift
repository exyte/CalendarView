//
//  MonthInYearSwitcher.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 14.05.2025.
//

import SwiftUI

/// Select a month from a year, scroll between years
struct MonthInYearSwitcher: View {
    @Environment(\.calendarTheme) private var theme
    @Environment(\.dismiss) private var dismiss

    var date: Date
    var didSelectMonth: (Date)->()

    @State var items: [Int] = Array(-5...5)
    @State var tableUpdateID = UUID() // triggers table update

    @State var yearCellSize: CGSize?

    @State var searchText = ""
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        VStack {
            headerView

            Group {
                TextField("\(Image(systemName: "magnifyingglass")) Search a year", text: $searchText)
                    .padding(16, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 22)
                            .fill(Color.white)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .submitLabel(.search)
                    .focused($isSearchFocused)
                    .onSubmit {
                        centerOnYear()
                        isSearchFocused = false
                    }
            }
            .padding(.horizontal, 16)

            createSimpleInfiniteTableView(items: $items) { item in
                let yearDate = date.startOfYear.adding(.year, value: item)
                YearLayout(date: yearDate) { month in
                    didSelectMonth(yearDate.setMonth(to: month))
                }
                .padding(16)
                .background(theme.year.background)
            }
            .loadMoreParameters(threshold: 2, pageSize: 4)
            .reloadTrigger(updateID: tableUpdateID)
            .scrollMode(scrollMode: .free(yearCellSize?.height))
        }
        .background(theme.year.background)
        .background {
            MeasuringTrickView(size: $yearCellSize) {
                YearLayout(date: Date(), didSelectMonth: {_ in})
            }
        }
    }

    var headerView: some View {
        ZStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(.cross)
                }
                .frame(width: 44, height: 44)
                .background(Circle().styled(theme.button.background))

                Spacer()
            }

            Text("Year").systemFont(17, .semibold, theme.main.text)
        }
        .padding(16)
        .overlay {
            VStack {
                Capsule()
                    .frame(width: 36, height: 5)
                    .foregroundStyle(theme.main.secondaryText)
                    .padding(.top, 5)

                Spacer()
            }
        }
    }

    private func centerOnYear() {
        guard let year = Int(searchText) else { return }

        let baseYear = Calendar.current.component(.year, from: date)
        let diff = year - baseYear
        let range = (diff - 5)...(diff + 5)

        items = Array(range)
        tableUpdateID = UUID()
    }
}
