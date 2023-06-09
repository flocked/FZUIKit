//
//  File.swift
//  
//
//  Created by Florian Zand on 09.06.23.
//

import SwiftUI

@available(iOS 15.0, macOS 12.0, *)
public struct DynamicTextSelection: ViewModifier {
    public var allowsSelection: Bool

    public func body(content: Content) -> some View {
        if allowsSelection {
            content.textSelection(.enabled)
        } else {
            content.textSelection(.disabled)
        }
    }
}

@available(iOS 15.0, macOS 12.0, *)
public extension View {
    func textSelection(_ allowsSelection: Bool) -> some View {
        self.modifier(DynamicTextSelection(allowsSelection: allowsSelection))
    }
}
