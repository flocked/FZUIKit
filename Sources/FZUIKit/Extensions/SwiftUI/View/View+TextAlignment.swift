//
//  View+TextAlignment.swift
//
//
//  Created by Florian Zand on 06.10.22.
//

import SwiftUI

public extension View {
    /**
     Sets the alignment of a text.

     - Parameters:
        - textAlignment: The alignment of the text.
        - autoWidth: A Boolean value indicating whether the text should fit its width automatically.
     */
    func textAlignment(_ textAlignment: TextAlignment, autoWidth: Bool = true) -> some View {
        multilineTextAlignment(textAlignment)
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
    
    var nsTextAlignment: NSTextAlignment {
        switch self {
        case .leading: return .left
        case .center: return .center
        case .trailing: return .right
        }
    }
}
