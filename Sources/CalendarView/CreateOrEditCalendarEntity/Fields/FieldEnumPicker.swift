//
//  EventFieldType.swift
//  Jaye
//
//  Created by Exyte on 02.04.2025.
//

import SwiftUI

struct FieldEnumPicker<E: PickerEnum>: View {
    @Environment(\.calendarTheme) var theme
    @Binding var selection: E

    @State private var showSelectionPopup: Bool = false

    var body: some View {
        HStack {
            Text(E.title)
                .libraryFont(17, theme.main.secondaryText)

            Spacer()

            Text(selection.stringValue)
                .libraryFont(17, theme.main.secondaryText.opacity(0.6))

            Image(systemName: "chevron.right")
                .libraryFont(15, .semibold, theme.main.tertiaryText.opacity(0.3))
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
                .libraryFont(17, .semibold, theme.main.text)

            ForEach(E.allCases, id: \.self) { value in
                HStack {
                    Text(value.stringValue)
                        .libraryFont(17, theme.main.text)

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
