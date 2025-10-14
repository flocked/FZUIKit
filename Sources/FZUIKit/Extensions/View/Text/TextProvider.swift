//
//  TextProvider.swift
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
public protocol TextProvider: NSUIView { }

extension NSUITextField: TextProvider, TextProviderImplementation { }
extension NSUITextView: TextProvider, TextProviderImplementation { }
#if canImport(UIKit)
extension UILabel: TextProvider, TextProviderImplementation { }
#endif

fileprivate protocol TextProviderImplementation: TextProvider {
    func layoutManager(onlyVisible: Bool, useMaximumNumberOfLines: Bool) -> NSLayoutManager
}

public extension TextProvider {
    /// A Boolean value indicating whether the specified location lies on or inside the text.
    func isLocationOnText(_ location: CGPoint) -> Bool {
        guard bounds.contains(location) else { return false }
        return layoutManager().isLocationOnText(location)
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
    
    fileprivate func layoutManager(string: String? = nil, attributedString: NSAttributedString? = nil, maxLines: Int? = nil, lineBreakMode: NSLineBreakMode? = nil, font: NSUIFont?, onlyVisible: Bool, useMaximumNumberOfLines: Bool) -> NSLayoutManager {
        var size = bounds.size
        #if os(macOS)
        let textRect = (self as? NSTextField)?.textRect ?? bounds
        size = textRect.size
        calculationLayoutManager.textOffset = textRect.origin
        if textRect.height > bounds.height {
            calculationLayoutManager.textOffset.y += (bounds.height - textRect.height) / 2.0
        }
        #endif
        if self is NSUITextView {
            calculationLayoutManager.textContainers[0].lineFragmentPadding = 5.0
            calculationLayoutManager.textOffset.y -= 2.0
        }
        
        let textContainer = calculationLayoutManager.textContainers[0]
        let textStorage = calculationLayoutManager.textStorage!
        textContainer.size = onlyVisible ? size : size.height(.greatestFiniteMagnitude)
        textContainer.lineBreakMode = lineBreakMode ?? textContainer.lineBreakMode
        textContainer.maximumNumberOfLines = useMaximumNumberOfLines ? maxLines ?? textContainer.maximumNumberOfLines : 0
        if let attributedString = attributedString, attributedString != textStorage {
            textStorage.setAttributedString(attributedString)
            appliedFont = nil
        } else if let string = string, string != textStorage.string || font != appliedFont {
            textStorage.setAttributedString(NSAttributedString(string: string, attributes: font != nil ? [.font: font!] : nil))
            appliedFont = font
        }
        calculationLayoutManager.ensureLayout(for: textContainer)
        return calculationLayoutManager
    }
    
    fileprivate var calculateTextStorage: NSTextStorage {
        get { getAssociatedValue("calculateTextStorage", initialValue: NSTextStorage(string: "")) }
        set { setAssociatedValue(newValue, key: "calculateTextStorage") }
    }
    
    fileprivate var appliedFont: NSUIFont? {
        get { getAssociatedValue("appliedFont") }
        set { setAssociatedValue(newValue, key: "appliedFont") }
    }
    
    fileprivate var calculationLayoutManager: NSLayoutManager {
        getAssociatedValue("calculationLayoutManager", initialValue: NSLayoutManager(textStorage: calculateTextStorage))
    }
}

fileprivate extension NSUITextView {
    func layoutManager(onlyVisible: Bool, useMaximumNumberOfLines: Bool) -> NSLayoutManager {
        #if os(macOS)
        layoutManager(string: string, attributedString: attributedString(), maxLines: maximumNumberOfLines, lineBreakMode: lineBreakMode, font: font, onlyVisible: onlyVisible, useMaximumNumberOfLines: useMaximumNumberOfLines)
        #else
        layoutManager(string: text, attributedString: attributedText, maxLines: maximumNumberOfLines, lineBreakMode: lineBreakMode, font: font, onlyVisible: onlyVisible, useMaximumNumberOfLines: useMaximumNumberOfLines)
        #endif
    }
}

#if os(macOS)
fileprivate extension NSTextField {
    func layoutManager(onlyVisible: Bool = true, useMaximumNumberOfLines: Bool = true) -> NSLayoutManager {
        layoutManager(string: stringValue, attributedString: attributedStringValue, maxLines: maximumNumberOfLines, lineBreakMode: lineBreakMode, font: font, onlyVisible: onlyVisible, useMaximumNumberOfLines: useMaximumNumberOfLines)
    }
}
#elseif canImport(UIKit)
fileprivate extension UITextField {
    func layoutManager(onlyVisible: Bool = true, useMaximumNumberOfLines: Bool = true) -> NSLayoutManager {
        layoutManager(string: text, attributedString: attributedText, maxLines: 1, font: font, onlyVisible: onlyVisible, useMaximumNumberOfLines: useMaximumNumberOfLines)
    }
}

fileprivate extension UILabel {
    func layoutManager(onlyVisible: Bool = true, useMaximumNumberOfLines: Bool = true) -> NSLayoutManager {
        layoutManager(string: text, attributedString: attributedText, maxLines: numberOfLines, lineBreakMode: lineBreakMode, font: font, onlyVisible: onlyVisible, useMaximumNumberOfLines: useMaximumNumberOfLines)
    }
}
#endif

fileprivate extension TextProvider {
    func layoutManager(onlyVisible: Bool = true, useMaximumNumberOfLines: Bool = true) -> NSLayoutManager {
        (self as! TextProviderImplementation).layoutManager(onlyVisible: onlyVisible, useMaximumNumberOfLines: useMaximumNumberOfLines)
    }
}

fileprivate extension NSLayoutManager {
    convenience init(textStorage: NSTextStorage) {
        self.init()
        let textContainer = NSTextContainer(size: .zero)
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
