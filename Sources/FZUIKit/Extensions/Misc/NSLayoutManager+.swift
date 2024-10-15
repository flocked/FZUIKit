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

extension NSLayoutManager {
    /// The frame of the string.
    func boundingRect(for string: String) -> CGRect? {
        guard let range = textStorage?.string.range(of: string) else { return nil }
        return boundingRect(for: range)
    }
    
    /// The frame of the string at the range.
    func boundingRect(for range: Range<String.Index>) -> CGRect? {
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
    
    internal func getTextLines(range: NSRange? = nil, useMaximumNumberOfLines: Bool = true) -> [TextLine] {
        guard let textStorage = textStorage, let textContainer = textContainers.first else { return [] }
        
        var textLines: [TextLine] = []
        var glyphRange = NSRange(location: 0, length: textStorage.length)
        if let range = range {
            glyphRange =  self.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
        }
        let maximumNumberOfLines = textContainer.maximumNumberOfLines
        if useMaximumNumberOfLines {
            textContainer.maximumNumberOfLines = 0
        }
        enumerateLineFragments(forGlyphRange: glyphRange) { (rect, usedRect, textContainer, glyphRange, stop) in
            guard rect != .zero else { return }
            textLines.append(.init(frame: rect, textFrame: usedRect, text: String(textStorage.string[glyphRange]), textRange: Range(glyphRange, in: textStorage.string)!))
        }
        textContainer.maximumNumberOfLines = maximumNumberOfLines
        return textContainer.maximumNumberOfLines > 0 ? Array(textLines[safe: 0..<textContainer.maximumNumberOfLines]) : textLines
    }
}

#endif
