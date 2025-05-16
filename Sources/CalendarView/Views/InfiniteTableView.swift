//
//  InfiniteTableView.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 15.05.2025.
//

import SwiftUI

enum InfiniteDirection {
    case top, bottom
}

struct InfiniteTableView<Data, Content>: UIViewRepresentable where Data: Identifiable, Content: View {
    var data: [Data]
    var threshold: Int = 3
    var loadMore: ((InfiniteDirection, Int) -> Void)?
    @ViewBuilder var content: (Data) -> Content

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITableView {
        let tableView = UITableView()
        tableView.dataSource = context.coordinator
        tableView.delegate = context.coordinator
        tableView.scrollsToTop = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return tableView
    }

    func updateUIView(_ uiView: UITableView, context: Context) {
        let oldData = context.coordinator.data
        let newData = data

        if oldData.isEmpty {
            DispatchQueue.main.async {
                context.coordinator.data = newData
                uiView.reloadData()
                uiView.scrollToRow(at: IndexPath(row: data.count/2, section: 0), at: .middle, animated: false)
            }
            return
        }

        if oldData.map(\.id) == newData.map(\.id) {
            return
        }

        context.coordinator.data = newData

        // Detect prepending
        var insertedCount = 0
        for (i, item) in newData.enumerated() {
            if i >= oldData.count || oldData.first?.id != item.id {
                insertedCount += 1
            } else {
                break
            }
        }

        if insertedCount > 0, let firstVisibleIndex = uiView.indexPathsForVisibleRows?.first {
            let firstVisibleCellFrame = uiView.rectForRow(at: firstVisibleIndex)
            let currentOffsetY = uiView.contentOffset.y

            UIView.performWithoutAnimation {
                uiView.reloadData()
                uiView.layoutIfNeeded()

                let updatedVisibleIndex = IndexPath(row: insertedCount + firstVisibleIndex.row, section: 0)
                let updatedVisibleCellFrame = uiView.rectForRow(at: updatedVisibleIndex)
                let deltaY = updatedVisibleCellFrame.minY - firstVisibleCellFrame.minY
                uiView.contentOffset.y = currentOffsetY + deltaY
            }
        } else {
            uiView.reloadData()
        }
    }

    class Coordinator: NSObject, UITableViewDataSource, UITableViewDelegate {
        var parent: InfiniteTableView
        var data: [Data] = []

        init(_ parent: InfiniteTableView) {
            self.parent = parent
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            data.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
            cell.selectionStyle = .none

            if let item = data[safe: indexPath.row] {
                cell.contentConfiguration = UIHostingConfiguration {
                    parent.content(item)
                }
            }

            return cell
        }

        func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            let count = data.count
            print("count: \(count) index: \(indexPath.row) top: \(count - parent.threshold) bottom: \(parent.threshold)")
            if indexPath.row >= count - parent.threshold {
                print("load more bottom")
                parent.loadMore?(.bottom, parent.threshold)
            } else if indexPath.row <= parent.threshold {
                print("load more top")
                parent.loadMore?(.top, parent.threshold)
            }
        }
    }
}

// Helper to safely index into arrays
extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
