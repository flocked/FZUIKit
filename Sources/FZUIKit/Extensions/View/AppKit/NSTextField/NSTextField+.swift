//
//  NSTextField+.swift
//
//
//  Created by Florian Zand on 03.09.22.
//

#if os(macOS)

import AppKit
import FZSwiftUtils

public extension NSTextField {
    /**
     Initializes a text field that automatically resizes to fit it's string value.
         
     - Parameter stringValue: A string to use as the content of the label.
         
     - Returns: An initialized `NSTextField`.
     */
    convenience init(resizingLabel stringValue: String) {
        self.init(labelWithString: stringValue)
        self.automaticallyResizesToFit = true
        self.backgroundColor = nil
        self.focusType = .roundedCorners(4.0)
        self.isVerticallyCentered = true
        self.stringValue = stringValue
        self.resizeToFit()
    }
        
    /**
     Creates a text field for use as a label.
         
     - Parameter string: The string value of the text field.
     */
    static func label(_ stringValue: String = "") -> NSTextField {
        NSTextField(labelWithString: stringValue).backgroundColor(nil)
    }
        
    /**
     Creates a wrapping text field for use as a multiline label.
         
     - Parameter string: The string value of the text field.
     */
    static func wrapping(_ stringValue: String = "") -> Self {
        Self(wrappingLabelWithString: stringValue)
            .isSelectable(false)
            .isEditable(false)
    }
        
    /**
     Creates a bordered and bezeled editing text field.
         
     - Parameters:
        - string: The string value of the text field.
        - placeholder: The place holder of the text field.
        - rounded: A Boolean value indicating whether the text field's bezel is rounded.
     */
    static func editing(_ string: String = "", placeholder: String? = nil, rounded: Bool = false) -> Self {
        Self(string: string)
            .isBordered(true)
            .placeholder(placeholder)
            .bezelStyle(rounded ? .roundedBezel : .squareBezel)
    }
        
    /**
     Creates a text field that automatically resizes to fit it's string value.
         
     - Parameter string: The string value of the text field.
     */
    static func resizing(_ stringValue: String = "") -> Self {
        let textField = Self(labelWithString: stringValue)
        textField.automaticallyResizesToFit = true
        textField.backgroundColor = nil
        textField.focusType = .roundedCorners(4.0)
        textField.isVerticallyCentered = true
        textField.stringValue = stringValue
        textField.resizeToFit()
        return textField
    }
        
    /// The text field’s number formatter.
    var numberFormatter: NumberFormatter? {
        get { formatter as? NumberFormatter }
        set {
            if let newValue = newValue {
                formatter = newValue
            } else if formatter is NumberFormatter {
                formatter = nil
            }
        }
    }
        
    /// Sets the text field’s number formatter.
    @discardableResult
    func numberFormatter(_ formatter: NumberFormatter?) -> Self {
        numberFormatter = formatter
        return self
    }
        
    /// Sets the string the text field displays when empty to help the user understand the text field’s purpose.
    @discardableResult
    func placeholder(_ placeholder: String?) -> Self {
        placeholderString = placeholder
        return self
    }
        
    /// Sets attributed string the text field displays when empty to help the user understand the text field’s purpose.
    @discardableResult
    func placeholderAttributed(_ placeholder: NSAttributedString?) -> Self {
        placeholderAttributedString = placeholder
        return self
    }
        
    /// Sets the Boolean value that controls whether the text field’s cell draws a background color behind the text.
    @discardableResult
    func drawsBackground(_ draws: Bool) -> Self {
        drawsBackground = draws
        return self
    }
        
    /// Sets the color of the background the text field’s cell draws behind the text.
    @discardableResult
    func backgroundColor(_ color: NSColor?) -> Self {
        backgroundColor = color ?? .clear
        drawsBackground = color != nil
        return self
    }
        
    /// Sets the maximum width of the text field’s intrinsic content size.
    @discardableResult
    func preferredMaxLayoutWidth(_ maxWidth: CGFloat) -> Self {
        preferredMaxLayoutWidth = maxWidth
        return self
    }
                
    /// The selected string value, or `nil` if the no string is selected.
    var selectedStringValue: String? {
        get { selectedStringRange != nil ? String(stringValue[selectedStringRange!]) : nil }
        set { selectedStringRange = newValue != nil ? (stringValue as NSString).range(of: newValue!) : nil }
    }
        
    /// The range of the selected string, or `nil` if the no string is selected.
    var selectedStringRange: NSRange? {
        get { currentEditor()?.selectedRange }
        set {
            let newValue = newValue ?? NSRange(location: 0, length: 0)
            guard newValue != .notFound else { return }
            currentEditor()?.selectedRange = newValue
        }
    }
        
    /// Deselects all text.
    func deselectAll() {
        currentEditor()?.selectedRange = NSRange(location: 0, length: 0)
    }
        
    /// Selects all text.
    func selectAll() {
        select(stringValue)
    }
        
    /// Selects the specified string.
    func select(_ string: String) {
        selectedStringValue = string
    }
        
    /// Selects the specified range.
    func select(_ range: Range<String.Index>) {
        let range = NSRange(range, in: stringValue)
        guard range != .notFound else { return }
        currentEditor()?.selectedRange = range
    }
        
    /// Selects the specified range.
    func select(_ range: ClosedRange<String.Index>) {
        let range = NSRange(range, in: stringValue)
        guard range != .notFound else { return }
        currentEditor()?.selectedRange = range
    }
        
    /// The location of the cursor while editing.
    var editingCursorLocation: Int? {
        let currentEditor = currentEditor() as? NSTextView
        return currentEditor?.selectedRanges.first?.rangeValue.location
    }
        
    /// The range of the selected text while editing.
    var editingSelectedRange: Range<String.Index>? {
        get { (self.currentEditor() as? NSTextView)?.selectedStringRanges.first }
        set {
            if let range = newValue {
                let currentEditor = self.currentEditor() as? NSTextView
                currentEditor?.selectedStringRanges = [range]
            }
        }
    }

    /**
     A Boolean value indicating whether the text field truncates the text that does not fit within the bounds.

     When the value of this property is `true`, the text field truncates text and adds an ellipsis character to the last visible line when the text does not fit. The value of the property [lineBreakMode](https://developer.apple.com/documentation/appkit/nstextcontainer/linebreakmode)  must be [byWordWrapping](https://developer.apple.com/documentation/appkit/nslinebreakmode/bywordwrapping) or [byCharWrapping](https://developer.apple.com/documentation/appkit/nslinebreakmode/bycharwrapping) for this option to have any effect.
     */
    var truncatesLastVisibleLine: Bool {
        get { cell?.truncatesLastVisibleLine ?? false }
        set { cell?.truncatesLastVisibleLine = newValue }
    }
        
    /// Sets the Boolean value indicating whether the text field truncates the text that does not fit within the bounds.
    @discardableResult
    func truncatesLastVisibleLine(_ truncates: Bool) -> Self {
        truncatesLastVisibleLine = truncates
        return self
    }
        
    /**
     A Boolean value indicating whether the text field wraps text whose length that exceeds the text field’s frame.
         
     To specify the maximum numbers of lines for wrapping, use [maximumNumberOfLines](https://developer.apple.com/documentation/appkit/nstextfield/maximumnumberoflines).
         
     When the value of this property is `true`, the text field wraps text and makes the cell non-scrollable. If the text of the text field is an attributed string value, you must explicitly set the paragraph style line break mode. Setting the value of this property to `true` is equivalent to setting the [lineBreakMode](https://developer.apple.com/documentation/appkit/nstextcontainer/linebreakmode) property to [byWordWrapping](https://developer.apple.com/documentation/appkit/nslinebreakmode/bywordwrapping).
     */
    var wraps: Bool {
        get { cell?.wraps ?? false }
        set { cell?.wraps = newValue }
    }
        
    /// Sets the Boolean value indicating whether the text field wraps text whose length that exceeds the text field’s frame.
    @discardableResult
    func wraps(_ wraps: Bool) -> Self {
        self.wraps = wraps
        return self
    }
        
    /**
     A Boolean value indicating whether excess text scrolls past the text field’s bounds.
         
     When the value of this property is `true`, text can be scrolled past the text field’s bound. When the value is `false`, the text field wraps its text.
     */
    var isScrollable: Bool {
        get { cell?.isScrollable ?? false }
        set { cell?.isScrollable = newValue }
    }
        
    /// Sets the Boolean value indicating whether excess text scrolls past the text field’s bounds.
    @discardableResult
    func isScrollable(_ isScrollable: Bool) -> Self {
        self.isScrollable = isScrollable
        return self
    }
        
    /// Sets the color of the text field’s content.
    @discardableResult
    func textColor(_ color: NSColor?) -> Self {
        textColor = color            
        return self
    }
        
    /// Sets the Boolean value that determines whether the user can select the content of the text field.
    @discardableResult
    func isSelectable(_ isSelectable: Bool) -> Self {
        self.isSelectable = isSelectable
        return self
    }
        
    /// Sets the Boolean value that controls whether the user can edit the value in the text field.
    @discardableResult
    func isEditable(_ isEditable: Bool) -> Self {
        self.isEditable = isEditable
        return self
    }
        
    /// Sets the text layout of the text field.
    @discardableResult
    func textLayout(_ textLayout: TextLayout) -> Self {
        self.textLayout = textLayout
        return self
    }
        
    /// Sets the text field’s bezel style.
    @discardableResult
    func bezelStyle(_ style: BezelStyle?) -> Self {
        bezelStyle = style ?? bezelStyle
        isBezeled = style != nil
        return self
    }
        
    /// Sets the Boolean value that controls whether the text field draws a solid black border around its contents.
    @discardableResult
    func isBordered(_ isBordered: Bool) -> Self {
        self.isBordered = isBordered
        return self
    }
        
    /// Sets the Boolean value that controls whether the text field draws a bezeled background around its contents.
    @discardableResult
    func isBezeled(_ isBezeled: Bool) -> Self {
        self.isBezeled = isBezeled
        return self
    }
        
    /// Sets the maximum number of lines a wrapping text field displays before clipping or truncating the text.
    @discardableResult
    func maximumNumberOfLines(_ lines: Int) -> Self {
        maximumNumberOfLines = lines
        return self
    }
        
    /// A Boolean value indicating whether the text field has keyboard focus.
    var hasKeyboardFocus: Bool {
        currentEditor() == window?.firstResponder
    }

    /**
     Returns the size of the current string value for the specified size and maximum number of lines.
     - Parameters:
        - size: The size.
        - maximumNumberOfLines: The maximum number of lines of `nil` to use the current specified maximum number.

     - Returns: Returns the size of the current string value.
     */
    func textSize(forSize size: CGSize, maximumNumberOfLines: Int? = nil) -> CGSize {
        let _maximumNumberOfLines = self.maximumNumberOfLines
        let bounds = CGRect(origin: .zero, size: size)
        self.maximumNumberOfLines = maximumNumberOfLines ?? self.maximumNumberOfLines
        if let cell = cell {
            let rect = cell.drawingRect(forBounds: bounds)
            let cellSize = cell.cellSize(forBounds: rect)
            self.maximumNumberOfLines = _maximumNumberOfLines
            return cellSize
        }
        self.maximumNumberOfLines = _maximumNumberOfLines
        return .zero
    }

    /// A Boolean value indicating whether the text field is truncating the text.
    var isTruncatingText: Bool {
        var isTruncating = false
        if let cell = cell {
            isTruncating = cell.expansionFrame(withFrame: frame, in: self) != .zero
            if !isTruncating, maximumNumberOfLines == 1 {
                let cellSize = cell.cellSize(forBounds: CGRect(0, 0, CGFloat.greatestFiniteMagnitude, frame.height-0.5))
                isTruncating = cellSize.width > frame.width
            }
        }
        return isTruncating
    }
    
    /// The rectangle of the text.
    var textRect: CGRect {
        cell?.titleRect(forBounds: bounds) ?? bounds
    }
}
#endif
