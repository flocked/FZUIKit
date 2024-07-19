//
//  NSAppearanceCustomization+.swift
//
//
//  Created by Florian Zand on 19.07.24.
//

#if os(macOS)
import AppKit

public extension NSAppearanceCustomization {
    /// Sets the appearance.
    @discardableResult
    func appearance(_ appearance: NSAppearance?) -> Self {
        self.appearance = appearance
        return self
    }
}

#endif
