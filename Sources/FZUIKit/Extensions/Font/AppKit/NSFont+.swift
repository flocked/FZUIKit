//
//  NSFont+.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

#if os(macOS)
    import AppKit
    import FZSwiftUtils

    @available(macOS 11.0, *)
    extension NSFont.TextStyle: CaseIterable {
        /// A collection of all text style values.
        public static var allCases: [Self] {
            [.body, .subheadline, .headline, .caption1, .caption2, .callout, .footnote, .title1, .title2, .title3, .largeTitle]
        }
    }

    public extension NSFont {
        
        /// The height, in points, of text lines.
        var lineHeight: CGFloat {
            let ctFont = cleanedFont as CTFont
            return CTFontGetAscent(ctFont) + CTFontGetDescent(ctFont) + CTFontGetLeading(ctFont)
        }
        
        internal var baselineOffset: CGFloat {
            value(forKey: "_baselineOffsetForUILayout") as? CGFloat ?? 0.0
        }

        internal var descenderReal: CGFloat {
            let ctFont = cleanedFont as CTFont
            return -CTFontGetDescent(ctFont)
        }

        internal var ascenderReal: CGFloat {
            let ctFont = cleanedFont as CTFont
            return -CTFontGetAscent(ctFont)
        }

        internal var leadingReal: CGFloat {
            let ctFont = cleanedFont as CTFont
            return -CTFontGetLeading(ctFont)
        }

        var spc: CGFloat? {
            if let spc: CGFloat = getAssociatedValue(key: "spc", object: self) {
                return spc
            }
            let components = String(describing: self).components(separatedBy: "spc=")
            if components.count == 2 {
                var value = components[1]
                value.removeLast()
                let spc = CGFloat(value)
                FZSwiftUtils.set(associatedValue: spc, key: "spc", object: self)
                return spc
            }
            return nil
        }

        internal var cleanedFont: NSFont {
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
            return font
        }

        /**
         Returns the standard system font for the specified table row size and weight.

         - Parameters:
            - size: The table row size.
         */
        static func systemFont(forTableRowSize size: NSTableView.RowSizeStyle) -> NSFont {
            .systemFont(ofSize: systemFontSize(forTableRowSize: size))
        }

        /**
         Returns the standard system font for the specified table row size and weight.

         - Parameters:
            - size: The table row size.
            - weight: The weight of the font.
         */
        static func systemFont(forTableRowSize size: NSTableView.RowSizeStyle, weight: NSFont.Weight) -> NSFont {
            .systemFont(ofSize: systemFontSize(forTableRowSize: size), weight: weight)
        }

        internal static func systemFontSize(forTableRowSize tableRowSize: NSTableView.RowSizeStyle) -> CGFloat {
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
