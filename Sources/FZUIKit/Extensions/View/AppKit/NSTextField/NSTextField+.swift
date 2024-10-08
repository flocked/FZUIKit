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
        /**
         Initializes a text field that automatically resizes to fit it's string value.
         
         - Parameter stringValue: A string to use as the content of the label.
         
         - Returns: An initialized `NSTextField`.
         */
        convenience init(resizingLabel stringValue: String) {
            self.init(labelWithString: stringValue)
            self.automaticallyResizesToFit = true
            self.backgroundColor = nil
            self.focusType = .roundedCorners(4.0)
            self.isVerticallyCentered = true
            self.stringValue = stringValue
            self.resizeToFit()
        }
        
        /**
         Creates a text field for use as a label.
         
         - Parameter string: The string value of the text field.
         */
        static func label(_ stringValue: String = "") -> NSTextField {
            NSTextField(labelWithString: stringValue).backgroundColor(nil)
        }
        
        /**
         Creates a wrapping text field for use as a multiline label.
         
         - Parameter string: The string value of the text field.
         */
        static func wrapping(_ stringValue: String = "") -> Self {
            Self(wrappingLabelWithString: stringValue)
                .isSelectable(false)
                .isEditable(false)
        }
        
        /**
         Creates a bordered and bezeled editing text field.
         
         - Parameters:
            - string: The string value of the text field.
            - placeholder: The place holder of the text field.
            - rounded: A Boolean value that indicates whether the text field's bezel is rounded.
         */
        static func editing(_ string: String = "", placeholder: String? = nil, rounded: Bool = false) -> Self {
            Self(string: string)
                .isBordered(true)
                .placeholder(placeholder)
                .bezelStyle(rounded ? .roundedBezel : .squareBezel)
        }
        
        /**
         Creates a text field that automatically resizes to fit it's string value.
         
         - Parameter string: The string value of the text field.
         */
        static func resizing(_ stringValue: String = "") -> Self {
            let textField = Self(labelWithString: stringValue)
            textField.automaticallyResizesToFit = true
            textField.backgroundColor = nil
            textField.focusType = .roundedCorners(4.0)
            textField.isVerticallyCentered = true
            textField.stringValue = stringValue
            textField.resizeToFit()
            return textField
        }
        
        /// The text field’s number formatter.
        var numberFormatter: NumberFormatter? {
            get { formatter as? NumberFormatter }
            set {
                if let newValue = newValue {
                    formatter = newValue
                } else if formatter is NumberFormatter {
                    formatter = nil
                }
            }
        }
        
        /// Sets the text field’s number formatter.
        @discardableResult
        func numberFormatter(_ formatter: NumberFormatter?) -> Self {
            numberFormatter = formatter
            return self
        }
        
        /// Sets the string the text field displays when empty to help the user understand the text field’s purpose.
        @discardableResult
        func placeholder(_ placeholder: String?) -> Self {
            placeholderString = placeholder
            return self
        }
        
        /// Sets attributed string the text field displays when empty to help the user understand the text field’s purpose.
        @discardableResult
        func placeholderAttributed(_ placeholder: NSAttributedString?) -> Self {
            placeholderAttributedString = placeholder
            return self
        }
        
        /// Sets the Boolean value that controls whether the text field’s cell draws a background color behind the text.
        @discardableResult
        func drawsBackground(_ draws: Bool) -> Self {
            drawsBackground = draws
            return self
        }
        
        /// Sets the color of the background the text field’s cell draws behind the text.
        @discardableResult
        func backgroundColor(_ color: NSColor?) -> Self {
            backgroundColor = color ?? .clear
            drawsBackground = color != nil
            return self
        }
        
        /// The selected string value, or `nil` if the no string is selected.
        var selectedStringValue: String? {
            get { selectedStringRange != nil ? String(stringValue[selectedStringRange!]) : nil }
            set { selectedStringRange = newValue != nil ? (stringValue as NSString).range(of: newValue!) : nil }
        }
        
        /// The range of the selected string, or `nil` if the no string is selected.
        var selectedStringRange: NSRange? {
            get { currentEditor()?.selectedRange }
            set {
                let newValue = newValue ?? NSRange(location: 0, length: 0)
                guard newValue != .notFound else { return }
                currentEditor()?.selectedRange = newValue
            }
        }
        
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
            selectedStringValue = string
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
            get { (self.currentEditor() as? NSTextView)?.selectedStringRanges.first }
            set {
                if let range = newValue {
                    let currentEditor = self.currentEditor() as? NSTextView
                    currentEditor?.selectedStringRanges = [range]
                }
            }
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
        
        /// Sets the Boolean value indicating whether the text field truncates the text that does not fit within the bounds.
        @discardableResult
        func truncatesLastVisibleLine(_ truncates: Bool) -> Self {
            truncatesLastVisibleLine = truncates
            return self
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
        
        /// Sets the Boolean value indicating whether the text field wraps text whose length that exceeds the text field’s frame.
        @discardableResult
        func wraps(_ wraps: Bool) -> Self {
            self.wraps = wraps
            return self
        }
        
        /**
         A Boolean value indicating whether excess text scrolls past the text field’s bounds.
         
         When the value of this property is `true`, text can be scrolled past the text field’s bound. When the value is `false`, the text field wraps its text.
         */
        var isScrollable: Bool {
            get { cell?.isScrollable ?? false }
            set { cell?.isScrollable = newValue }
        }
        
        /// Sets the Boolean value indicating whether excess text scrolls past the text field’s bounds.
        @discardableResult
        func isScrollable(_ isScrollable: Bool) -> Self {
            self.isScrollable = isScrollable
            return self
        }
        
        /// Sets the color of the text field’s content.
        @discardableResult
        func textColor(_ color: NSColor?) -> Self {
            textColor = color            
            return self
        }
        
        /// Sets the Boolean value that determines whether the user can select the content of the text field.
        @discardableResult
        func isSelectable(_ isSelectable: Bool) -> Self {
            self.isSelectable = isSelectable
            return self
        }
        
        /// Sets the Boolean value that controls whether the user can edit the value in the text field.
        @discardableResult
        func isEditable(_ isEditable: Bool) -> Self {
            self.isEditable = isEditable
            return self
        }
        
        /// Sets the text layout of the text field.
        @discardableResult
        func textLayout(_ textLayout: TextLayout) -> Self {
            self.textLayout = textLayout
            return self
        }
        
        /// Sets the text field’s bezel style.
        @discardableResult
        func bezelStyle(_ style: BezelStyle?) -> Self {
            bezelStyle = style ?? bezelStyle
            isBezeled = style != nil
            return self
        }
        
        /// Sets the Boolean value that controls whether the text field draws a solid black border around its contents.
        @discardableResult
        func isBordered(_ isBordered: Bool) -> Self {
            self.isBordered = isBordered
            return self
        }
        
        /// Sets the Boolean value that controls whether the text field draws a bezeled background around its contents.
        @discardableResult
        func isBezeled(_ isBezeled: Bool) -> Self {
            self.isBezeled = isBezeled
            return self
        }
        
        /// Sets the maximum number of lines a wrapping text field displays before clipping or truncating the text.
        @discardableResult
        func maximumNumberOfLines(_ lines: Int) -> Self {
            maximumNumberOfLines = lines
            return self
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
            var isTruncating = false
            if let cell = cell {
                isTruncating = cell.expansionFrame(withFrame: frame, in: self) != .zero
                if !isTruncating, maximumNumberOfLines == 1 {
                    let cellSize = cell.cellSize(forBounds: CGRect(0, 0, CGFloat.greatestFiniteMagnitude, frame.height-0.5))
                    isTruncating = cellSize.width > frame.width
                }
            }
            return isTruncating
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

        internal var numberOfVisibleLinesAlt: Int {
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
