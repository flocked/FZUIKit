//
//  NSFont+.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

public extension NSFont {
    /// The standard system font, with default size.
    static var systemFont: NSUIFont {
        .systemFont(ofSize: 0)
    }
    
    /// The font used for standard interface labels, with default size.
    static var label: NSFont {
        .labelFont(ofSize: 0)
    }

    /// The font used for standard interface items, such as button labels, menu items, and so on, with default size.
    static var message: NSFont {
        .messageFont(ofSize: 0)
    }

    /// The font used for menu bar items, with default size.
    static var menuBar: NSFont {
        .menuBarFont(ofSize: 0)
    }

    /// The font used for menu items, with default size.
    static var menu: NSFont {
        .menuFont(ofSize: 0)
    }

    /// The font used for the content of controls, with default size.
    static var controlContent: NSFont {
        .controlContentFont(ofSize: 0)
    }

    /// The font used for window title bars, with default size.
    static var titleBar: NSFont {
        .titleBarFont(ofSize: 0)
    }

    /// The font used for palette window title bars, with default size.
    static var palette: NSFont {
        .paletteFont(ofSize: 0)
    }

    /// The font used for tool tips labels, with default size.
    static var toolTips: NSFont {
        .toolTipsFont(ofSize: 0)
    }

    /**
     The actual line height used when rendering text with this font.
     
     This value represents the full vertical distance from the highest [ascender](https://developer.apple.com/documentation/appkit/nsfont/ascender) to the lowest [descender](https://developer.apple.com/documentation/appkit/nsfont/descender), including any built-in [leading](https://developer.apple.com/documentation/appkit/nsfont/leading). It corresponds to the real line spacing the font provides when drawing multiline text.
     */
    var lineHeight: CGFloat {
        if let lineHeight = value(forKeySafely: "lineHeight") as? Double {
            return lineHeight
        }
        let ctFont = cleanedFont as CTFont
        return CTFontGetAscent(ctFont) + CTFontGetDescent(ctFont) + CTFontGetLeading(ctFont)
    }
    
    /**
     The default line height that can be used for layouting UI components.
     
     This value is typically a rounded or adjusted line height that AppKit uses for consistent
     vertical alignment in controls like `NSTextField` and `NSButton`.
     
     This can be useful when implementing custom views or controls that need to match AppKit’s default line height behavior.
     
     It is generally calculated based on font metrics such as [ascender](https://developer.apple.com/documentation/appkit/nsfont/ascender), [descender](https://developer.apple.com/documentation/appkit/nsfont/descender), and [leading](https://developer.apple.com/documentation/appkit/nsfont/leading), and ensures text aligns nicely across different fonts and sizes.
     */
    var defaultLineHeight: Double {
        value(forKeySafely: "defaultLineHeightForFont") as? Double ?? lineHeight
    }
    
    /**
     The default line height that can be used for layouting UI components.
     
     This value is typically a rounded or adjusted line height that AppKit uses for consistent
     vertical alignment in controls like `NSTextField` and `NSButton`.
     
     This can be useful when implementing custom views or controls that need to match AppKit’s default line height behavior.
     
     It is generally calculated based on font metrics such as [ascender](https://developer.apple.com/documentation/appkit/nsfont/ascender), [descender](https://developer.apple.com/documentation/appkit/nsfont/descender), and [leading](https://developer.apple.com/documentation/appkit/nsfont/leading), and ensures text aligns nicely across different fonts and sizes.
     */
    var defaultLineHeightForUILayout: Double {
        value(forKeySafely: "_defaultLineHeightForUILayout") as? Double ?? lineHeight
    }

    /**
     Returns the baseline offset used by AppKit to align text within UI components.

     This value represents the vertical distance from the font’s baseline to the visual alignment point used in layout. It is used by AppKit to consistently align text across various controls like `NSTextField`, `NSButton`, and `NSLabel`.

     This can be useful when implementing custom views or controls that need to match AppKit’s default text alignment behavior.
     */
    var baselineOffsetForUILayout: CGFloat {
        value(forKeySafely: "_baselineOffsetForUILayout") as? CGFloat ?? 0.0
    }
    
    /// Returns the width of the space character in points.
    var spaceCharacterWidth: CGFloat {
        var glyph = CGGlyph()
        guard let cgFont = cgFont else { return 0.0 }
        let fontRef = CTFontCreateWithGraphicsFont(cgFont, pointSize, nil, nil)
        guard CTFontGetGlyphsForCharacters(fontRef, [0x20], &glyph, 1) else { return 0.0 }
        var advancement = CGSize.zero
        CTFontGetAdvancesForGlyphs(fontRef, .horizontal, [glyph], &advancement, 1)
        return (advancement.width * 100).rounded() / 100
        return advancement.width
    }

    /// `CGFont` representation of the font.
    var cgFont: CGFont? {
        guard let name = fontDescriptor.name else { return nil }
        return CGFont(name as CFString)
    }
    
    private var descenderReal: CGFloat {
        let ctFont = cleanedFont as CTFont
        return -CTFontGetDescent(ctFont)
    }

    private var ascenderReal: CGFloat {
        let ctFont = cleanedFont as CTFont
        return -CTFontGetAscent(ctFont)
    }

    private var leadingReal: CGFloat {
        let ctFont = cleanedFont as CTFont
        return -CTFontGetLeading(ctFont)
    }

    private var cleanedFont: NSFont {
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

@available(macOS 11.0, *)
extension NSFont.TextStyle: CaseIterable {
    /// A collection of all text style values.
    public static var allCases: [Self] {
        [.body, .subheadline, .headline, .caption1, .caption2, .callout, .footnote, .title1, .title2, .title3, .largeTitle]
    }
}

#endif
