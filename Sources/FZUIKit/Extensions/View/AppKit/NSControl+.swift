//
//  NSControl+.swift
//
//
//  Created by Florian Zand on 04.03.24.
//

#if os(macOS)
import AppKit

extension NSControl {
    /// Sets the font.
    @discardableResult
    public func font(_ font: NSFont?) -> Self {
        self.font = font
        return self
    }
    
    /// Sets the integer value.
    @discardableResult
    public func integerValue(_ value: Int) -> Self {
        integerValue = value
        return self
    }
    
    /// Sets the double value.
    @discardableResult
    public func doubleValue(_ value: Double) -> Self {
        doubleValue = value
        return self
    }
    
    /// Sets the string value.
    @discardableResult
    public func stringValue(_ string: String) -> Self {
        stringValue = string
        return self
    }
    
    /// Sets the attributed string value.
    @discardableResult
    public func attributedStringValue(_ string: NSAttributedString) -> Self {
        attributedStringValue = string
        return self
    }
    
    /// Sets the attributed string value.
    @available(macOS 12, *)
    @discardableResult
    public func attributedStringValue(_ string: AttributedString) -> Self {
        attributedStringValue = NSAttributedString(string)
        return self
    }
    
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
    
    /// Sets the tag identifying the receiver (not the tag of the receiver’s cell).
    @discardableResult
    public func tag(_ tag: Int) -> Self {
        self.tag = tag
        return self
    }
    
    /// Sets the size of the control.
    @discardableResult
    public func controlSize(_ size: ControlSize) -> Self {
        controlSize = size
        return self
    }
    
    /// Sets the text alignment.
    @discardableResult
    public func alignment(_ alignment: NSTextAlignment) -> Self {
        self.alignment = alignment
        return self
    }
    
    /// Sets the line break mode to use for text in the control’s cell.
    @discardableResult
    public func lineBreakMode(_ mode: NSLineBreakMode) -> Self {
        self.lineBreakMode = mode
        return self
    }
    
    /// Sets the Boolean value that indicates whether the text in the control’s cell uses single line mode.
    @discardableResult
    public func usesSingleLineMode(_ usesSingleLineMode: Bool) -> Self {
        self.usesSingleLineMode = usesSingleLineMode
        return self
    }
        
    /// Sets the formatter.
    @discardableResult
    public func formatter(_ formatter: Formatter?) -> Self {
        self.formatter = formatter
        return self
    }
}

#endif
