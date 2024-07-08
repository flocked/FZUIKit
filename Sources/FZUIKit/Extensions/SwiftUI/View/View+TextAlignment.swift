//
//  View+TextAlignment.swift
//
//
//  Created by Florian Zand on 06.10.22.
//

import SwiftUI
import AppKit

public extension View {
    /**
     Sets the alignment of a text view.

     - Parameters:
        - textAlignment: The alignment of the text.
        - autoWidth: A Boolean value that indicates whether the text should fit its width automatically.
     */
    func textAlignment(_ textAlignment: TextAlignment, autoWidth: Bool = true) -> some View {
        modifier(TextAlignmentModifier(textAlignment: textAlignment, autoWidth: autoWidth))
    }
    
    /**
     Sets the alignment of a text.

     - Parameter textAlignment: The alignment of the text.
     */
    func textAlignment(_ textAlignment: NSTextAlignment) -> some View {
        self.frame(alignment: textAlignment.swiftUI)
            .multilineTextAlignment(textAlignment.swiftUIMultiline)
    }
}

struct TextAlignmentModifier: ViewModifier {
    let textAlignment: TextAlignment
    let autoWidth: Bool

    init(textAlignment: TextAlignment, autoWidth: Bool = true) {
        self.textAlignment = textAlignment
        self.autoWidth = autoWidth
    }

    @ViewBuilder
    func body(content: Content) -> some View {
        content
            .multilineTextAlignment(textAlignment)
            .frame(maxWidth: autoWidth ? CGFloat.infinity : nil, alignment: textAlignment.alignment)
    }
}

extension TextAlignment {
    var alignment: Alignment {
        switch self {
        case .leading: return .leading
        case .center: return .center
        case .trailing: return .trailing
        }
    }
}
