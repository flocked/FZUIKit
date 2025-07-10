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
    
    #if canImport(UIKit)
    /// Sets the Boolean value indicating whether the control is in the selected state.
    @discardableResult
    public func isSelected(_ isSelected: Bool) -> Self {
        self.isSelected = isSelected
        return self
    }
    
    /// Sets the vertical alignment of content within the control’s bounds.
    @discardableResult
    public func contentVerticalAlignment(_ alignment: UIControl.ContentVerticalAlignment) -> Self {
        self.contentVerticalAlignment = alignment
        return self
    }
    
    /// Sets the horizontal alignment of content within the control’s bounds.
    @discardableResult
    public func contentHorizontalAlignment(_ alignment: UIControl.ContentHorizontalAlignment) -> Self {
        self.contentHorizontalAlignment = alignment
        return self
    }
    
    /// Sets the Boolean value that determines whether the context menu interaction is the control’s primary action.
    @discardableResult
    public func showsMenuAsPrimaryAction(_ shows: Bool) -> Self {
        showsMenuAsPrimaryAction = shows
        return self
    }
    
    /// Sets the default text to display in the control’s tooltip.
    @available(iOS 15.0, *)
    @discardableResult
    public func toolTip(_ toolTip: String?) -> Self {
        self.toolTip = toolTip
        return self
    }
    #endif
}

#endif
