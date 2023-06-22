//
//  SwiftUI Text+.swift
//  
//
//  Parts taken from: https://github.com/danielsaidi/SwiftUIKit
//  Copyright © 2020 Daniel Saidi. All rights reserved.

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

public extension Text {
    
    /**
     Force multiline rendering of a `Text` view where a text
     can become truncated even if there's space.
     */
    func forceMultiline() -> some View {
        self.fixedSize(horizontal: false, vertical: true)
    }
    
    /**
     Force single-line rendering of a `Text` view, where the
     text can become truncated even if there's space.
     */
    func forceSingleLine() -> some View {
        self.fixedSize(horizontal: true, vertical: false)
    }
}

@available(iOS 15.0, macOS 12.0, *)
public extension View {
    func textSelection(_ allowsSelection: Bool) -> some View {
        self.modifier(DynamicTextSelection(allowsSelection: allowsSelection))
    }
}
