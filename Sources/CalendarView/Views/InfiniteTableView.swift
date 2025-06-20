//
//  InfiniteTableView.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 15.05.2025.
//

import SwiftUI

public enum InfiniteScrollDirection {
    case backward, forward
}

public enum InfiniteScrollLayout {
    case vertical, horizontal
}

public enum InfiniteScrollMode {
    case free, paged(CGFloat)
}

public class InfiniteTableViewCustomizationParams {
    var scrollLayout: InfiniteScrollLayout = .vertical
    var scrollMode: InfiniteScrollMode = .free
    var threshold: Int = 0
    var pageSize: Int = 5
    var updateID: UUID = UUID() // use to perform a full reload with re-centering
}

extension InfiniteTableView {
    func scrollLayout(_ layout: InfiniteScrollLayout) -> InfiniteTableView {
        self.params.scrollLayout = layout
        return self
    }

    func scrollMode(scrollMode: InfiniteScrollMode) -> InfiniteTableView {
        self.params.scrollMode = scrollMode
        return self
    }

    func loadMoreParameters(threshold: Int, pageSize: Int) -> InfiniteTableView {
        self.params.threshold = threshold
        self.params.pageSize = pageSize
        return self
    }

    func reloadTrigger(updateID: UUID) -> InfiniteTableView {
        self.params.updateID = updateID
        return self
    }
}

struct InfiniteTableView<Data, Content>: UIViewRepresentable where Data: Identifiable, Content: View {
    var data: [Data]
    var loadMore: ((InfiniteScrollDirection, Int) -> Void)?
    var willDisplayItem: (Data)->() = {_ in}
    @ViewBuilder var content: (Data) -> Content

    @State var prevUpdateID: UUID?
    @State var params = InfiniteTableViewCustomizationParams()

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
        if case let .paged(cellSize) = params.scrollMode {
            tableView.rowHeight = cellSize
            tableView.estimatedRowHeight = cellSize
        } else {
            tableView.rowHeight = UITableView.automaticDimension
        }
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.backgroundColor = .clear
        tableView.transform = CGAffineTransform(rotationAngle: (params.scrollLayout == .horizontal ? -.pi/2.0 : 0))
        return tableView
    }

    func updateUIView(_ uiView: UITableView, context: Context) {
        let oldData = context.coordinator.data
        let newData = data

        // completely new data, just reload the whole table and scroll to the middle
        print(prevUpdateID, params.updateID)
        if prevUpdateID != params.updateID {
            DispatchQueue.main.async {
                self.prevUpdateID = params.updateID
                context.coordinator.data = newData
                uiView.reloadData()
                uiView.scrollToRow(at: IndexPath(row: newData.count/2, section: 0), at: .middle, animated: false)
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

        private var isBusy = false
        private var pagedCellSize: CGFloat? {
            if case let .paged(size) = parent.params.scrollMode {
                return size
            }
            return nil
        }

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
                        .applyIfLet(pagedCellSize) { view, size in
                            view.frame(width: size)
                        }
                        .frame(maxHeight: .infinity)
                        .rotationEffect(Angle(radians: (parent.params.scrollLayout == .horizontal ? .pi/2.0 : 0)))
                }
                .margins(.all, 0)
                .background(.clear)
            }

            return cell
        }

        func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            guard !isBusy else { return }
            let count = data.count
            if indexPath.row >= count - parent.params.threshold - 1 {
                parent.loadMore?(.forward, parent.params.pageSize)
            } else if indexPath.row <= parent.params.threshold {
                parent.loadMore?(.backward, parent.params.pageSize)
            }
        }

        func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            guard case let .paged(cellSize) = parent.params.scrollMode else { return }
            isBusy = true
            let targetY = targetContentOffset.pointee.y

            // Compute the intended offset
            let remainder = targetY.truncatingRemainder(dividingBy: cellSize)
            let newOffsetY = remainder < cellSize/2 ? targetY - remainder : targetY - remainder + cellSize

            DispatchQueue.main.async {
                scrollView.setContentOffset(CGPoint(x: 0, y: newOffsetY), animated: true)
                self.isBusy = false

                let targetIndex = Int(newOffsetY/cellSize + 0.5)
                if let item = self.data[safe: targetIndex] {
                    self.parent.willDisplayItem(item)
                }
            }
        }
    }

    // can't move outside, because of Data generic
    func willDisplayItem(closure: @escaping (Data)->()) -> InfiniteTableView {
        var view = self
        view.willDisplayItem = closure
        return view
    }
}
