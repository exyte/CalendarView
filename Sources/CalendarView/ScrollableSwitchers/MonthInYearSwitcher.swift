//
//  MonthInYearSwitcher.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 14.05.2025.
//

import SwiftUI

/// Select a month from a year, scroll between years
struct MonthInYearSwitcher: View {
    @Environment(\.calendarTheme) var theme
    @Environment(\.dismiss) private var dismiss

    var date: Date
    var didSelectMonth: (Date)->()

    @State private var items: [Int] = Array(-5...5)
    @State private var tableUpdateID = UUID() // triggers table update

    @State private var yearCellSize: CGSize?

    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        VStack {
            CloseSaveHeaderView(title: "Year")

            Group {
                TextField("\(Image(systemName: "magnifyingglass")) Search a year", text: $searchText)
                    .padding(16, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 22)
                            .fill(theme.main.cardBackground)
                            .stroke(theme.main.separator, lineWidth: 1)
                    )
                    .submitLabel(.search)
                    .focused($isSearchFocused)
                    .onSubmit {
                        centerOnYear()
                        isSearchFocused = false
                    }
            }
            .padding(.horizontal, 16)

            if let yearCellSize {
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
                .scrollMode(scrollMode: .free(yearCellSize.height))
            }
        }
        .background(theme.year.background)
        .background {
            FinalMeasuringTrickView(size: $yearCellSize, id: "year") {
                YearLayout(date: Date(), didSelectMonth: {_ in})
                    .padding(16)
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
