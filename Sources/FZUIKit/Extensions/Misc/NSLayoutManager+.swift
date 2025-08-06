//
//  NSLayoutManager+.swift
//
//
//  Created by Florian Zand on 15.10.24.
//


#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import FZSwiftUtils

extension NSLayoutManager {
    /**
     Removes the specified text container.
     
     - Parameter textContainer: The text container to remove.
     */
    public func removeTextContainer(_ textContainer: NSTextContainer) {
        guard let index = textContainers.firstIndex(of: textContainer) else { return }
        removeTextContainer(at: index)
    }
    
    /// Sets the text containers of the layout manager.
    @discardableResult
    public func textContainers(_ textContainers: [NSTextContainer]) -> Self {
        textContainersWritable = textContainers
        return self
    }
    
    fileprivate var textContainersWritable: [NSTextContainer] {
        get { textContainers }
        set {
            textContainers.forEach({ removeTextContainer($0) })
            newValue.forEach({ addTextContainer($0) })
        }
    }
    
    /// The bounding rectangle of the specified string.
    public func boundingRect(for string: String) -> CGRect? {
        guard let range = textStorage?.string.range(of: string) else { return nil }
        return boundingRect(for: range)
    }
    
    /// The bounding rectangle of the string at the specified range.
    public func boundingRect(for range: Range<String.Index>) -> CGRect? {
        guard let string = textStorage?.string else { return nil }
        let range = range.clamped(to: string.startIndex..<string.endIndex)
        return boundingRect(for: NSRange(range, in: string))
    }
    
    /// The bounding rectangle of the string at the specified range.
    public func boundingRect(for range: NSRange) -> CGRect? {
        guard let textContainer = textContainers.first else { return nil }
        ensureLayout(for: textContainer)
        var boundingRect: CGRect = .zero
        enumerateLineFragments(forGlyphRange: glyphRange(forCharacterRange: range, actualCharacterRange: nil)) { rect, usedRect, _, range, _ in
            boundingRect = boundingRect.union(usedRect)
        }
        return boundingRect
    }
    
    /**
     Returns the bounding rectangle for the glyph at the specified index.
     
     - Parameters:
        - glyphIndex: The glyph for which to return the bounding rectangle.
        - textContainer: The text container in which the glyphs are laid out.
     */
    public func boundingRect(forGlyphAt glyphIndex: Int, in textContainer: NSTextContainer? = nil) -> CGRect {
        if let textContainer = textContainer ?? textContainers.first {
            return boundingRect(forGlyphRange: NSRange(location: glyphIndex, length: 1), in: textContainer)
        }
        return lineFragmentRect(forGlyphAt: glyphIndex, effectiveRange: nil).origin(location(forGlyphAt: glyphIndex)).width(0)
    }
    
    /**
     Returns the bounding position for the glyph at the specified index.
     
     - Parameter glyphIndex: The glyph for which to return the bounding position.
     */
    public func boundingPosition(forGlyphAt glyphIndex: Int) -> CGPoint {
        return location(forGlyphAt: glyphIndex).yValue(lineFragmentRect(forGlyphAt: glyphIndex, effectiveRange: nil).y)
    }
    
    /// The text lines in the layout manager.
    func textLines(includeCharacters: Bool = false) -> [TextLine] {
        guard let textContainer = textContainers.first else { return [] }
        return textLines(glyphRange: glyphRange(for: textContainer), includeCharacters: includeCharacters)
    }
    
    /**
     The text lines for the specified range.
     
     - Parameter range: The range for the text lines.
     */
    func textLines(for range: NSRange, includeCharacters: Bool = false) -> [TextLine] {
        textLines(glyphRange: glyphRange(forCharacterRange: range, actualCharacterRange: nil), includeCharacters: includeCharacters)
    }
    
    /**
     Returns the text lines lying wholly or partially within the specified rectangle.
     
     - Parameter bounds: The bounding rectangle for which to return text lines.
     */
    func textLines(forBoundingRect bounds: CGRect, includeCharacters: Bool = false) -> [TextLine] {
        guard let textContainer = textContainers.first else { return [] }
        return textLines(glyphRange: glyphRange(forBoundingRect: bounds, in: textContainer), includeCharacters: includeCharacters)
    }
    
    /**
     The text lines including the specified strig.
     
     - Parameter string: The string for the text lines.
     */
    func textLines(for string: String, includeCharacters: Bool = false) -> [TextLine] {
        guard let textStorage = textStorage, let range = textStorage.string.range(of: string) else { return [] }
        return textLines(for: range, includeCharacters: includeCharacters)
    }
    
    /**
     The text lines for the specified range.
     
     - Parameter range: The range for the text lines.
     */
    func textLines(for range: Range<String.Index>, includeCharacters: Bool = false) -> [TextLine] {
        guard let textStorage = textStorage else { return [] }
        let range = range.clamped(to: textStorage.string.startIndex..<textStorage.string.endIndex)
        return textLines(for: NSRange(range, in: textStorage.string), includeCharacters: includeCharacters)
    }
    
    private func textLines(glyphRange: NSRange, includeCharacters: Bool = false) -> [TextLine] {
        guard let textContainer = textContainers.first, let textStorage = textStorage else { return [] }
        ensureLayout(for: textContainer)
        var lines: [TextLine] = []
        let padding = textContainer.lineFragmentPadding
        let height = textContainer.size.height
        let fontValues = includeCharacters ? textStorage.allAttributeValues(for: .font) : []
        enumerateLineFragments(forGlyphRange: glyphRange) { frame, textFrame, textContainer, range, stop in
            let textRange = self.characterRange(forGlyphRange: range, actualGlyphRange: nil)
            let text = String(textStorage.string[textRange])
            let characters: [TextLine.LineCharacter] = includeCharacters ? range.indexed().compactMap { index, glyphIndex in
                var frame = self.boundingRect(forGlyphAt: glyphIndex, in: textContainer)
                frame.origin.y = height - frame.origin.y - frame.height + padding + self.textOffset.y
                frame.origin.x += self.textOffset.x
                guard let font = fontValues.value(at: glyphIndex) as? NSUIFont, let glyphPath = NSUIBezierPath(glyph: self.cgGlyph(at: glyphIndex), font: font, location: frame.origin) else { return nil }
                return .init(text[index], frame: frame, bezierPath: glyphPath, index: glyphIndex)
            } : []
            lines += TextLine(frame: frame, textFrame: textFrame, textRange: textRange, text: text, characters: characters)
        }
        return lines
    }
    
    /// The bezier path of the text in the layout manager.
    func textBezierPath() -> NSUIBezierPath {
        characterBezierPaths().combined()
    }
    
    /// The bezier paths of the text lines in the layout manager.
    internal func textLineBezierPaths() -> [NSUIBezierPath] {
        characterBezierPathsByLine().map({ $0.combined() })
    }
    
    /// The bezier paths of the characters in the text of the layout manager.
    internal func characterBezierPaths() -> [NSUIBezierPath] {
        characterBezierPathsByLine().flatMap({ $0 })
    }

    private func characterBezierPathsByLine() -> [[NSUIBezierPath]] {
        guard let textContainer = textContainers.first, let textStorage = textStorage else { return [] }
        ensureLayout(for: textContainer)
        let fonts = textStorage.allAttributeValues(for: .font)
        let padding = textContainer.lineFragmentPadding
        let height = textContainer.size.height
        var lines: [[NSUIBezierPath]] = []
        enumerateLineFragments(forGlyphRange: glyphRange(for: textContainer)) { lineFrame, textFrame, textContainer, range, stop in
            lines += range.compactMap({ glyphIndex in
                guard let font = fonts.value(at: glyphIndex) as? NSUIFont else { return nil }
                var frame = self.boundingRect(forGlyphAt: glyphIndex)
                frame.origin.y = height - frame.y - frame.height + padding + self.textOffset.y
                frame.origin.x += self.textOffset.x
                return NSUIBezierPath(glyph: self.cgGlyph(at: glyphIndex), font: font, location: frame.origin)
            })
        }
        return lines
    }
    
    /// A Boolean value indicating whether the specified location is inside the text of text field.
    func isLocationInsideText(_ location: CGPoint) -> Bool {
        guard let textContainer = textContainers.first else { return false }
        let glyphIndex = glyphIndex(for: location, in: textContainer)
        return boundingRect(forGlyphRange: NSRange(location: glyphIndex, length: 1), in: textContainer).contains(location)
    }
    
    var textOffset: CGPoint {
        get { getAssociatedValue("textOffset") ?? .zero }
        set { setAssociatedValue(newValue, key: "textOffset") }
    }
}

extension NSAttributedString {
    func allAttributeValues(for attrName: NSAttributedString.Key, range: NSRange? = nil) -> [(range: NSRange, value: Any?)] {
        var result: [(range: NSRange, value: Any?)] = []
        let fullRange = range ?? NSRange(location: 0, length: length)
        var index = fullRange.lowerBound
        while index < fullRange.upperBound {
            var effectiveRange = NSRange()
            let value = attribute(attrName, at: index, longestEffectiveRange: &effectiveRange, in: fullRange)
            result.append((effectiveRange, value))
            index = effectiveRange.upperBound
        }

        return result
    }
}

extension [(range: NSRange, value: Any?)] {
    func value(at location: Int) -> Any? {
        first(where: { NSLocationInRange(location, $0.range) })?.value
    }
}

#endif
