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
            let range = (stringValue as NSString).range(of: string)
            guard range != .notFound else { return }
            currentEditor()?.selectedRange = range
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
            get {
                let currentEditor = self.currentEditor() as? NSTextView
                return currentEditor?.selectedStringRanges.first
            }
            set {
                if let range = newValue {
                    let currentEditor = self.currentEditor() as? NSTextView
                    currentEditor?.selectedStringRanges = [range]
                }
            }
        }
        
        /// The focus type of the text field.
        var focusType: NSTextFieldCell.FocusType {
            get { (cell as? NSTextFieldCell)?.focusType ?? .default }
            set { (cell as? NSTextFieldCell)?.focusType = newValue }
        }
        
        /// The vertical alignment of the displayed text inside the text field.
        var verticalTextAlignment: NSTextFieldCell.VerticalAlignment {
            get { (cell as? NSTextFieldCell)?.verticalAlignment ?? .default }
            set { (cell as? NSTextFieldCell)?.verticalAlignment = newValue }
        }
        
        /*
        /// The leading padding of the text cell.
        var leadingTextPadding: CGFloat {
            get { (cell as? NSTextFieldCell)?.leadingPadding ?? 0.0 }
            set { (cell as? NSTextFieldCell)?.leadingPadding = newValue }
        }
        
        /// The trailing padding of the text cell.
        var trailingTextPadding: CGFloat {
            get { (cell as? NSTextFieldCell)?.trailingPadding ?? 0.0 }
            set { (cell as? NSTextFieldCell)?.trailingPadding = newValue }
        }
        */
        
        /// The y-coordinate of the baseline for the topmost line of the text.
        var firstBaselineY: CGFloat? {
            guard let font = font else { return nil }
            let defaultLineHeight = lineHeight
            let cellFrame = cellFrame ?? frame
            guard cellFrame.height >= defaultLineHeight else { return nil }
            let height = font.spc ?? defaultLineHeight - font.ascenderReal
            return cellFrame.origin.y + cellFrame.height - defaultLineHeight + height
        }

        /// The y-coordinate of the baseline for the last visible line of the text.
        var lastBaselineY: CGFloat? {
            guard let font = font else { return nil }
            guard let lastLineFrame = lineFrames().last else { return nil }
            let defaultLineHeight = lineHeight
            let height = font.spc ?? defaultLineHeight - font.ascenderReal
            return lastLineFrame.origin.y + height
        }
        
        /// Returns the number of visible lines.
        var numberOfVisibleLines: Int {
            guard let font = font else { return -1 }
            let charSize = font.lineHeight

            let framesetter = CTFramesetterCreateWithAttributedString(attributedStringValue)
            let textSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRange(), nil, CGSize(bounds.width, CGFloat.greatestFiniteMagnitude), nil)

            var numberOfVisibleLines = Int((textSize.height / charSize).rounded(.down))
            if maximumNumberOfLines != 0, numberOfVisibleLines > maximumNumberOfLines {
                numberOfVisibleLines = maximumNumberOfLines
            }
            return numberOfVisibleLines
        }

        /**
         A Boolean value indicating whether the text field truncates the text that does not fit within the bounds.
         
         When the value of this property is `true`, the text field truncates text and adds an ellipsis character to the last visible line when the text does not fit. The value in the `lineBreakMode` property must be `byWordWrapping` or `byCharWrapping` for this option to have any effect.
         */
        var truncatesLastVisibleLine: Bool {
            get { cell?.truncatesLastVisibleLine ?? false }
            set { cell?.truncatesLastVisibleLine = newValue }
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
        
        /**
         A Boolean value indicating whether excess text scrolls past the text field’s bounds.
         
         When the value of this property is `true`, text can be scrolled past the text field’s bound. When the value is `false`, the text field wraps its text.
         */
        var isScrollable: Bool {
            get { cell?.isScrollable ?? false }
            set { cell?.isScrollable = newValue }
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
            guard let cell = cell else { return false }
            return cell.expansionFrame(withFrame: frame, in: self) != .zero
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

         - Parameter option: Option how to count the lines. The default value is `limitToMaxNumberOfLines`.
         */
        func linesCount(_ option: LineCountOption = .limitToMaxNumberOfLines) -> Int {
            rangesOfLines(option).count
        }

        /**
         An array of strings of the lines.

         - Parameter option: Option which lines should be returned. The default value is `limitToMaxNumberOfLines`.
         */
        func lines(_ option: LineCountOption = .limitToMaxNumberOfLines) -> [String] {
            let ranges = rangesOfLines(option)
            return ranges.compactMap { String(self.stringValue[$0]) }
        }

        /// An array of frames for all visible lines.
        func lineFrames() -> [CGRect] {
            var lineFrames: [CGRect] = []
            guard font != nil else { return [] }
            let defaultLineHeight = lineHeight
            let frame = cellFrame ?? frame
            for index in 0 ..< numberOfVisibleLines - 1 {
                var lineFrame = frame
                lineFrame.size.height = defaultLineHeight
                lineFrame.topLeft = frame.topLeft
                lineFrame.origin.y = lineFrame.origin.y - (CGFloat(index) * defaultLineHeight)
                lineFrames.append(lineFrame)
            }
            return lineFrames
        }

        /// The height of a singe line.
        internal var lineHeight: CGFloat {
            guard font != nil else { return 0 }
            if stringValue == "" {
                stringValue = " "
                let height = attributedStringValue[0].height(withConstrainedWidth: CGFloat.greatestFiniteMagnitude)
                stringValue = ""
                return height
            }
            return attributedStringValue[0].height(withConstrainedWidth: CGFloat.greatestFiniteMagnitude)
        }

        /// The frame of the text cell.
        internal var cellFrame: CGRect? {
            let frame = isBezeled == false ? frame : frame.insetBy(dx: 0, dy: 1)
            return cell?.drawingRect(forBounds: frame)
        }

        var numberOfVisibleLinesAlt: Int {
            let maxSize = CGSize(width: bounds.width, height: CGFloat.infinity)
            var numberOfVisibleLines = 0
            let attributedStringValue = attributedStringValue
            var height: CGFloat = 0
            var string = ""
            for character in attributedStringValue.string {
                string += String(character)
                let range = attributedStringValue.range(of: string)
                self.attributedStringValue = attributedStringValue[range]
                let boundingRect = self.attributedStringValue.boundingRect(with: maxSize, options: .usesLineFragmentOrigin)
                if boundingRect.height != height {
                    if boundingRect.height < frame.size.height {
                        height = boundingRect.height
                        numberOfVisibleLines = numberOfVisibleLines + 1
                        if numberOfVisibleLines == maximumNumberOfLines {
                            self.attributedStringValue = attributedStringValue
                            return numberOfVisibleLines
                        }
                    } else {
                        self.attributedStringValue = attributedStringValue
                        return numberOfVisibleLines
                    }
                }
            }
            self.attributedStringValue = attributedStringValue
            return numberOfVisibleLines
        }

        /**
         An array of string ranges of the lines.

         - Parameter option: Option which line ranges should be returned. The default value is `limitToMaxNumberOfLines`.
         */
        func rangesOfLines(_ option: LineCountOption = .limitToMaxNumberOfLines) -> [Range<String.Index>] {
            let stringValue = stringValue
            let attributedStringValue = attributedStringValue
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
            attributedStringValue.attributedSubstring(from: NSRange(location: 0, length: 1))
            for index in 0 ..< attributedStringValue.string.count {
                let partialString = attributedStringValue[0 ... index]
                self.attributedStringValue = partialString
                let height = textSize(forSize: boundsSize, maximumNumberOfLines: option == .all ? 0 : maximumNumberOfLines + 1).height
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
                        if maximumNumberOfLines == 0 || option == .all || lineRanges.count < maximumNumberOfLines {
                            let endIndex = stringValue.endIndex
                            let range = startIndex ..< endIndex
                            lineRanges.append(range)
                        }
                    }
                }
            }

            stringValue.forEach { char in
                partialString = partialString + String(char)

                self.stringValue = partialString
                let height = self.textSize(forSize: boundsSize, maximumNumberOfLines: option == .all ? 0 : self.maximumNumberOfLines + 1).height
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

/*
 /**
  Returns the number of visible lines.

  ``AppKit/NSTextField/numberOfVisibleLines`` sometimes returns the wrong number of visible lines. This property always returns the correct number, but takes longer to calculate.
  */
 var numberOfVisibleLinesAlt: Int {
  let maxSize = CGSize(width: self.bounds.width, height: CGFloat.infinity)
  var numberOfVisibleLines = 0
  let attributedStringValue = self.attributedStringValue
  var height: CGFloat = 0
  var string = ""
  for character in attributedStringValue.string {
      string += String(character)
      let range = attributedStringValue.range(of: string)
      self.attributedStringValue = attributedStringValue[range]
      let boundingRect = self.attributedStringValue.boundingRect(with: maxSize, options: .usesLineFragmentOrigin)
      if boundingRect.height != height {
          if boundingRect.height < self.frame.size.height {
              height = boundingRect.height
              numberOfVisibleLines = numberOfVisibleLines + 1
              if numberOfVisibleLines == self.maximumNumberOfLines {
                  self.attributedStringValue = attributedStringValue
                  return numberOfVisibleLines
              }
          } else {
              self.attributedStringValue = attributedStringValue
              return numberOfVisibleLines
          }
      }
  }
  self.attributedStringValue = attributedStringValue
  return numberOfVisibleLines
 }

  func rangesOfLinesAA() {
      let maxSize = self.bounds.size
      var lineCount = 0
      let attributedStringValue = self.attributedStringValue
      var height: CGFloat = 0
      var string = ""
      var partialString = ""
      var lineRanges: [Range<String.Index>] = []
      for character in attributedStringValue.string {
          string += String(character)
          partialString += String(character)
          let range = attributedStringValue.range(of: string)
          let partialAttributedString = attributedStringValue[range]
          let boundingRect = partialAttributedString.boundingRect(with: maxSize, options: .usesLineFragmentOrigin)
          if boundingRect.height != height {
              attributedStringValue.string.range(of: string)
          }
      }
  }
 */
