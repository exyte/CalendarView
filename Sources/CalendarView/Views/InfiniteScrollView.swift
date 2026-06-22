//
//  InfiniteDirection.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 06.06.2025.
//

import SwiftUI

/// use simple integers as data
@MainActor
func createSimpleInfiniteTableView<Content: View>(
    items: Binding<[Int]>,
    @ViewBuilder content: @escaping (Int) -> Content
) -> InfiniteTableView<Int, EmptyUpdatable, Content, EmptyView> {
    InfiniteTableView(data: items) { direction, pageSize in
        switch direction {
        case .backward:
            guard let first = items.wrappedValue.first else { return }
            for offset in 1...pageSize {
                items.wrappedValue.insert(first - offset, at: 0)
            }
        case .forward:
            guard let last = items.wrappedValue.last else { return }
            for offset in 1...pageSize {
                items.wrappedValue.append(last + offset)
            }
        }
    } content: { item in
        content(item)
    }
}
