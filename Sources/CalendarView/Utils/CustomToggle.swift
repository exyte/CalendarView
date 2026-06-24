//
//  CustomToggle.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 24.06.2026.
//

import SwiftUI

struct CustomToggle: View {
    @Binding var isOn: Bool

    var onColor: Color
    var offColor: Color
    var thumbColor: Color = .white

    var body: some View {
        Button {
            withAnimation(.snappy(duration: 0.2)) {
                isOn.toggle()
            }
        } label: {
            Capsule()
                .fill(isOn ? onColor : offColor)
                .frame(width: 64, height: 28)
                .overlay(alignment: isOn ? .trailing : .leading) {
                    Capsule()
                        .fill(thumbColor)
                        .frame(width: 39, height: 24)
                        .padding(2)
                }
        }
        .buttonStyle(.plain)
    }
}
