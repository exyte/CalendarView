//
//  InfinitePageView.swift
//  CalendarView
//
//  Created by Exyte on 02.09.2025.
//

import SwiftUI

struct InfiniteTabPageView<Content: View>: View {
    @Binding var currentPage: Int
    @Binding var isDaySwiping: Bool

    var isCalendarScrolling: Bool
    let width: CGFloat

    let didEndAnimation: (_ direction: Int) -> ()
    let content: (_ page: Int) -> Content

    @State private var offset: CGFloat = .zero
    @GestureState private var translation: CGFloat = .zero

    private let animationDuration: CGFloat = 0.25

    var body: some View {
        ZStack {
            pageView(index: -1)
            pageView(index: 0)
            pageView(index: 1)
        }
        .offset(x: translation + offset)
        .contentShape(Rectangle())
        .simultaneousGesture(dragGesture)
        .clipped()
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 100)
            .updating($translation) { value, state, _ in
                let translation = min(width, max(-width, value.translation.width))
                if isCalendarScrolling { return }
                isDaySwiping = true
                state = translation
            }
            .onEnded { value in
                if isCalendarScrolling { return }
                offset = min(width, max(-width, value.translation.width))
                let predictEndOffset = value.predictedEndTranslation.width
                withAnimation(.easeOut(duration: animationDuration)) {
                    if offset < -width / 2 || predictEndOffset < -width {
                        offset = -width
                    } else if offset > width / 2 || predictEndOffset > width {
                        offset = width
                    } else {
                        offset = 0
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                    if offset < 0 {
                        currentPage += 1
                        didEndAnimation(1)
                    } else if offset > 0 {
                        currentPage -= 1
                        didEndAnimation(-1)
                    }
                    offset = 0
                    isDaySwiping = false
                }
            }
    }

    private func pageView(index: Int) -> some View {
        content(determineGeneralPageIndex(index))
            .offset(x: determinePageOffset(index))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // Periodic function to determine on which general page each of the 3 content elements should be displayed.
    func determineGeneralPageIndex(_ index: Int) -> Int {
        let generalPageIndex = currentPage + 1 - index // Calculate the global page index for content element
        let periodicIndex = Int((CGFloat(generalPageIndex) / 3).rounded(.down)) // 0 0 0 1 1 1 2 2 2 ...
        let resultPeriodicIndex = periodicIndex * 3 // 0 0 0 3 3 3 6 6 6 ...
        return resultPeriodicIndex + index
    }

    // Periodic function to determine the order of the three contents in a static state.
    func determinePageOffset(_ index: Int) -> CGFloat {
        var indexOffset: Int {
            if index == -1 { -1 }
            else if index == 0 { 1 }
            else { 0 }
        }

        let generalPageIndex = currentPage + indexOffset // Calculate the global page index for content element
        let periodicPagePlacement = (generalPageIndex % 3 + 3) % 3 // 0 1 2 0 1 2 0 1 2 ...
        let resultPeriodicPagePlacement = 1 - periodicPagePlacement // -1 0 1 -1 0 1 -1 0 1 ...
        return CGFloat(resultPeriodicPagePlacement) * width
    }
}
