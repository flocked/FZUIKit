//
//  View+TextAlignment.swift
//
//
//  Created by Florian Zand on 06.10.22.
//

import SwiftUI

public extension View {
    @ViewBuilder
    func textAlignment(_ textAlignment: TextAlignment, autoWidth: Bool = true) -> some View {
        modifier(TextAlignmentModifier(textAlignment: textAlignment, autoWidth: autoWidth))
    }
}

internal struct TextAlignmentModifier: ViewModifier {
    private let textAlignment: TextAlignment
    private let autoWidth: Bool

    internal init(textAlignment: TextAlignment, autoWidth: Bool = true) {
        self.textAlignment = textAlignment
        self.autoWidth = autoWidth
    }

    @ViewBuilder
    internal func body(content: Content) -> some View {
        switch textAlignment {
        case .leading:
            content
                .multilineTextAlignment(textAlignment)
                .frame(maxWidth: autoWidth ? CGFloat.infinity : nil, alignment: .leading)
        case .center:
            content
                .multilineTextAlignment(textAlignment)
                .frame(maxWidth: autoWidth ? CGFloat.infinity : nil, alignment: .center)
        case .trailing:
            content
                .multilineTextAlignment(textAlignment)
                .frame(maxWidth: autoWidth ? CGFloat.infinity : nil, alignment: .trailing)
        }
    }
}
