//
//  EndlessPager.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 02.07.2026.
//

import SwiftUI

struct EndlessPager<Item: Identifiable, Content: View>: View {
    @Binding var items: [Item]
    var preloadRadius: Int = 2
    var onNeedMore: (HorizontalEdge) -> Void
    var onItemChanged: ((Item) -> Void)? = nil
    @ViewBuilder var content: (Item) -> Content

    @State private var scrolledID: Item.ID?

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(items) { item in
                    content(item)
                        .containerRelativeFrame(.horizontal)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $scrolledID)
        .scrollIndicators(.hidden)
        .onChange(of: scrolledID) { _, id in checkPreload(for: id) }
    }

    private func checkPreload(for id: Item.ID?) {
        guard let id, let index = items.firstIndex(where: { $0.id == id }) else { return }

        onItemChanged?(items[index])

        if index < preloadRadius {
            onNeedMore(.leading)
        }
        if index >= items.count - preloadRadius {
            onNeedMore(.trailing)
        }
    }
}
