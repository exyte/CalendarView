//
//  EventFieldType.swift
//  Jaye
//
//  Created by Exyte on 02.04.2025.
//

import SwiftUI

struct FieldEnumPicker<E: PickerEnum>: View {
    @Binding var selection: E

    @State private var showSelectionPopup: Bool = false
    
    var body: some View {
        HStack {
            Text(E.title)
                .systemFont(17, .appBlack2)

            Spacer()

            Text(selection.stringValue)
                .systemFont(17, .appBlack2, 0.6)

            Image(systemName: "chevron.right")
                .systemFont(15, .semibold, .appBlack3, 0.3)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            showSelectionPopup = true
        }
        .sheet(isPresented: $showSelectionPopup) {
            SelectionPopupView(selection: $selection)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
}

struct SelectionPopupView<E: PickerEnum>: View {
    @Environment(\.calendarTheme) var theme
    @Environment(\.dismiss) var dismiss

    @Binding var selection: E

    var body: some View {
        VStack(spacing: 20) {
            Text(E.title)
                .systemFont(17, .semibold, theme.main.text)

            ForEach(E.allCases, id: \.self) { value in
                HStack {
                    Text(value.stringValue)

                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selection = value
                    dismiss()
                }
            }

            Spacer()
        }
        .padding(20, 30)
    }
}
