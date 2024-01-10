//
//  Text+.swift
//  
//
//  Parts taken from: https://github.com/danielsaidi/SwiftUIKit
//  Copyright © 2020 Daniel Saidi. All rights reserved.

import SwiftUI

public extension Text {
    /// Force multiline rendering where a text can become truncated even if there's space.
    func forceMultiline() -> some View {
        self.fixedSize(horizontal: false, vertical: true)
    }

    /// Force single-line rendering where the text can become truncated even if there's space.
    func forceSingleLine() -> some View {
        self.fixedSize(horizontal: true, vertical: false)
    }
}

#if os(macOS) || os(iOS)
@available(iOS 15.0, macOS 12.0, *)
public extension View {
    /// Controls whether text can be selected.
    func textSelection(_ allowsSelection: Bool) -> some View {
        self.modifier(DynamicTextSelection(allowsSelection: allowsSelection))
    }
}

@available(iOS 15.0, macOS 12.0, *)
/// A view mpdifier that controls whether text can be selected.
public struct DynamicTextSelection: ViewModifier {
    /// A Boolean value that indicates whether text can be selected.
    public let allowsSelection: Bool

    public func body(content: Content) -> some View {
        if allowsSelection {
            content.textSelection(.enabled)
        } else {
            content.textSelection(.disabled)
        }
    }
}
#endif
