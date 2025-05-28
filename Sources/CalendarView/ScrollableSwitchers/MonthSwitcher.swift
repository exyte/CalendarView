//
//  MonthSwitcher.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 14.05.2025.
//

import SwiftUI

struct MonthSwitcher: View {
    @Environment(\.calendarTheme) private var theme
    @Environment(\.dismiss) private var dismiss

    var date: Date
    var didSelectMonth: (Date)->()

    @State private var items: [Int] = Array(-5...5)
    @State private var searchText = ""
    @State private var tableUpdateID = UUID() // triggers table update

    @FocusState private var isSearchFocused: Bool

    var body: some View {
        VStack {
            headerView
                .padding(16, 8)

            InfiniteTableView(data: items, threshold: 2, tableUpdateID: tableUpdateID) { direction, threshold in
                DispatchQueue.main.async {
                    switch direction {
                    case .top:
                        for _ in 0..<threshold {
                            items.insert(items.first! - 1, at: 0)
                        }
                    case .bottom:
                        for _ in 0..<threshold {
                            items.append(items.last! + 1)
                        }
                    }
                }
            } content: { item in
                let yearDate = date.startOfYear.adding(.year, value: item)
                YearLayout(date: yearDate) { month in
                    didSelectMonth(yearDate.setMonth(to: month))
                }
                .padding(16)
                .background(theme.year.background)
            }
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

extension Int: @retroactive Identifiable {
    public var id: Int {
        self
    }
}
