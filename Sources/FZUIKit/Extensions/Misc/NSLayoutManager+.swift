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
