//
//  DefaultHeaderView.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 29.04.2025.
//

import SwiftUI
import AnchoredPopup

public struct DefaultHeaderView: View {
    @Binding var selectedDate: Date
    @Binding var displayMode: CalendarDisplayMode

    public init(selectedDate: Binding<Date>, displayMode: Binding<CalendarDisplayMode>) {
        self._selectedDate = selectedDate
        self._displayMode = displayMode
    }

    public var body: some View {
        HStack {
            ZStack {
                switch displayMode {
                case .day:
                    Image(.day)
                case .threeDays:
                    Image(.three)
                case .month:
                    Image(.month)
                }
            }
            .padding(5)
            .background(Circle().foregroundStyle(.white.opacity(0.2)))
            .useAsPopupAnchor(id: "displayMode") {
                VStack(alignment: .leading) {
                    makeButton("Month", .month, .month)
                    makeButton("Day", .day, .day)
                    makeButton("3 Day", .three, .threeDays)
                }
                .padding(18, 10)
                .background(styledRoundedRectangle(20, .white))
            } customize: {
                $0.position(.anchorRelative(.topLeading))
                    .background(.none)
            }

            Spacer()

            DatePicker(
                "Start Date",
                selection: $selectedDate,
                displayedComponents: [.date]
            )
            //Text(selectedDate.formatted("MMMM, yyyy"))

            Spacer()

            Button {

            } label: {
                Image(.filters)
            }
            .padding(5)
            .background(Circle().foregroundStyle(.white.opacity(0.2)))
        }
        .padding(10)
        .background(Color.green.opacity(0.5))
    }

    func makeButton(_ title: String, _ image: ImageResource, _ mode: CalendarDisplayMode) -> some View {
        Button {
            displayMode = mode
        } label: {
            HStack {
                Image(image).renderingMode(.template)
                Text(title)
            }
        }
        .foregroundStyle(displayMode == mode ? Color("appBlack", bundle: .module) : Color("appGrey", bundle: .module))
    }
}
