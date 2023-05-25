//
//  NSFont+.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

#if os(macOS)
    import AppKit
    @available(macOS 11.0, *)
    extension NSFont.TextStyle: CaseIterable {
        public static var allCases: [Self] {
            [.body, .subheadline, .headline, .caption1, .caption2, .callout, .footnote, .title1, .title2, .title3, .largeTitle]
        }
    }

    public extension NSFont {
        var lineHeight: CGFloat {
            var attributes = fontDescriptor.fontAttributes
            var font = self
            if attributes[.sizeCategory] != nil {
                attributes[.sizeCategory] = nil
                if let usageValue = attributes[.uiUsage] as? String {
                    if usageValue == "UICTFontTextStyleHeadline" {
                        attributes[.uiUsage] = "CTFontDemiUsage"
                    } else if usageValue.contains("UICTFontTextStyle") {
                        attributes[.uiUsage] = "CTFontRegularUsage"
                    }
                }
                font = NSFont(descriptor: NSUIFontDescriptor(fontAttributes: attributes), size: pointSize)!
            }
            let ctFont = font as CTFont
            return CTFontGetAscent(ctFont) + CTFontGetDescent(ctFont) + CTFontGetLeading(ctFont)
            // return self.boundingRectForFont.size.height
        }

        static func systemFont(ofTableRowSize tableRowSize: NSTableView.RowSizeStyle) -> NSFont {
            return .systemFont(ofSize: systemFontSize(forTableRowSize: tableRowSize))
        }

        static func systemFont(ofTableRowSize tableRowSize: NSTableView.RowSizeStyle, weight: NSFont.Weight) -> NSFont {
            return .systemFont(ofSize: systemFontSize(forTableRowSize: tableRowSize), weight: weight)
        }

        static func systemFontSize(forTableRowSize tableRowSize: NSTableView.RowSizeStyle) -> CGFloat {
            switch tableRowSize {
            case .small:
                return 11.0
            case .large:
                if #available(macOS 11.0, *) {
                    return 15.0
                } else {
                    return 13.0
                }
            default:
                return 13.0
            }
        }

        func sized(toFit text: String, height: CGFloat) -> NSFont {
            let font = withSize(1)
            var textSize = text.size(withAttributes: [.font: font])
            var newPointSize = font.pointSize

            while textSize.height < height {
                newPointSize += 1
                let newFont = NSFont(name: font.fontName, size: newPointSize)!
                textSize = text.size(withAttributes: [.font: newFont])
            }
            return withSize(newPointSize)
        }

        func sized(toFit text: String, width: CGFloat) -> NSFont {
            let font = withSize(1)
            var textSize = text.size(withAttributes: [.font: font])
            var newPointSize = font.pointSize

            while textSize.width < width {
                newPointSize += 1
                let newFont = NSFont(name: font.fontName, size: newPointSize)!
                textSize = text.size(withAttributes: [.font: newFont])
            }
            return withSize(newPointSize)
        }
    }

#endif
