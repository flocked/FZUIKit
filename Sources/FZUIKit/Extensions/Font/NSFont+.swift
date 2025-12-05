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
    static var systemFont: NSFont {
        .systemFont(ofSize: 0)
    }
    
    /// Returns the standard system font with the specified size.
    static func systemFont(ofSize size: NSControl.ControlSize, weight: Weight = .regular, design: SystemDesign = .default) -> NSFont {
        .systemFont(ofSize: NSFont.systemFontSize(for: size), weight: weight, design: design)
    }
    
    /// Returns the font used for standard interface labels in the specified size.
    static func labelFont(ofSize size: NSControl.ControlSize) -> NSFont {
        .labelFont(ofSize: NSFont.systemFontSize(for: size))
    }
    
    /// Returns the font used for standard interface items, such as button labels, menu items, and so on, in the specified size.
    static func messageFont(ofSize size: NSControl.ControlSize) -> NSFont {
        .messageFont(ofSize: NSFont.systemFontSize(for: size))
    }
    
    /// Returns the font used for menu bar items, in the specified size.
    static func menuBarFont(ofSize size: NSControl.ControlSize) -> NSFont {
        .menuBarFont(ofSize: NSFont.systemFontSize(for: size))
    }
    
    /// Returns the font used for menu items, in the specified size.
    static func menuFont(ofSize size: NSControl.ControlSize) -> NSFont {
        .menuFont(ofSize: NSFont.systemFontSize(for: size))
    }
    
    /// Returns the font used for the content of controls in the specified size.
    static func controlContentFont(ofSize size: NSControl.ControlSize) -> NSFont {
        .controlContentFont(ofSize: NSFont.systemFontSize(for: size))
    }
    
    /// Returns the font used for window title bars, in the specified size.
    static func titleBarFont(ofSize size: NSControl.ControlSize) -> NSFont {
        .titleBarFont(ofSize: NSFont.systemFontSize(for: size))
    }
    
    /// Returns the font used for palette window title bars, in the specified size.
    static func paletteFont(ofSize size: NSControl.ControlSize) -> NSFont {
        .paletteFont(ofSize: NSFont.systemFontSize(for: size))
    }
    
    /// Returns the font used for tool tips labels, in the specified size.
    static func toolTipsFont(ofSize size: NSControl.ControlSize) -> NSFont {
        .toolTipsFont(ofSize: NSFont.systemFontSize(for: size))
    }
    
    /// The font used for standard interface labels, with default size.
    static var labelFont: NSFont {
        .labelFont(ofSize: 0)
    }

    /// The font used for standard interface items, such as button labels, menu items, and so on, with default size.
    static var messageFont: NSFont {
        .messageFont(ofSize: 0)
    }

    /// The font used for menu bar items, with default size.
    static var menuBarFont: NSFont {
        .menuBarFont(ofSize: 0)
    }

    /// The font used for menu items, with default size.
    static var menuFont: NSFont {
        .menuFont(ofSize: 0)
    }

    /// The font used for the content of controls, with default size.
    static var controlContentFont: NSFont {
        .controlContentFont(ofSize: 0)
    }

    /// The font used for window title bars, with default size.
    static var titleBarFont: NSFont {
        .titleBarFont(ofSize: 0)
    }

    /// The font used for palette window title bars, with default size.
    static var paletteFont: NSFont {
        .paletteFont(ofSize: 0)
    }

    /// The font used for tool tips labels, with default size.
    static var toolTipsFont: NSFont {
        .toolTipsFont(ofSize: 0)
    }
    
    /**
     The actual line height used when rendering text with this font.
     
     This value represents the full vertical distance from the highest [ascender](https://developer.apple.com/documentation/appkit/nsfont/ascender) to the lowest [descender](https://developer.apple.com/documentation/appkit/nsfont/descender), including any built-in [leading](https://developer.apple.com/documentation/appkit/nsfont/leading). It corresponds to the real line spacing the font provides when drawing multiline text.
     */
    var lineHeight: CGFloat {
        if let lineHeight = value(forKeySafely: "lineHeight") as? CGFloat {
            return lineHeight
        }
        let ctFont = cleanedFont
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
    
    private var descenderReal: CGFloat {
        -CTFontGetDescent(cleanedFont)
    }

    private var ascenderReal: CGFloat {
        -CTFontGetAscent(cleanedFont)
    }

    private var leadingReal: CGFloat {
        -CTFontGetLeading(cleanedFont)
    }

    var cleanedFont: NSFont {
        var attributes = fontDescriptor.fontAttributes
        guard attributes.removeValue(forKey: .sizeCategory) != nil else { return self }
        if let usageValue = attributes[.uiUsage] as? String {
            if usageValue == "UICTFontTextStyleHeadline" {
                attributes[.uiUsage] = "CTFontDemiUsage"
            } else if usageValue.contains("UICTFontTextStyle") {
                attributes[.uiUsage] = "CTFontRegularUsage"
            }
        }
        return NSFont(descriptor: NSUIFontDescriptor(fontAttributes: attributes), size: 0)!
    }
}

#endif
