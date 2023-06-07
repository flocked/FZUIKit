//
//  EditableLabel.swift
//  
//
//  Created by Florian Zand on 07.06.23.
//

import SwiftUI

public struct EditableLabel: View {
    @Binding var text: String
    @State private var newValue: String = ""
    
    @State var editProcessGoing = false { didSet{ newValue = text } }
    
    let onEditEnd: (String) -> Void

    
    public init(_ txt: Binding<String>, onEditEnd: @escaping (String) -> Void) {
        _text = txt
        self.onEditEnd = onEditEnd
    }
    
    @ViewBuilder
    public var body: some View {
        ZStack {
            // Text variation of View
            Text(text)
                .opacity(editProcessGoing ? 0 : 1)
            
            // TextField for edit mode of View
            TextField("", text: $newValue,
                          onEditingChanged: { _ in },
                          onCommit: { text = newValue; editProcessGoing = false; onEditEnd(text) } )
                .opacity(editProcessGoing ? 1 : 0)
        }
        // Enable EditMode on double tap
        .onTapGesture(count: 2, perform: { editProcessGoing = true } )
        // Exit from EditMode on Esc key press
        .onExitCommand(perform: { editProcessGoing = false; newValue = text })
    }
}
