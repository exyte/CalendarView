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
) -> InfiniteTableView<Int, Content> {
    InfiniteTableView(data: items.wrappedValue) { direction, pageSize in
        DispatchQueue.main.async {
            switch direction {
            case .backward:
                for _ in 0..<pageSize {
                    items.wrappedValue.insert(items.wrappedValue.first! - 1, at: 0)
                }
            case .forward:
                for _ in 0..<pageSize {
                    items.wrappedValue.append(items.wrappedValue.last! + 1)
                }
            }
        }
    } content: { item in
        content(item)
    }
}
