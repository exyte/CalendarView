//
//  EventFieldView.swift
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
            //.sfProText(.regular, 17)

            Spacer()

            Text(currentValue.stringValue)
                .border(Color.red, width: 2)
            //.sfProText(.regular, 17, .cadet)

            Image(systemName: "arrow.right")
                .frame(width: 24, height: 24)
                .border(Color.blue, width: 2)
        }
        .onTapGesture {
            showSelectionPopup = true
        }
        .popup(isPresented: $showSelectionPopup) {
            SelectionPopupView(selection: $currentValue)
        } customize: {
            $0
                .type(.scroll(headerView: AnyView(PopupHeaderView())))
                .displayMode(.sheet)
                .closeOnTap(false)
                .closeOnTapOutside(true)
                .dragToDismiss(true)
                .position(.bottom)
                .backgroundColor(.black.opacity(0.5))
        }
    }
}
