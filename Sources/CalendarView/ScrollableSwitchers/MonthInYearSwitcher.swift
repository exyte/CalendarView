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

    @State private var items: [Int] = Array(-5...5)
    @State private var tableUpdateID = UUID() // triggers table update

    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        VStack {
            headerView
                .padding(16, 8)

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
        }
        .background(theme.year.background)
    }

    var headerView: some View {
        HStack {
            Button("Cancel") {
                dismiss()
            }
            .systemFont(17, .semibold, theme.main.accent)
            .padding(.trailing, 20)

            TextField("Enter a year", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .submitLabel(.search)
                .focused($isSearchFocused)
                .onSubmit {
                    centerOnYear()
                    isSearchFocused = false
                }

            Button("Search") {
                centerOnYear()
                isSearchFocused = false
            }
            .systemFont(17, .semibold, theme.main.accent)
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
