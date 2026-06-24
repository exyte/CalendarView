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
    case free(CGFloat? = nil), paged(CGFloat)
}

public struct InfiniteTableViewCustomizationParams {
    var scrollLayout: InfiniteScrollLayout = .vertical
    var scrollMode: InfiniteScrollMode = .free()
    var isPagingEnabled: Bool = false
    var threshold: Int = 0
    var pageSize: Int = 1
    var updateID: UUID = UUID() // use to perform a full reload with re-centering
}

extension InfiniteTableView {
    func scrollLayout(_ layout: InfiniteScrollLayout) -> InfiniteTableView {
        var copy = self
        copy.params.scrollLayout = layout
        return copy
    }

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

    @State private var prevUpdateID: UUID?
    var params = InfiniteTableViewCustomizationParams()

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
        if case let .paged(cellSize) = params.scrollMode {
            tableView.rowHeight = cellSize
            tableView.estimatedRowHeight = cellSize
        } else if case let .free(cellSize) = params.scrollMode {
            tableView.rowHeight = cellSize ?? UITableView.automaticDimension
            tableView.estimatedRowHeight = cellSize ?? UITableView.automaticDimension
        }
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.backgroundColor = .clear
        tableView.transform = CGAffineTransform(rotationAngle: (params.scrollLayout == .horizontal ? -.pi/2.0 : 0))
        return tableView
    }

    public func updateUIView(_ uiView: UITableView, context: Context) {
        let oldData = context.coordinator.data
        let newData = data

        guard !newData.isEmpty else { return }

        // completely new data, just reload the whole table and scroll to the middle
        if prevUpdateID != params.updateID {
            DispatchQueue.main.async {
                self.prevUpdateID = params.updateID
                context.coordinator.data = newData
                context.coordinator.cellModels = cellModels
                uiView.reloadData()
                uiView.scrollToRow(at: IndexPath(row: newData.count/2, section: 0), at: .middle, animated: false)
            }
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

        if insertedCount > 0, let firstVisibleIndex = uiView.indexPathsForVisibleRows?.first {
            let firstVisibleCellFrame = uiView.rectForRow(at: firstVisibleIndex)
            let currentOffsetY = uiView.contentOffset.y

            UIView.performWithoutAnimation {
                DispatchQueue.main.async {
                    context.coordinator.isBusy = true
                    uiView.reloadData()
                    uiView.setNeedsLayout()
                    uiView.layoutIfNeeded()

                    let updatedVisibleIndex = IndexPath(row: insertedCount + firstVisibleIndex.row, section: 0)
                    let updatedVisibleCellFrame = uiView.rectForRow(at: updatedVisibleIndex)
                    let deltaY = updatedVisibleCellFrame.minY - firstVisibleCellFrame.minY
                    uiView.contentOffset.y = currentOffsetY + deltaY
                    context.coordinator.isBusy = false
                }
            }
        } else {
            uiView.reloadData()
        }
    }

    public class Coordinator: NSObject, UITableViewDataSource, UITableViewDelegate {
        var data: [Data] = []
        var cellModels: [Data: UpdatableModel] = [:]
        var isBusy = false

        private var parent: InfiniteTableView

        private var pagedCellSize: CGFloat? {
            if case let .paged(size) = parent.params.scrollMode {
                return size
            }
            if case let .free(size) = parent.params.scrollMode {
                return size
            }
            return nil
        }

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
                    Group {
                        if parent.hasUpdatableModels, let model = parent.cellModels[item] {
                            parent.updatableContent(item, model)
                        } else {
                            parent.content(item)
                        }
                    }
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

        public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            guard !isBusy else { return }
            if let item = self.data[safe: indexPath.row] {
                self.parent.willDisplayItem?(item)
            }
            let count = data.count
            if indexPath.row >= count - parent.params.threshold - 1 {
                parent.loadMore?(.forward, parent.params.pageSize)
            } else if indexPath.row <= parent.params.threshold {
                parent.loadMore?(.backward, parent.params.pageSize)
            }
        }

        public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            guard case let .paged(cellSize) = parent.params.scrollMode, !parent.params.isPagingEnabled else { return }
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
}
