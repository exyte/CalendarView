//
//  CreateOrEditEventHeaderView.swift
//  CalendarView
//
//  Created by Exyte on 03.06.2026.
//

import SwiftUI

struct CreateOrEditEventHeaderView: View {
    @Environment(\.calendarTheme) private var theme
    @Environment(\.dismiss) private var dismiss

    @Binding var rightButtonEnabled: Bool

    var title: String
    var onDismiss: () async -> ()

    init(rightButtonEnabled: Binding<Bool>? = nil, title: String, onDismiss: @escaping () async -> () = {}) {
        self._rightButtonEnabled = rightButtonEnabled ?? .constant(true)
        self.title = title
        self.onDismiss = onDismiss
    }

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
                        await onDismiss()
                        dismiss()
                    }
                } label: {
                    Image(.checkmark)
                        .resizable()
                        .frame(width: 14, height: 12)
                }
                .frame(width: 44, height: 44)
                .background(Circle().styled(rightButtonEnabled ? theme.button.accent : theme.button.disabled))
                .disabled(!rightButtonEnabled)
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
