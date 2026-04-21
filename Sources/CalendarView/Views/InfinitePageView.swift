//
//  InfinitePageView.swift
//  CalendarView
//
//  Created by Exyte on 02.09.2025.
//

import SwiftUI

struct InfiniteTabPageView<Content: View>: View {
    @Binding var currentPage: Int
    @Binding var isDragging: Bool

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
        .gesture(dragGesture)
        .clipped()
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 5)
            .updating($translation) { value, state, _ in
                isDragging = true
                let translation = min(width, max(-width, value.translation.width))
                state = translation
            }
            .onEnded { value in
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
                    isDragging = false
                }
            }
    }

    private func pageView(index: Int) -> some View {
        content(determineGeneralPageIndex(index))
            .offset(x: determinePageOffset(index))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // Used to determine on which page each of the 3 content elements should be displayed.
    func determineGeneralPageIndex(_ index: Int) -> Int {
        let generalPageIndex = currentPage + 1 - index
        let periodicIndex = Int((CGFloat(generalPageIndex) / 3).rounded(.down)) // 0 0 0 1 1 1 2 2 2 ...
        let resultPeriodicIndex = periodicIndex * 3 // 0 0 0 3 3 3 6 6 6 ...
        return resultPeriodicIndex + index
    }

    // Used to determine the order of the three contents in a static state.
    func determinePageOffset(_ index: Int) -> CGFloat {
        var indexOffset: Int {
            if index == -1 { -1 }
            else if index == 0 { 1 }
            else { 0 }
        }

        let generalPageIndex = currentPage + indexOffset
        let periodicPagePlacement = (generalPageIndex % 3 + 3) % 3 // 0 1 2 0 1 2 0 1 2 ...
        let resultPeriodicPagePlacement = 1 - periodicPagePlacement
        return CGFloat(resultPeriodicPagePlacement) * width
    }
}
