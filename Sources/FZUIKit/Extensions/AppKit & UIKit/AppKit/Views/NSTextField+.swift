//
//  File.swift
//
//
//  Created by Florian Zand on 03.09.22.
//

#if os(macOS)

    import AppKit

    public extension NSTextField {
        convenience init(layout: TextLayout) {
            self.init(frame: .zero)
            textLayout = layout
        }

        var truncatesLastVisibleLine: Bool {
            get { self.cell?.truncatesLastVisibleLine ?? false }
            set { self.cell?.truncatesLastVisibleLine = newValue }
        }

        convenience init(frame: CGRect, layout: TextLayout) {
            self.init(frame: frame)
            textLayout = layout
        }

        var textLayout: TextLayout? {
            get {
                switch (lineBreakMode, cell?.wraps, cell?.isScrollable) {
                case (.byWordWrapping, true, false):
                    return .wraps
                case (.byTruncatingTail, false, false):
                    return .truncates
                case (.byClipping, false, true):
                    return .scrolls
                default:
                    return nil
                }
            }
            set {
                if let newValue = newValue {
                    lineBreakMode = newValue.lineBreakMode
                    usesSingleLineMode = false
                    cell?.wraps = newValue.wraps
                    truncatesLastVisibleLine = true
                    cell?.isScrollable = newValue.isScrollable
                    setContentCompressionResistancePriority(newValue.layoutPriority, for: .horizontal)
                }
            }
        }

        enum TextLayout: Int, CaseIterable {
            case truncates = 0
            case wraps = 1
            case scrolls = 2

            public init?(lineBreakMode: NSLineBreakMode) {
                guard let found = Self.allCases.first(where: { $0.lineBreakMode == lineBreakMode }) else { return nil }
                self = found
            }

            internal var isScrollable: Bool {
                return (self == .scrolls)
            }

            internal var wraps: Bool {
                return (self == .wraps)
            }

            internal var layoutPriority: NSLayoutConstraint.Priority {
                return (self == .wraps) ? .fittingSizeCompression : .defaultLow
            }

            internal var lineBreakMode: NSLineBreakMode {
                switch self {
                case .wraps:
                    return .byWordWrapping
                case .truncates:
                    return .byTruncatingTail
                case .scrolls:
                    return .byClipping
                }
            }
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

        var isTruncatingText: Bool {
            var bounds = self.bounds
            let textSize = textRect(forBounds: bounds, maximumNumberOfLines: maximumNumberOfLines).size
            bounds.size = CGSize(width: bounds.size.width, height: CGFloat.infinity)
            let fullSize = textRect(forBounds: bounds, maximumNumberOfLines: 0).size
            return textSize != fullSize
        }

        enum LineOption {
            case all
            case limitToMaxNumberOfLines
        }

        func linesCount(_ optiom: LineOption = .limitToMaxNumberOfLines) -> Int {
            return rangesOfLines(optiom).count
        }

        func lines(_ option: LineOption = .limitToMaxNumberOfLines) -> [String] {
            let ranges = rangesOfLines(option)
            return ranges.compactMap { String(self.stringValue[$0]) }
        }

        func rangesOfLines(_ option: LineOption = .limitToMaxNumberOfLines) -> [Range<String.Index>] {
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
                 Swift.print(line, lineString)
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
