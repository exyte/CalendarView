//
//  EventFieldType.swift
//  Jaye
//
//  Created by Exyte on 02.04.2025.
//

import SwiftUI
import PopupView

enum EventFieldType: String, CaseIterable {
    
    case repeatField = "Repeat"
    case alertField = "Alert"
    case jayeBlockField = "Jaye Block"
    case vibrationTypeField = "Vibration type"
    case priority = "Priority"
    
    var iconName: String {
        switch self {
        case .repeatField:
            return "repeat"
        case .alertField:
            return "alert"
        case .jayeBlockField:
            return "jaye_block"
        case .vibrationTypeField:
            return "vibration"
        case .priority:
            return "priority"
        }
    }
}

struct FieldEnumPicker<S: PickerEnum>: View {
    var eventFieldType: EventFieldType
    @Binding var currentValue: S
    
    @State var showSelectionPopup: Bool = false
    
    var body: some View {
        HStack {
            Text(eventFieldType.rawValue)

            Spacer()

            Text(currentValue.stringValue)
                .systemFont(17, .regular, Color.named("appGrey"))

            Image(.rightArrow)
                .frame(width: 24, height: 24)
                .foregroundStyle(Color.named("appLightGrey"))
        }
        .contentShape(Rectangle())
        .onTapGesture {
            showSelectionPopup = true
        }
        .scrollPopup(isPresented: $showSelectionPopup) {
            SelectionPopupView(selection: $currentValue)
        } header: {
            PopupHeaderView()
        } customize: {
            $0
                .closeOnTap(false)
                .closeOnTapOutside(true)
                .dragToDismiss(true)
                .backgroundColor(.black.opacity(0.5))
        }
    }
}
