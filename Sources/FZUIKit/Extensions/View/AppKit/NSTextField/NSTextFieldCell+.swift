//
//  NSTextFieldCell+.swift
//
//
//  Created by Florian Zand on 17.03.24.
//

#if os(macOS)
import AppKit

extension NSTextFieldCell {
    /// The text field associated with the cell.
    public var textField: NSTextField? {
        controlView as? NSTextField
    }
}

#endif
