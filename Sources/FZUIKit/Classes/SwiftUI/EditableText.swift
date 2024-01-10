//
//  EditableText.swift
//
//
//  Created by Florian Zand on 07.06.23.
//

import SwiftUI

@available(macOS 15.0, iOS 13.0, tvOS 16.0, *)
public struct EditableText: View {
    @Binding var text: String
    @State private var newValue: String = ""

    @State var editProcessGoing = false { didSet { newValue = text } }

    let onEditEnd: (String) -> Void
    let alignment: Alignment

    var multilineTextAlignment: TextAlignment {
        switch alignment {
        case .leading: return .leading
        case .center: return .center
        case .trailing: return .trailing
        default: return .leading
        }
    }

    public init(_ txt: Binding<String>, alignment: Alignment = .leading, onEditEnd: @escaping (String) -> Void) {
        _text = txt
        self.onEditEnd = onEditEnd
        self.alignment = alignment
    }

    @ViewBuilder
    public var body: some View {
        ZStack(alignment: alignment) {
            Text(text)
                .multilineTextAlignment(multilineTextAlignment)
                .opacity(editProcessGoing ? 0 : 1)

            TextField("", text: $newValue,
                      onEditingChanged: { _ in },
                      onCommit: { text = newValue; editProcessGoing = false; onEditEnd(text) })
                .textFieldStyle(.plain)
                .multilineTextAlignment(multilineTextAlignment)
                .opacity(editProcessGoing ? 1 : 0)
        }
        .onTapGesture(count: 2, perform: { editProcessGoing = true })
        #if os(macOS)
            .onExitCommand(perform: { editProcessGoing = false; newValue = text })
        #endif
    }
}
