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
                
    /// Returns the number of visible lines.
    var numberOfVisibleLines: Int {
        textLines().count
    }
        
    /// Returns the total number of lines, including the hidden ones and ignoring the ``maximumNumberOfLines``.
    var totalNumberOfLines: Int {
        getTextLines(onlyVisible: false, useMaximumNumberOfLines: false).count
    }

    /**
     A Boolean value indicating whether the text field truncates the text that does not fit within the bounds.
         
     When the value of this property is `true`, the text field truncates text and adds an ellipsis character to the last visible line when the text does not fit. The value in the `lineBreakMode` property must be `byWordWrapping` or `byCharWrapping` for this option to have any effect.
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
         
     To specify the maximum numbers of lines for wrapping, use `maximumNumberOfLines`.
         
     When the value of this property is `true`, the text field wraps text and makes the cell non-scrollable. If the text of the text field is an attributed string value, you must explicitly set the paragraph style line break mode. Setting the value of this property to `true` is equivalent to setting the `lineBreakMode` property to `byWordWrapping`.
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
        
    /**
     The text lines of the text field.
         
     - Parameter onlyVisible: A Boolean value indicating whether to only return visible text lines.
     */
    func textLines(onlyVisible: Bool = true) -> [TextLine] {
        getTextLines(onlyVisible: onlyVisible)
    }
                
    /**
     The text lines for the specified string.
         
     An empty array is returned, if the text field's string value isn't containing the string.

     - Parameters:
        - string: The string for the text lines.
        - onlyVisible: A Boolean value indicating whether to only return visible text lines.
     */
    func textLines(for string: String, onlyVisible: Bool = true) -> [TextLine] {
        guard let range = stringValue.range(of: string) else { return [] }
        return textLines(for: range, onlyVisible: onlyVisible)
    }
        
    /**
     The text lines for the specified string range.
         
     An empty array is returned, if the text field's string value isn't containing the range.
         
     - Parameters:
        - range: The string range for the text lines.
        - onlyVisible: A Boolean value indicating whether to only return visible text lines.
     */
    func textLines(for range: Range<String.Index>, onlyVisible: Bool = true) -> [TextLine] {
        guard range.clamped(to: stringValue.startIndex..<stringValue.endIndex) == range else { return [] }
        return getTextLines(range: NSRange(range, in: stringValue), onlyVisible: onlyVisible)
    }
        
    internal func getTextLines(range: NSRange? = nil, onlyVisible: Bool = true, useMaximumNumberOfLines: Bool = true) -> [TextLine] {
        let layoutManager = layoutManager(onlyVisible: onlyVisible, useMaximumNumberOfLines: useMaximumNumberOfLines)
            
            
        var glyphRange = NSRange(location: 0, length: layoutManager.textStorage!.length)
        if let range = range {
            glyphRange =  layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
        }
        var textLines: [TextLine] = []
        layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { (rect, usedRect, textContainer, glyphRange, stop) in
            guard rect != .zero else { return }
            textLines.append(.init(frame: rect, textFrame: usedRect, text: String(self.stringValue[glyphRange]), textRange: Range(glyphRange, in: self.stringValue)!))
        }
        return textLines
    }
        
    /// The frame of the string at the range.
    func boundingRect(for range: Range<String.Index>) -> CGRect? {
        guard range.clamped(to: stringValue.startIndex..<stringValue.endIndex) == range else { return nil }
            
        let layoutManager = layoutManager()
        var boundingRect: CGRect? = nil
        layoutManager.enumerateEnclosingRects(forGlyphRange:  NSRange(range, in: stringValue), withinSelectedGlyphRange:  NSRange(range, in: stringValue), in: layoutManager.textContainers.first!) { rect, stop in
            boundingRect = rect
            stop.pointee = true
        }
        boundingRect?.origin.x += 2
        boundingRect?.origin.y += 2
        return boundingRect
    }
        
    /// The frame of the string.
    func boundingRect(for string: String) -> CGRect? {
        guard let range = stringValue.range(of: string) else { return nil }
        return boundingRect(for: range)
    }
        
    internal func layoutManager(onlyVisible: Bool = true, useMaximumNumberOfLines: Bool = true) -> NSLayoutManager {
        var size = bounds.size
        if let cell {
            let rect = cell.drawingRect(forBounds: bounds)
            size = cell.cellSize(forBounds: rect)
        }
        if !onlyVisible {
            size.height = .greatestFiniteMagnitude
        }
        let textStorage = NSTextStorage(attributedString: attributedStringValue)
            
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: size)
        textContainer.size = size
            
        textContainer.lineBreakMode = lineBreakMode
        textContainer.maximumNumberOfLines = useMaximumNumberOfLines ? maximumNumberOfLines : 0
        textContainer.lineFragmentPadding = 0.0
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        layoutManager.ensureLayout(for: textContainer)
        layoutManager.replaceTextStorage(textStorage)
        return layoutManager
    }
}

protocol TextLocationProvider {
    func isLocationInsideText(_ location: CGPoint) -> Bool
}

extension NSTextField: TextLocationProvider {
    /// A Boolean value indicating whether the specified location is inside the text of text field.
   public func isLocationInsideText(_ location: CGPoint) -> Bool {
        guard bounds.contains(location) else { return false }
        if let editor = currentEditor() as? NSTextView,
           let layoutManager = editor.layoutManager,
           let textContainer = editor.textContainer {
            let containerPoint = CGPoint(x: location.x - editor.textContainerOrigin.x, y: location.y - editor.textContainerOrigin.y)
            let glyphIndex = layoutManager.glyphIndex(for: containerPoint, in: textContainer)
            return layoutManager.boundingRect(forGlyphRange: NSRange(location: glyphIndex, length: 1), in: textContainer).contains(containerPoint)
        } else {
            let textStorage = NSTextStorage(attributedString: attributedStringValue)
            let layoutManager = NSLayoutManager()
            let textContainer = NSTextContainer(size: bounds.size).lineFragmentPadding(2.0).maximumNumberOfLines(maximumNumberOfLines).lineBreakMode(lineBreakMode)
            layoutManager.addTextContainer(textContainer)
            textStorage.addLayoutManager(layoutManager)
            let glyphIndex = layoutManager.glyphIndex(for: location, in: textContainer)
            return layoutManager.boundingRect(forGlyphRange: NSRange(location: glyphIndex, length: 1), in: textContainer).contains(location)
        }
    }
}

#endif
