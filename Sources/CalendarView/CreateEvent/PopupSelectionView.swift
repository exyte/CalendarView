//
//  SelectionPopupView.swift
//  Jaye
//
//  Created by Exyte on 04.06.2025.
//

import SwiftUI
import PopupView

struct SelectionPopupView<Selection: PickerEnum>: View {
    @Environment(\.popupDismiss) var dismiss

    @Binding var selection: Selection
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 12)
            
            Text(selection.title)
                .padding(.bottom, 20)
            
            ForEach(Selection.allCases, id: \.self) { value in
                HStack {
                    Text(value.stringValue)

                    Spacer()
                    
                    Image(value == selection ? .checkboxRadioFill : .checkboxRadioEmpty)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(Color.blue.opacity(0.3))
                        .frame(width: 24, height: 24)
                }
                .padding(.bottom, 20)
                .onTapGesture {
                    selection = value
                    dismiss?()
                }
            }
            
            Spacer()
                .frame(height: 30)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .background(.white)
    }
}
