//
//  DescriptionFieldView.swift
//  Jaye
//
//  Created by Exyte on 02.04.2025.
//

import SwiftUI

struct FieldDescription: View {
    @Binding var description: String
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
//                Image(.description)
//                    .frame(width: 24, height: 24)
                
                Text("Description")
                   // .sfProText(.regular, 17)

                Spacer()
            }
            
            TextField("", text: $description, prompt: Text("Type here..."), axis: .vertical)
                //.sfProText(.regular, 15)
                .focused($isFocused)
                .submitLabel(.done)
                .onChange(of: description) {
                    if description.last?.isNewline == true {
                        description.removeLast()
                        isFocused = false
                    }
                }
                .padding(.top, 8)
        }
    }
}
