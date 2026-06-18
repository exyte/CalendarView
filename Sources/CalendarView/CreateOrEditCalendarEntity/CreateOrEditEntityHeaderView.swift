//
//  CreateOrEditEntityHeaderView.swift
//  CalendarView
//
//  Created by Exyte on 03.06.2026.
//

import SwiftUI

struct CreateOrEditEntityHeaderView: View {
    @Environment(\.calendarTheme) private var theme
    @Environment(\.dismiss) private var dismiss

    var title: String
    var saveButtonEnabled: Bool = true
    var onSave: () async -> ()

    var body: some View {
        ZStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(.cross)
                }
                .frame(width: 44, height: 44)
                .background(Circle().styled(theme.button.background))

                Spacer()

                Button {
                    Task {
                        await onSave()
                        dismiss()
                    }
                } label: {
                    Image(.checkmark)
                        .resizable()
                        .frame(width: 14, height: 12)
                }
                .frame(width: 44, height: 44)
                .background(Circle().styled(saveButtonEnabled ? theme.button.accent : theme.button.disabled))
                .disabled(!saveButtonEnabled)
            }

            Text(title)
                .systemFont(17, .semibold, theme.main.text)
        }
        .padding(16)
        .overlay {
            VStack {
                Capsule()
                    .frame(width: 36, height: 5)
                    .foregroundStyle(theme.main.secondaryText)
                    .padding(.top, 5)

                Spacer()
            }
        }
    }
}
