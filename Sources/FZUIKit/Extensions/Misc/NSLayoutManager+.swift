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
    
    /// The frame of the specified string.
    public func boundingRect(for string: String) -> CGRect? {
        guard let range = textStorage?.string.range(of: string) else { return nil }
        return boundingRect(for: range)
    }
    
    /// The frame of the string at the specified range.
    public func boundingRect(for range: Range<String.Index>) -> CGRect? {
        var boundingRect: CGRect? = nil
        guard let string = textStorage?.string, let textContainer = textContainers.first, range.clamped(to: string.startIndex..<string.endIndex) == range else { return nil }
        enumerateEnclosingRects(forGlyphRange:  NSRange(range, in: string), withinSelectedGlyphRange:  NSRange(range, in: string), in: textContainer) { rect, stop in
            boundingRect = rect
            stop.pointee = true
        }
        boundingRect?.origin.x += 2
        boundingRect?.origin.y += 2
        return boundingRect
    }
    
    /**
     The text lines for the specified range.
         
     - Parameters:
        - range: The range for the text lines.
        - useMaximumNumberOfLines: A Boolean value indicating whether to only include text lines upto the line specified by text container's `maximumNumberOfLines`.
     */
    internal func textLines(for range: NSRange? = nil, useMaximumNumberOfLines: Bool = true) -> [TextLine] {
        guard let textStorage = textStorage, let textContainer = textContainers.first else { return [] }
        var textLines: [TextLine] = []
        let maximumNumberOfLines = textContainer.maximumNumberOfLines
        defer { textContainer.maximumNumberOfLines = maximumNumberOfLines }
        if useMaximumNumberOfLines {
            textContainer.maximumNumberOfLines = 0
        }
        let glyphRange = glyphRange(forCharacterRange: range ?? NSRange(location: 0, length: textStorage.length), actualCharacterRange: nil)
        enumerateLineFragments(forGlyphRange: glyphRange) { (rect, usedRect, textContainer, range, stop) in
            guard rect != .zero else { return }
            textLines += .init(frame: rect, textFrame: usedRect, text: String(textStorage.string[range]), textRange: Range(range, in: textStorage.string)!, textNSRange: range)
        }
        return textContainer.maximumNumberOfLines > 0 ? Array(textLines[safe: 0..<textContainer.maximumNumberOfLines]) : textLines
    }

    /// Returns the bezier paths for each character in the layout manager.
    internal func characterBezierPaths() -> [NSUIBezierPath] {
        guard let textContainer = textContainers.first, let textStorage = textStorage else { return [] }
        ensureLayout(for: textContainer)
        var bezierPaths: [NSUIBezierPath] = []
        for glyphIndex in glyphRange(for: textContainer) {
            guard let font = textStorage.attribute(.font, at: glyphIndex, effectiveRange: nil) as? NSUIFont, let glyphPath = NSUIBezierPath(glyph: glyph(at: glyphIndex), font: font) else { continue }
            let location = location(forGlyphAt: glyphIndex)
            #if os(macOS)
            glyphPath.transform(using: AffineTransform(translationByX: location.x, byY: location.y))
            #else
            glyphPath.apply(.init().translatedBy(x: location.x, y: location.y))
            #endif
            bezierPaths += glyphPath
        }
        return bezierPaths
    }
    
    /// Returns the bezier path for the text in the layout manager.
    internal func textBezierPath() -> NSUIBezierPath {
        characterBezierPaths().reduce(into: .init()) {
            $0.append($1)
        }
    }
}

#endif
