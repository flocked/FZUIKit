//
//  NSTextField+.swift
//
//
//  Created by Florian Zand on 03.09.22.
//

#if os(macOS)

import AppKit

public extension NSTextField {
    /// Returns the number of lines.
    var currentNumberOfLines: Int {
        guard let font = self.font else { return -1 }
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        self.attributedStringValue.boundingRect(with: maxSize, context: nil)
        let stringValue = self.stringValue as NSString
        let textSize = stringValue.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
    }
    
    /// A Boolean value indicating whether the text field truncates the text that does not fit within the bounds.
    var truncatesLastVisibleLine: Bool {
        get { self.cell?.truncatesLastVisibleLine ?? false }
        set { self.cell?.truncatesLastVisibleLine = newValue }
    }
    
    /// A Boolean value indicating whether the text field has keyboard focus.
    var hasKeyboardFocus: Bool {
        return currentEditor() == window?.firstResponder
      }

    func textRect(forBounds bounds: CGRect, maximumNumberOfLines: Int) -> CGRect {
        let _maximumNumberOfLines = self.maximumNumberOfLines
        self.maximumNumberOfLines = maximumNumberOfLines
        if let cell = cell {
            let rect = cell.drawingRect(forBounds: bounds)
            let cellSize = cell.cellSize(forBounds: rect)
            self.maximumNumberOfLines = _maximumNumberOfLines
            return CGRect(origin: .zero, size: cellSize)
        }
        self.maximumNumberOfLines = _maximumNumberOfLines
        return .zero
    }

    /// A Boolean value indicating whether the text field is truncating the text.
    var isTruncatingText: Bool {
        var bounds = self.bounds
        let textSize = textRect(forBounds: bounds, maximumNumberOfLines: maximumNumberOfLines).size
        bounds.size = CGSize(width: bounds.size.width, height: CGFloat.infinity)
        let fullSize = textRect(forBounds: bounds, maximumNumberOfLines: 0).size
        return textSize != fullSize
    }

    /// Option how to count the lines of a text field.
    enum LineCountOption {
        /// Returns all lines
        case all
        /// Returns lines upto the maximum number of lines.
        case limitToMaxNumberOfLines
    }

    /**
     The number of lines.
     
     - Parameters option: Option how to count the lines. The default value is `limitToMaxNumberOfLines`.
     */
    func linesCount(_ option: LineCountOption = .limitToMaxNumberOfLines) -> Int {
        return rangesOfLines(option).count
    }

    /**
     An array of strings of the lines.

     - Parameters option: Option which lines should be returned. The default value is `limitToMaxNumberOfLines`.
     */
    func lines(_ option: LineCountOption = .limitToMaxNumberOfLines) -> [String] {
        let ranges = rangesOfLines(option)
        return ranges.compactMap { String(self.stringValue[$0]) }
    }

    /**
     An array of string ranges of the lines.
     
     - Parameters option: Option which line ranges should be returned. The default value is `limitToMaxNumberOfLines`.
     */
    func rangesOfLines(_ option: LineCountOption = .limitToMaxNumberOfLines) -> [Range<String.Index>] {
        let stringValue = self.stringValue
        let linebreakMode = lineBreakMode
        if linebreakMode != .byCharWrapping || linebreakMode != .byWordWrapping, maximumNumberOfLines != 1 {
            lineBreakMode = .byCharWrapping
        }
        var partialString = ""
        var startIndex = stringValue.startIndex
        var previousHeight: CGFloat = 0.0
        var didStart = false
        var nextIndex = stringValue.startIndex
        var lineRanges: [Range<String.Index>] = []
        var boundsSize = bounds.size
        boundsSize.height = .infinity
        stringValue.forEach { char in
            partialString = partialString + String(char)
            self.stringValue = partialString
            let height = self.textRect(forBounds: CGRect(origin: .zero, size: boundsSize), maximumNumberOfLines: option == .all ? 0 : self.maximumNumberOfLines + 1).size.height
            if didStart == false {
                previousHeight = height
                didStart = true
            } else {
                nextIndex = stringValue.index(after: nextIndex)
                if height > previousHeight {
                    let endIndex = nextIndex
                    let range = startIndex ..< endIndex
                    startIndex = endIndex
                    lineRanges.append(range)
                    previousHeight = height
                } else if nextIndex == stringValue.index(before: stringValue.endIndex) {
                    if self.maximumNumberOfLines == 0 || option == .all || lineRanges.count < self.maximumNumberOfLines {
                        let endIndex = stringValue.endIndex
                        let range = startIndex ..< endIndex
                        lineRanges.append(range)
                    }
                }
            }
        }
        self.stringValue = stringValue
        lineBreakMode = linebreakMode
        return lineRanges
    }
}

#endif

/*
 func textLines(width: CGFloat? = nil, numberOfLines: Int? = nil) -> [Range<String.Index>] {
     let stringValue = self.stringValue
     var partialString: String = ""
     var isBeginning = true
     var previousHeight: CGFloat = 0.0
     var lines: [Range<String.Index>] = []
     var line = 0
     var startIndex = stringValue.startIndex
     var maximumNumberOfLines = numberOfLines ?? self.maximumNumberOfLines
     if (maximumNumberOfLines > 0) {
         maximumNumberOfLines = maximumNumberOfLines + 1
     }
     let _maxNumberOfLines = self.maximumNumberOfLines
     let _lineBreakMode = self.lineBreakMode
     self.lineBreakMode = .byCharWrapping
     var nextIndex = stringValue.startIndex
     let width = width ?? self.bounds.size.width
     self.maximumNumberOfLines = maximumNumberOfLines
     stringValue.forEach({
         char in
         if (nextIndex != stringValue.endIndex) {
             nextIndex = stringValue.index(after: nextIndex)
         }
         partialString = partialString + String(char)
         self.stringValue = partialString
         let fittingSize = self.sizeThatFits(CGSize(width, .infinity))
         if (isBeginning) {
             nextIndex = stringValue.startIndex
             previousHeight = fittingSize.height
             isBeginning = false
         } else {
             if (fittingSize.height > previousHeight) {
                 let endIndex = nextIndex
                 let lineString = String(stringValue[startIndex..<endIndex])
                 startIndex = endIndex
                 var range = startIndex..<endIndex
                 lines.append(range)
                 Swift.debugPrint(line, lineString)
             //    lines[line] = lineString
                 previousHeight = fittingSize.height
                 line = line + 1
             } else {
                 if (nextIndex == stringValue.index(before: stringValue.endIndex) && (line < _maxNumberOfLines || self.maximumNumberOfLines == 0)) {
                     let endIndex = stringValue.endIndex
                     let lineString = String(stringValue[startIndex..<endIndex])
                     var range = startIndex..<endIndex
                     lines.append(range)
                  //   lines[line] = lineString
                 }
             }
         }
     })
     self.stringValue = stringValue
     self.maximumNumberOfLines = _maxNumberOfLines
     self.lineBreakMode = _lineBreakMode
     return lines
 }
 */

/*
 //
 //  UILabel+.swift
 //
 //
 //  Created by Florian Zand on 17.08.23.
 //

 #if canImport(UIKit)
 import UIKit

 extension UILabel {
     /// Returns the number of lines.
     var numberOfLines: Int {
         let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
         let charSize = font.lineHeight
         let text = (self.text ?? "") as NSString
         let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
         let linesRoundedUp = Int(ceil(textSize.height/charSize))
         return linesRoundedUp
     }
 }
 #endif

 */
