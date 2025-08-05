//
//  NSUITextView+.swift
//
//
//  Created by Florian Zand on 08.11.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import FZSwiftUtils

public extension NSUITextView {
    /**
     Initializes a text view.
             
     - Parameters:
        - frame: The frame rectangle of the text view.
        - layoutManager: The layout manager of the text view.

     */
    convenience init(frame: CGRect, layoutManager: NSLayoutManager) {
        let textStorage = NSTextStorage()
        textStorage.addLayoutManager(layoutManager)
        #if os(macOS)
        let textContainer = NSTextContainer(containerSize: frame.size)
        #else
        let textContainer = NSTextContainer(size: frame.size)
        #endif
        layoutManager.addTextContainer(textContainer)
        self.init(frame: frame, textContainer: textContainer)
    }
    
    /// The maximum number of lines that the text view can display.
    var maximumNumberOfLines: Int {
        get { _textContainer?.maximumNumberOfLines ?? 0 }
        set { _textContainer?.maximumNumberOfLines = newValue }
    }
    
    /// The behavior of the last line inside the text view.
    var lineBreakMode: NSLineBreakMode {
        get { _textContainer?.lineBreakMode ?? .byWordWrapping }
        set { _textContainer?.lineBreakMode = newValue }
    }
        
    /// Sets the maximum number of lines that the text view can display.
    @discardableResult
    func maximumNumberOfLines(_ maximumNumberOfLines: Int) -> Self {
        self.maximumNumberOfLines = maximumNumberOfLines
        return self
    }
        
    /// Sets the behavior of the last line inside the text view.
    @discardableResult
    func lineBreakMode(_ lineBreakMode: NSLineBreakMode) -> Self {
        self.lineBreakMode = lineBreakMode
        return self
    }
    
    /**
     The text lines of the text view.
         
     The text view needs to have a layout manager, text container and text storage, or else an empty array is returned.
     
     - Parameters:
        - string: The string for the text lines.
        - onlyVisible: A Boolean value indicating whether to only return visible text lines.
        - useMaximumNumberOfLines: A Boolean value indicating whether to only include text lines upto the line specified by ``maximumNumberOfLines``.
     */
    func textLines(onlyVisible: Bool = true, useMaximumNumberOfLines: Bool = true) -> [TextLine] {
        getTextLines(onlyVisible: onlyVisible, useMaximumNumberOfLines: useMaximumNumberOfLines)
    }
        
    /**
     The text lines for the specified string.
         
     An empty array is returned, if the text view's string value isn't containing the string.

     - Parameters:
        - string: The string for the text lines.
        - onlyVisible: A Boolean value indicating whether to only return visible text lines.
        - useMaximumNumberOfLines: A Boolean value indicating whether to only include text lines upto the line specified by ``maximumNumberOfLines``.
     */
    func textLines(for string: String, onlyVisible: Bool = true, useMaximumNumberOfLines: Bool = true) -> [TextLine] {
        guard let range = self.string.range(of: string) else { return [] }
        return textLines(for: range, onlyVisible: onlyVisible, useMaximumNumberOfLines: useMaximumNumberOfLines)
    }
        
    /**
     The text lines for the specified string range.
         
     An empty array is returned, if the text view's string value isn't containing the range.
         
     - Parameters:
        - range: The string range for the text lines.
        - onlyVisible: A Boolean value indicating whether to only return visible text lines.
        - useMaximumNumberOfLines: A Boolean value indicating whether to only include text lines upto the line specified by ``maximumNumberOfLines``.
     */
    func textLines(for range: Range<String.Index>, onlyVisible: Bool = true, useMaximumNumberOfLines: Bool = true) -> [TextLine] {
        let range = range.clamped(to: string.startIndex..<string.endIndex)
        return getTextLines(range: NSRange(range, in: string), onlyVisible: onlyVisible, useMaximumNumberOfLines: useMaximumNumberOfLines)
    }
        
    /// The frame of the string at the range.
    func boundingRect(for range: Range<String.Index>) -> CGRect? {
        var boundingRect: CGRect? = nil
        #if os(macOS)
        guard let layoutManager = layoutManager else { return nil }
        #endif
        let range = range.clamped(to: string.startIndex..<string.endIndex)
        layoutManager.enumerateEnclosingRects(forGlyphRange:  NSRange(range, in: string), withinSelectedGlyphRange:  NSRange(range, in: string), in: layoutManager.textContainers.first!) { rect, stop in
            boundingRect = rect
            stop.pointee = true
        }
        boundingRect?.origin.x += 2
        boundingRect?.origin.y += 2
        return boundingRect
    }
        
    /// The frame of the string.
    func boundingRect(for string: String) -> CGRect? {
        guard let range = self.string.range(of: string) else { return nil }
        return boundingRect(for: range)
    }
    
    /// The range of characters selected in the text view.
    var selectedStringRange: Range<String.Index> {
        get { Range(selectedRange, in: string)! }
        set { selectedRange = NSRange(newValue, in: string) }
    }
    
    /// The selected string.
    var selectedString: String? {
        get { _textStorage?.attributedSubstring(from: selectedRange).string }
        set {
            if let newValue = newValue {
                let range = (string as NSString).range(of: newValue)
                guard range.location != NSNotFound else { return }
                selectedRange = range
            } else {
                selectedRange = NSRange(location: 0, length: 0)
            }
        }
    }
    
    /// The selected attributed string.
    var selectedAttributedString: NSAttributedString? {
        get { _textStorage?.attributedSubstring(from: selectedRange) }
    }
    
    /// The font of the selected text.
    var selectionFont: NSUIFont? {
        get {
            var font: NSUIFont?
            _textStorage?.enumerateAttribute(.font, in: selectedRange, using: { _font,_,_ in
                font = _font as? NSUIFont
            })
            return font
        }
        set {
            if let newValue = newValue {
                _textStorage?.addAttribute(.font, value: newValue, range: selectedRange)
            } else {
                _textStorage?.removeAttribute(.font, range: selectedRange)
            }
        }
    }
    
    #if os(macOS)
    /// The ranges of characters selected in the text view.
    var selectedStringRanges: [Range<String.Index>] {
        get { selectedRanges.compactMap({ Range($0.rangeValue, in: string)} ) }
        set { selectedRanges = newValue.compactMap({ NSRange($0, in: string).nsValue }) }
    }
        
    /// Sets the ranges of characters selected in the text view.
    @discardableResult
    func selectedStringRanges(_ ranges: [Range<String.Index>]) -> Self {
        selectedStringRanges = ranges
        return self
    }
        
    /// The fonts of the selected text ranges.
    var selectionFonts: [NSUIFont] {
        get {
            guard let textStorage = textStorage else { return [] }
            return selectedRanges.reduce(into: []) { fonts, range in
                textStorage.enumerateAttribute(.font, in: range.rangeValue, using: { font,_,_ in
                    fonts += font as? NSUIFont
                })
            }
        }
        set {
            guard let textStorage = textStorage else { return }
            for (index, range) in selectedRanges.compactMap({$0.rangeValue}).enumerated() {
                if let font = newValue[safe: index] ?? newValue.last {
                    textStorage.addAttribute(.font, value: font, range: range)
                }
            }
        }
    }
        
    /// Selects all text.
    func selectAll() {
        select(string)
    }
        
    /**
     Selects the specified range in the text view.
     
     - Parameters:
        - range: The range to select.
        - exclusive: A Boolean value indicating whether only the range should be selected, or the selection should be expanded.
     */
    func select(_ string: String, exclusive: Bool = true) {
        guard let range = string.range(of: string) else { return }
        select(range, exclusive: exclusive)
    }
        
    /**
     Selects the specified range in the text view.
     
     - Parameters:
        - range: The range to select.
        - exclusive: A Boolean value indicating whether only the range should be selected, or the selection should be expanded.
     */
    func select(_ range: Range<String.Index>, exclusive: Bool = true) {
        if exclusive {
            selectedStringRange = range
        } else if !selectedStringRanges.contains(range) {
            selectedStringRanges += range
        }
    }
        
    /**
     Selects the specified range in the text view.
     
     - Parameters:
        - range: The range to select.
        - exclusive: A Boolean value indicating whether only the range should be selected, or the selection should be expanded.
     */
    func select(_ range: NSRange, exclusive: Bool = true) {
        guard NSRange(string)?.contains(range) == true else { return }
        if exclusive {
            selectedRange = range
        } else if !selectedRanges.map({$0.rangeValue}).contains(range) {
            selectedRanges += range.nsValue
        }
    }
    #else
    /// Selects the text.
    func selectAll() {
        select(text)
    }
        
    /// Selects the specified string in the text view.
    func select(_ string: String) {
        guard let range = text.range(of: string) else { return }
        selectedStringRange = range
    }
        
    /// Selects the specified range in the text view.
    func select(_ range: Range<String.Index>) {
        guard text.range.contains(range) else { return }
        selectedStringRange = range
    }
        
    /// Selects the specified range in the text view.
    func select(_ range: NSRange) {
        guard NSRange(text)?.contains(range) == true else { return }
        selectedRange = range
    }
    #endif
        
    /// Sets the range of characters selected in the text view.
    @discardableResult
    func selectedStringRange(_ range: Range<String.Index>) -> Self {
        selectedStringRange = range
        return self
    }
    
    /// Sets the selected string.
    @discardableResult
    func selectedString(_ selectedString: String?) -> Self {
        self.selectedString = selectedString
        return self
    }
    
    /// The selection attributes of the text view.
    var selectionAttributes: [NSAttributedString.Key: Any] {
        get { _textStorage?.attributes(at: selectedRange.location, effectiveRange: &selectedRange) ?? [:] }
        set { _textStorage?.setAttributes(newValue, range: selectedRange) }
    }
    
    /// Sets the selection attributes of the text view.
    @discardableResult
    func selectionAttributes(_ attributes: [NSAttributedString.Key: Any]) -> Self {
        selectionAttributes = attributes
        return self
    }
    
    /// Sets the selection attributes of the text view.
    @discardableResult
    func selectionAttributes(_ attributes: (inout [NSAttributedString.Key: Any])->()) -> Self {
        attributes(&selectionAttributes)
        return self
    }
    
    /// Sets the typing attributes of the text view.
    @discardableResult
    func typingAttributes(_ attributes: [NSAttributedString.Key: Any]) -> Self {
        typingAttributes = attributes
        return self
    }
    
    /// Sets the typing attributes of the text view.
    @discardableResult
    func typingAttributes(_ attributes: (inout [NSAttributedString.Key: Any])->()) -> Self {
        attributes(&typingAttributes)
        return self
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
            textLines.append(.init(frame: rect, textFrame: usedRect, text: String(self.string[glyphRange]), textRange: Range(glyphRange, in: self.string)!))
        }
        return textLines
    }
    
    internal func layoutManager(onlyVisible: Bool, useMaximumNumberOfLines: Bool) -> NSLayoutManager {
        #if os(macOS)
        if onlyVisible, useMaximumNumberOfLines, let layoutManager = layoutManager, layoutManager.textStorage != nil, !layoutManager.textContainers.isEmpty {
            return layoutManager
        }
        #else
        if onlyVisible, useMaximumNumberOfLines, layoutManager.textStorage != nil, !layoutManager.textContainers.isEmpty {
            return layoutManager
        }
        #endif
        var size = bounds.size
        if !onlyVisible {
            size.height = .greatestFiniteMagnitude
        }
        #if os(macOS)
        let textStorage = NSTextStorage(attributedString: attributedString())
        #else
        let textStorage = NSTextStorage(attributedString: attributedText)
        #endif
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: size)
        textContainer.lineBreakMode = lineBreakMode
        textContainer.maximumNumberOfLines = useMaximumNumberOfLines ? maximumNumberOfLines : 0
        textContainer.lineFragmentPadding = 2.0
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        layoutManager.ensureLayout(for: textContainer)
        #if os(macOS)
        layoutManager.replaceTextStorage(textStorage)
        #endif
        return layoutManager
    }
        
    #if os(macOS)
    /**
     The font size of the text.

     The value can be animated via `animator()`.
     */
    var fontSize: CGFloat {
        get { _fontSize }
        set {
            NSView.swizzleAnimationForKey()
            _fontSize = newValue
        }
    }
        
    @objc internal var _fontSize: CGFloat {
        get { font?.pointSize ?? 0.0 }
        set { font = font?.withSize(newValue) }
    }
    
    internal var selectionHasStrikethrough: Bool {
        selection(hasAttribute: .strikethroughStyle)
    }
    
    internal var selectionHasUnderline: Bool {
        selection(hasAttribute: .underlineStyle)
    }
    
    internal func selection(hasAttribute key: NSAttributedString.Key) -> Bool {
        guard let textStorage = textStorage else { return false }
        var hasKey = false
        for range in selectedRanges.compactMap({$0.rangeValue}) {
            guard !hasKey else { break }
            textStorage.enumerateAttribute(key, in: range, using: { attribute, range, stop in
                guard attribute as? Int ?? 0 != 0 else { return }
                hasKey = true
                stop.pointee = true
            })
        }
        return hasKey
    }
        
    internal var typingIsUnderline: Bool {
        typingAttributes[.underlineStyle] as? Int ?? 0 != 0
    }
        
    internal var typingIsStrikethrough: Bool {
        typingAttributes[.strikethroughStyle] as? Int ?? 0 != 0
    }

    #elseif canImport(UIKit)
    /// The font size of the text.
    @objc var fontSize: CGFloat {
        get { font?.pointSize ?? 0.0 }
        set { font = font?.withSize(newValue) }
    }
    #endif
}

fileprivate extension NSUITextView {
    var _textStorage: NSTextStorage? { textStorage }
    var _textContainer: NSTextContainer? { textContainer }
}

#if !os(macOS)
fileprivate extension UITextView {
    var string: String {
        get { text }
        set { text = newValue }
    }
}
#endif
#endif
