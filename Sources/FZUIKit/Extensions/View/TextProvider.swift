//
//  TextLineProvider.swift
//  
//
//  Created by Florian Zand on 05.08.25.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

/// A view that provides text.
public protocol TextLineProvider: NSUIView {
    var numberOfVisibleLines: Int { get }
    var totalNumberOfLines: Int { get }
    
    func textLines(includeCharacters: Bool, onlyVisible: Bool, useMaximumNumberOfLines: Bool) -> [TextLine]
    func textLines(forBoundingRect bounds: CGRect, includeCharacters: Bool, onlyVisible: Bool, useMaximumNumberOfLines: Bool) -> [TextLine]
    func textLines(for string: String, includeCharacters: Bool, onlyVisible: Bool, useMaximumNumberOfLines: Bool) -> [TextLine]
    func textLines(for range: Range<String.Index>, includeCharacters: Bool, onlyVisible: Bool, useMaximumNumberOfLines: Bool) -> [TextLine]
    func textLines(for range: NSRange, includeCharacters: Bool, onlyVisible: Bool, useMaximumNumberOfLines: Bool) -> [TextLine]
    
    func boundingRect(for range: Range<String.Index>) -> CGRect?
    func boundingRect(for range: NSRange) -> CGRect?
    func boundingRect(for string: String) -> CGRect?
    
    func characterBezierPaths(onlyVisible: Bool, useMaximumNumberOfLines: Bool) -> [NSUIBezierPath]
    func textLineBezierPaths(onlyVisible: Bool, useMaximumNumberOfLines: Bool) -> [NSUIBezierPath]
    func textBezierPath(onlyVisible: Bool, useMaximumNumberOfLines: Bool) -> NSUIBezierPath
    
    func isLocationInsideText(_ location: CGPoint) -> Bool
}

extension NSUITextField: TextLineProvider, TextLineProviderImplementation { }
extension NSUITextView: TextLineProvider, TextLineProviderImplementation { }
#if canImport(UIKit)
extension UILabel: TextLineProvider, TextLineProviderImplementation { }
#endif

fileprivate protocol TextLineProviderImplementation {
    func layoutManager(onlyVisible: Bool, useMaximumNumberOfLines: Bool) -> NSLayoutManager
}

extension TextLineProvider {
    func layoutManager(onlyVisible: Bool = true, useMaximumNumberOfLines: Bool = true) -> NSLayoutManager {
        (self as! TextLineProviderImplementation).layoutManager(onlyVisible: onlyVisible, useMaximumNumberOfLines: useMaximumNumberOfLines)
    }
}

public extension TextLineProvider {
    /// A Boolean value indicating whether the specified location is inside the text.
    func isLocationInsideText(_ location: CGPoint) -> Bool {
        guard bounds.contains(location) else { return false }
        return layoutManager().isLocationInsideText(location)
    }
    
    /// The number of visible lines.
    var numberOfVisibleLines: Int {
        textLines().count
    }
        
    /// The total number of lines, including the hidden ones and ignoring the ``maximumNumberOfLines``.
    var totalNumberOfLines: Int {
        textLines(onlyVisible: false, useMaximumNumberOfLines: false).count
    }
    
    /**
     The text lines of the text.
         
     - Parameters:
        - includeCharacters: A Boolean value indicating whether to include information about each character in a line, including frame and bezier path.
        - onlyVisible: A Boolean value indicating whether to only return visible text lines.
        - useMaximumNumberOfLines: A Boolean value indicating whether to only include text lines upto the line specified by ``maximumNumberOfLines``.
     */
    func textLines(includeCharacters: Bool = false, onlyVisible: Bool = true, useMaximumNumberOfLines: Bool = true) -> [TextLine] {
        layoutManager(onlyVisible: onlyVisible, useMaximumNumberOfLines: useMaximumNumberOfLines).textLines(includeCharacters: includeCharacters)
    }
    
    /**
     The text lines lying wholly or partially within the specified rectangle.
         
     - Parameters:
        - bounds: The bounding rectangle for which to return text lines.
        - onlyVisible: A Boolean value indicating whether to only return visible text lines.
        - useMaximumNumberOfLines: A Boolean value indicating whether to only include text lines upto the line specified by ``maximumNumberOfLines``.
     */
    func textLines(forBoundingRect bounds: CGRect, includeCharacters: Bool = false, onlyVisible: Bool = true, useMaximumNumberOfLines: Bool = true) -> [TextLine] {
        layoutManager(onlyVisible: onlyVisible, useMaximumNumberOfLines: useMaximumNumberOfLines).textLines(forBoundingRect: bounds, includeCharacters: includeCharacters)
    }
                
    /**
     The text lines for the specified string.
         
     An empty array is returned, if the text isn't containing the specified string.

     - Parameters:
        - string: The string for the text lines.
        - onlyVisible: A Boolean value indicating whether to only return visible text lines.
        - useMaximumNumberOfLines: A Boolean value indicating whether to only include text lines upto the line specified by ``maximumNumberOfLines``.
     */
    func textLines(for string: String, includeCharacters: Bool = false, onlyVisible: Bool = true, useMaximumNumberOfLines: Bool = true) -> [TextLine] {
        layoutManager(onlyVisible: onlyVisible, useMaximumNumberOfLines: useMaximumNumberOfLines).textLines(for: string, includeCharacters: includeCharacters)
    }
        
    /**
     The text lines for the specified string range.
         
     An empty array is returned, if the text isn't containing the specified string.

     - Parameters:
        - range: The string range for the text lines.
        - onlyVisible: A Boolean value indicating whether to only return visible text lines.
        - useMaximumNumberOfLines: A Boolean value indicating whether to only include text lines upto the line specified by ``maximumNumberOfLines``.
     */
    func textLines(for range: Range<String.Index>, includeCharacters: Bool = false, onlyVisible: Bool = true, useMaximumNumberOfLines: Bool = true) -> [TextLine] {
        layoutManager(onlyVisible: onlyVisible, useMaximumNumberOfLines: useMaximumNumberOfLines).textLines(for: range, includeCharacters: includeCharacters)
    }
    
    /**
     The text lines for the specified range.
         
     An empty array is returned, if the text isn't containing the specified string.

     - Parameters:
        - range: The range for the text lines.
        - onlyVisible: A Boolean value indicating whether to only return visible text lines.
        - useMaximumNumberOfLines: A Boolean value indicating whether to only include text lines upto the line specified by ``maximumNumberOfLines``.
     */
    func textLines(for range: NSRange, includeCharacters: Bool = false, onlyVisible: Bool = true, useMaximumNumberOfLines: Bool = true) -> [TextLine] {
        layoutManager(onlyVisible: onlyVisible, useMaximumNumberOfLines: useMaximumNumberOfLines).textLines(for: range, includeCharacters: includeCharacters)
    }
    
    /// The bounding rectangle of the string at the range.
    func boundingRect(for range: Range<String.Index>) -> CGRect? {
        layoutManager().boundingRect(for: range)
    }
    
    /// The bounding rectangle of the string at the range.
    func boundingRect(for range: NSRange) -> CGRect? {
        layoutManager().boundingRect(for: range)
    }
        
    /// The bounding rectangle of the string.
    func boundingRect(for string: String) -> CGRect? {
        layoutManager().boundingRect(for: string)
    }
    
    /**
     Returns the bezier paths for each character in the text.
     
     - Parameters:
        - onlyVisible: A Boolean value indicating whether to include only the visible characters.
        - useMaximumNumberOfLines: A Boolean value indicating whether to include only characters up to the line specified by  [maximumNumberOfLines](https://developer.apple.com/documentation/appkit/nstextfield/maximumnumberoflines).
     */
    func characterBezierPaths(onlyVisible: Bool = true, useMaximumNumberOfLines: Bool = true) -> [NSUIBezierPath] {
        layoutManager(onlyVisible: onlyVisible, useMaximumNumberOfLines: useMaximumNumberOfLines).characterBezierPaths()
    }
    
    /**
     Returns the bezier paths for the text of each line.

     - Parameters:
        - onlyVisible: A Boolean value indicating whether to include only the visible characters.
        - useMaximumNumberOfLines: A Boolean value indicating whether to include only characters up to the line specified by  [maximumNumberOfLines](https://developer.apple.com/documentation/appkit/nstextfield/maximumnumberoflines).
     */
    func textLineBezierPaths(onlyVisible: Bool = true, useMaximumNumberOfLines: Bool = true) -> [NSUIBezierPath] {
        layoutManager(onlyVisible: onlyVisible, useMaximumNumberOfLines: useMaximumNumberOfLines).textLineBezierPaths()
    }
    
    /**
     Returns the bezier path of the text.
     
     - Parameters:
        - onlyVisible: A Boolean value indicating whether to include only the visible characters.
        - useMaximumNumberOfLines: A Boolean value indicating whether to include only characters up to the line specified by  [maximumNumberOfLines](https://developer.apple.com/documentation/appkit/nstextfield/maximumnumberoflines).
     */
    func textBezierPath(onlyVisible: Bool = true, useMaximumNumberOfLines: Bool = true) -> NSUIBezierPath {
        layoutManager(onlyVisible: onlyVisible, useMaximumNumberOfLines: useMaximumNumberOfLines).textBezierPath()
    }
}

extension NSUITextView {
    func layoutManager(onlyVisible: Bool, useMaximumNumberOfLines: Bool) -> NSLayoutManager {
        #if os(macOS)
        if onlyVisible, useMaximumNumberOfLines, let layoutManager = layoutManager, layoutManager.textStorage != nil, !layoutManager.textContainers.isEmpty {
            return layoutManager
        }
        return NSLayoutManager(string: string, attributedString: attributedString(), size: bounds.size, maxLines: maximumNumberOfLines, lineBreakMode: lineBreakMode, onlyVisible: onlyVisible, useMaximumNumberOfLines: useMaximumNumberOfLines)
        #else
        if onlyVisible, useMaximumNumberOfLines, layoutManager.textStorage != nil, !layoutManager.textContainers.isEmpty {
            return layoutManager
        }
        return NSLayoutManager(string: text, attributedString: attributedText, size: bounds.size, maxLines: maximumNumberOfLines, lineBreakMode: lineBreakMode, onlyVisible: onlyVisible, useMaximumNumberOfLines: useMaximumNumberOfLines)
        #endif
    }
}

#if os(macOS)
extension NSTextField {
    func layoutManager(onlyVisible: Bool = true, useMaximumNumberOfLines: Bool = true) -> NSLayoutManager {
        NSLayoutManager(string: stringValue, attributedString: attributedStringValue, size: bounds.size, maxLines: maximumNumberOfLines, lineBreakMode: lineBreakMode, onlyVisible: onlyVisible, useMaximumNumberOfLines: useMaximumNumberOfLines)
    }
}
#elseif canImport(UIKit)
extension UITextField {
    func layoutManager(onlyVisible: Bool = true, useMaximumNumberOfLines: Bool = true) -> NSLayoutManager {
        NSLayoutManager(string: text, attributedString: attributedText, size: bounds.size, onlyVisible: onlyVisible, useMaximumNumberOfLines: useMaximumNumberOfLines)
    }
}

extension UILabel {
    func layoutManager(onlyVisible: Bool = true, useMaximumNumberOfLines: Bool = true) -> NSLayoutManager {
        NSLayoutManager(string: text, attributedString: attributedText, size: bounds.size, maxLines: numberOfLines, lineBreakMode: lineBreakMode, onlyVisible: onlyVisible, useMaximumNumberOfLines: useMaximumNumberOfLines)
    }
}
#endif

fileprivate extension NSLayoutManager {
    convenience init(string: String? = nil, attributedString: NSAttributedString? = nil, size: CGSize, maxLines: Int? = nil, lineBreakMode: NSLineBreakMode? = nil, onlyVisible: Bool, useMaximumNumberOfLines: Bool) {
        self.init()
        var size = size
        if !onlyVisible {
            size.height = .greatestFiniteMagnitude
        }
        let textStorage: NSTextStorage
        if let attributedString = attributedString {
            textStorage = NSTextStorage(attributedString: attributedString)
        } else {
            textStorage = NSTextStorage(string: string ?? "")
        }
        let textContainer = NSTextContainer(size: size)
        textContainer.lineBreakMode = lineBreakMode ?? textContainer.lineBreakMode
        textContainer.maximumNumberOfLines = useMaximumNumberOfLines ? maxLines ?? textContainer.maximumNumberOfLines : 0
        textContainer.lineFragmentPadding = 2.0
        addTextContainer(textContainer)
        textStorage.addLayoutManager(self)
        ensureLayout(for: textContainer)
        #if os(macOS)
        replaceTextStorage(textStorage)
        #endif
    }
}
#endif
