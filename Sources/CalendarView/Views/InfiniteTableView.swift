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

public enum InfiniteScrollMode {
    case free(CGFloat? = nil)
    case paged(CGFloat)
}

public struct InfiniteTableViewCustomizationParams {
    var scrollMode: InfiniteScrollMode = .free()
    var isPagingEnabled: Bool = false
    var threshold: Int = 0
    var pageSize: Int = 1
    var updateID: UUID = UUID() // use to perform a full reload with re-centering
}

extension InfiniteTableView {
    func scrollMode(scrollMode: InfiniteScrollMode) -> InfiniteTableView {
        var copy = self
        copy.params.scrollMode = scrollMode
        return copy
    }

    func isPagingEnabled(_ isPagingEnabled: Bool) -> InfiniteTableView {
        var copy = self
        copy.params.isPagingEnabled = isPagingEnabled
        copy.params.pageSize = isPagingEnabled ? 1 : 5
        return copy
    }

    func loadMoreParameters(threshold: Int, pageSize: Int) -> InfiniteTableView {
        var copy = self
        copy.params.threshold = threshold
        copy.params.pageSize = pageSize
        return copy
    }

    func reloadTrigger(updateID: UUID) -> InfiniteTableView {
        var copy = self
        copy.params.updateID = updateID
        return copy
    }
}

public class EmptyUpdatable {}

public extension InfiniteTableView where UpdatableModel == EmptyUpdatable, UpdatableContent == EmptyView {

    init(data: Binding<[Data]>,
         loadMore: ((InfiniteScrollDirection, Int) -> Void)? = nil,
         willDisplayItem: ((Data)->Void)? = nil,
         content: @escaping (Data) -> Content
    ) {
        self._data = data
        self._cellModels = .constant([Data: EmptyUpdatable]())
        self.hasUpdatableModels = false
        self.loadMore = loadMore
        self.willDisplayItem = willDisplayItem
        self.content = content
        self.updatableContent = { _, _ in EmptyView() }
    }
}

public extension InfiniteTableView where Content == EmptyView {

    init(data: Binding<[Data]>,
         cellModels: Binding<[Data : UpdatableModel]>,
         loadMore: ((InfiniteScrollDirection, Int) -> Void)? = nil,
         willDisplayItem: ((Data)->Void)? = nil,
         content: @escaping (Data, UpdatableModel) -> UpdatableContent
    ) {
        self._data = data
        self._cellModels = cellModels
        self.hasUpdatableModels = true
        self.loadMore = loadMore
        self.willDisplayItem = willDisplayItem
        self.content = { _ in EmptyView() }
        self.updatableContent = content
    }
}

public struct InfiniteTableView<Data, UpdatableModel, Content, UpdatableContent>: UIViewRepresentable where Data: Identifiable, Data: Hashable, UpdatableModel: AnyObject, Content: View, UpdatableContent: View {
    /// use @Bindings to force swiftUI update flow on UIKit components
    @Binding var data: [Data]
    @Binding var cellModels: [Data: UpdatableModel]
    var hasUpdatableModels: Bool
    var loadMore: ((InfiniteScrollDirection, Int) -> Void)?
    var willDisplayItem: ((Data)->Void)?

    @ViewBuilder var content: (Data) -> Content
    @ViewBuilder var updatableContent: (Data, UpdatableModel) -> UpdatableContent

    var params = InfiniteTableViewCustomizationParams()
    var scrollDidChange: ((UIScrollView) -> Void)?

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public func makeUIView(context: Context) -> UITableView {
        let tableView = UITableView()
        tableView.dataSource = context.coordinator
        tableView.delegate = context.coordinator
        tableView.scrollsToTop = false
        tableView.isPagingEnabled = params.isPagingEnabled
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.backgroundColor = .clear
        return tableView
    }

    public func updateUIView(_ tableView: UITableView, context: Context) {
        context.coordinator.parent = self

        switch params.scrollMode {
        case let .free(cellSize):
            tableView.rowHeight = cellSize ?? UITableView.automaticDimension
            tableView.estimatedRowHeight = cellSize ?? UITableView.automaticDimension
        case let .paged(cellSize):
            tableView.rowHeight = cellSize
            tableView.estimatedRowHeight = cellSize
        }

        let oldData = context.coordinator.data
        let newData = data

        guard !newData.isEmpty else { return }

        // completely new data, just reload the whole table and scroll to the middle
        if context.coordinator.prevUpdateID != params.updateID {
            context.coordinator.prevUpdateID = params.updateID
            context.coordinator.data = newData
            context.coordinator.cellModels = cellModels

            reloadAndCenter(tableView, newData.count)
            return
        }

        if oldData.map(\.id) == newData.map(\.id) {
            return
        }

        context.coordinator.data = newData
        context.coordinator.cellModels = cellModels

        // Detect prepending
        var insertedCount = 0
        for (i, item) in newData.enumerated() {
            if i >= oldData.count || oldData.first?.id != item.id {
                insertedCount += 1
            } else {
                break
            }
        }

        if insertedCount > 0 {
            prependKeepingStable(tableView, insertedCount)
        } else {
            tableView.reloadData()
        }
    }

    func reloadAndCenter(_ tableView: UITableView, _ count: Int) {
        tableView.reloadData()
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()

        let middleIndex = count / 2
        if case let .paged(cellSize) = params.scrollMode {
            tableView.contentOffset = CGPoint(x: 0, y: CGFloat(middleIndex) * cellSize)
        } else {
            tableView.scrollToRow(at: IndexPath(row: middleIndex, section: 0), at: .top, animated: false)
        }
    }

    func prependKeepingStable(_ tableView: UITableView, _ insertedCount: Int) {
        if let firstVisibleIndex = tableView.indexPathsForVisibleRows?.first {
            let firstVisibleCellFrame = tableView.rectForRow(at: firstVisibleIndex)
            let currentOffsetY = tableView.contentOffset.y

            UIView.performWithoutAnimation {
                tableView.reloadData()
                tableView.setNeedsLayout()
                tableView.layoutIfNeeded()

                let updatedVisibleIndex = IndexPath(row: insertedCount + firstVisibleIndex.row, section: 0)
                let updatedVisibleCellFrame = tableView.rectForRow(at: updatedVisibleIndex)
                let deltaY = updatedVisibleCellFrame.minY - firstVisibleCellFrame.minY
                tableView.contentOffset.y = currentOffsetY + deltaY
            }
        }
    }

    public class Coordinator: NSObject, UITableViewDataSource, UITableViewDelegate {
        var data: [Data] = []
        var cellModels: [Data: UpdatableModel] = [:]
        var isUserScrolling = false
        var prevUpdateID: UUID?

        var parent: InfiniteTableView

        init(_ parent: InfiniteTableView) {
            self.parent = parent
        }

        public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            data.count
        }

        public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
            cell.selectionStyle = .none

            if let item = data[safe: indexPath.row] {
                cell.contentConfiguration = UIHostingConfiguration {
                    ZStack {
                        if parent.hasUpdatableModels, let model = parent.cellModels[item] {
                            parent.updatableContent(item, model)
                        } else {
                            parent.content(item)
                        }
                    }
                }
                .margins(.all, 0)
                .background(.clear)
            }

            return cell
        }

        public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            guard isUserScrolling else { return }
            if let item = self.data[safe: indexPath.row] {
                self.parent.willDisplayItem?(item)
            }
            let count = data.count
            let threshold = parent.params.threshold
            let pageSize = parent.params.pageSize
            let loadMore = parent.loadMore
            if indexPath.row >= count - threshold - 1 {
                DispatchQueue.main.async { loadMore?(.forward, pageSize) }
            } else if indexPath.row <= threshold {
                DispatchQueue.main.async { loadMore?(.backward, pageSize) }
            }
        }

        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            parent.scrollDidChange?(scrollView)
        }

        public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            isUserScrolling = true
        }

        public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            if !decelerate {
                isUserScrolling = false
            }
        }

        public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            isUserScrolling = false
        }

        public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
            isUserScrolling = false
        }

        public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            guard case let .paged(cellSize) = parent.params.scrollMode, !parent.params.isPagingEnabled else { return }
            let targetY = targetContentOffset.pointee.y

            // Compute the intended offset
            let remainder = targetY.truncatingRemainder(dividingBy: cellSize)
            let newOffsetY = remainder < cellSize/2 ? targetY - remainder : targetY - remainder + cellSize

            DispatchQueue.main.async {
                scrollView.setContentOffset(CGPoint(x: 0, y: newOffsetY), animated: true)

                let targetIndex = Int(newOffsetY/cellSize + 0.5)
                if let item = self.data[safe: targetIndex] {
                    self.parent.willDisplayItem?(item)
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

    func onScrollChange(_ closure: @escaping (UIScrollView) -> Void) -> InfiniteTableView {
        var copy = self
        copy.scrollDidChange = closure
        return copy
    }
}
