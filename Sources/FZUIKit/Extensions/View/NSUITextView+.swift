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
        
    /**
     The text lines of the text view.
         
     The text view needs to have a layout manager, text container and text storage, or else an empty array is returned.
     */
    var textLines: [TextLine] {
        getTextLines()
    }
        
    /**
     The text lines for the specified string.
         
     An empty array is returned, if the text view's string value isn't containing the string.

     - Parameters:
        - string: The string for the text lines.
        - onlyVisible: A Boolean value that indicates whether to only return visible text lines.
     */
    func textLines(for string: String) -> [TextLine] {
        #if os(macOS)
        guard let range = self.string.range(of: string) else { return [] }
        #else
        guard let range = text.range(of: string) else { return [] }
        #endif
        return textLines(for: range)
    }
        
    /**
     The text lines for the specified string range.
         
     An empty array is returned, if the text view's string value isn't containing the range.
         
     - Parameters:
        - range: The string range for the text lines.
        - onlyVisible: A Boolean value that indicates whether to only return visible text lines.
     */
    func textLines(for range: Range<String.Index>) -> [TextLine] {
        #if os(macOS)
        guard range.clamped(to: string.startIndex..<string.endIndex) == range else { return [] }
        return getTextLines(range: NSRange(range, in: string))
        #else
        guard range.clamped(to: text.startIndex..<text.endIndex) == range else { return [] }
        return getTextLines(range: NSRange(range, in: text))
        #endif
    }
        
    /// The frame of the string at the range.
    func boundingRect(for range: Range<String.Index>) -> CGRect? {
        var boundingRect: CGRect? = nil
        #if os(macOS)
        guard let layoutManager = layoutManager, range.clamped(to: string.startIndex..<string.endIndex) == range else { return nil }
        layoutManager.enumerateEnclosingRects(forGlyphRange:  NSRange(range, in: string), withinSelectedGlyphRange:  NSRange(range, in: string), in: layoutManager.textContainers.first!) { rect, stop in
            boundingRect = rect
            stop.pointee = true
        }
        #else
        guard range.clamped(to: text.startIndex..<text.endIndex) == range else { return nil }
        layoutManager.enumerateEnclosingRects(forGlyphRange:  NSRange(range, in: text), withinSelectedGlyphRange:  NSRange(range, in: text), in: layoutManager.textContainers.first!) { rect, stop in
            boundingRect = rect
            stop.pointee = true
        }
        #endif
        boundingRect?.origin.x += 2
        boundingRect?.origin.y += 2
        return boundingRect
    }
        
    /// The frame of the string.
    func boundingRect(for string: String) -> CGRect? {
        #if os(macOS)
        guard let range = self.string.range(of: string) else { return nil }
        #else
        guard let range = text.range(of: string) else { return nil }
        #endif
        return boundingRect(for: range)
    }
        
    internal func getTextLines(range: NSRange? = nil, useMaximumNumberOfLines: Bool = true) -> [TextLine] {
        #if os(macOS)
        guard let layoutManager = layoutManager, let textStorage = textStorage, let textContainer = textContainer else { return [] }
        #endif
            
        var textLines: [TextLine] = []
        var glyphRange = NSRange(location: 0, length: textStorage.length)
        if let range = range {
            glyphRange =  layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
        }
        let maximumNumberOfLines = textContainer.maximumNumberOfLines
        if useMaximumNumberOfLines {
            textContainer.maximumNumberOfLines = 0
        }
        layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { (rect, usedRect, textContainer, glyphRange, stop) in
            guard rect != .zero else { return }
            #if os(macOS)
            textLines.append(.init(frame: rect, textFrame: usedRect, text: String(self.string[glyphRange]), textRange: Range(glyphRange, in: self.string)!))
            #else
            textLines.append(.init(frame: rect, textFrame: usedRect, text: String(self.text[glyphRange]), textRange: Range(glyphRange, in: self.text)!))
            #endif
        }
        textContainer.maximumNumberOfLines = maximumNumberOfLines
        return textContainer.maximumNumberOfLines > 0 ? Array(textLines[safe: 0..<textContainer.maximumNumberOfLines]) : textLines
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
        
    internal var _fontSize: CGFloat {
        get { font?.pointSize ?? 0.0 }
        set { font = font?.withSize(newValue) }
    }

    #elseif canImport(UIKit)
    /// The font size of the text.
    @objc var fontSize: CGFloat {
        get { font?.pointSize ?? 0.0 }
        set { font = font?.withSize(newValue) }
    }
    #endif
}
#endif
