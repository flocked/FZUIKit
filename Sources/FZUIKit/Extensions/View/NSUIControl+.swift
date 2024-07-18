//
//  NSUIControl+.swift
//
//
//  Created by Florian Zand on 18.07.24.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif
extension NSUIControl {
    /// Sets the Boolean value that indicates whether the receiver reacts to mouse events.
    @discardableResult
    public func isEnabled(_ isEnabled: Bool) -> Self {
        self.isEnabled = isEnabled
        return self
    }
    
    /// Sets the Boolean value that indicates whether the cell is highlighted.
    @discardableResult
    public func isHighlighted(_ isHighlighted: Bool) -> Self {
        self.isHighlighted = isHighlighted
        return self
    }
}

#endif
