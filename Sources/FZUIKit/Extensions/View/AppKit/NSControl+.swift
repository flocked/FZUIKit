//
//  NSControl+.swift
//
//
//  Created by Florian Zand on 04.03.24.
//

#if os(macOS)
import AppKit

extension NSControl {
        
    /// Sets the Boolean value indicating whether the receiver’s cell sends its action message continuously to its target during mouse tracking.
    @discardableResult
    public func isContinuous(_ isContinuous: Bool) -> Self {
        self.isContinuous = isContinuous
        return self
    }
    
    /// Sets the Boolean value indicating whether the receiver ignores multiple clicks made in rapid succession.
    @discardableResult
    public func ignoresMultiClick(_ ignores: Bool) -> Self {
        self.ignoresMultiClick = ignores
        return self
    }
    
    /// Sets the Boolean value indicating whether the receiver refuses the first responder role.
    @discardableResult
    public func refusesFirstResponder(_ refuses: Bool) -> Self {
        self.refusesFirstResponder = refuses
        return self
    }
    
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
    
    /// Sets the Boolean value indicating whether the text in the control’s cell uses single line mode.
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
    
    /// Dragging image componentss for drag and drop support.
    public var draggingImageComponents: [NSDraggingImageComponent] {
        cell?.draggingImageComponents(withFrame: bounds, in: self) ?? []
    }
}

extension NSControl.StateValue: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = value ? .on : .off
    }    
}

#endif
