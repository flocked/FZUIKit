//
//  EditableText.swift
//
//
//  Created by Florian Zand on 07.06.23.
//

import SwiftUI


@available(macOS 15.0, iOS 13.0, tvOS 16.0, visionOS 1.0, *)
public struct EditableText: View {
    @Binding private var text: String
    @State private var draftText: String = ""
    @State private var isEditing = false

    private let onEditEnd: (String) -> Void
    private let alignment: Alignment

    private var multilineTextAlignment: TextAlignment {
        switch alignment {
        case .leading: return .leading
        case .center: return .center
        case .trailing: return .trailing
        default: return .leading
        }
    }

    public init(
        _ text: Binding<String>,
        alignment: Alignment = .leading,
        onEditEnd: @escaping (String) -> Void
    ) {
        self._text = text
        self.alignment = alignment
        self.onEditEnd = onEditEnd
    }

    public var body: some View {
        ZStack(alignment: alignment) {
            Text(text)
                .multilineTextAlignment(multilineTextAlignment)
                .opacity(isEditing ? 0 : 1)

            TextField(
                "",
                text: $draftText,
                onEditingChanged: { _ in },
                onCommit: commitEdit
            )
            .textFieldStyle(.plain)
            .multilineTextAlignment(multilineTextAlignment)
            .opacity(isEditing ? 1 : 0)
        }
        .onTapGesture(count: 2) {
            beginEdit()
        }
        #if os(macOS)
        .onExitCommand {
            cancelEdit()
        }
        #endif
    }

    private func beginEdit() {
        draftText = text
        isEditing = true
    }

    private func commitEdit() {
        text = draftText
        isEditing = false
        onEditEnd(text)
    }

    private func cancelEdit() {
        draftText = text
        isEditing = false
    }
}
