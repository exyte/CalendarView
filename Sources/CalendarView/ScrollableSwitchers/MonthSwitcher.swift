//
//  MonthSwitcher.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 14.05.2025.
//

import SwiftUI

struct MonthSwitcher: View {
    @Environment(\.calendarTheme) private var theme

    var date: Date
    var didSelectMonth: (Date)->()

    @State var items: [Int] = Array(-5...5)

    var body: some View {
        InfiniteTableView(data: items, threshold: 2) { direction, threshold in
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
            .padding(.bottom, 30)
            .background(theme.year.background)
        }
        .background(theme.year.background)
    }
}

extension Int: Identifiable {
    public var id: Int {
        self
    }
}
