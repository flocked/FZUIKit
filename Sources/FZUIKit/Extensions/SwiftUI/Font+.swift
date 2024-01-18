//
//  Font+.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

import SwiftUI

#if os(macOS)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

public extension Font {
    /// Creates a font from the specified font object.
    init(_ font: NSUIFont) {
        self = Font(font as CTFont)
    }
}

public extension NSUIFont {
    /// A SwiftUI representation of the font.
    var swiftUI: Font {
        /*
         if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
             if let textStyle = fontDescriptor.textStyle {
                 var font = Font.system(textStyle.swiftUI, design: fontDescriptor.design?.swiftUI, weight: fontDescriptor.weight?.swiftUI)
             }
         }
          */
        Font(self)
    }
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension Font {
    func width(_ width: Font.Width?) -> Font {
        if let width = width {
            return self.width(width)
        }
        return self
    }
}

@available(macOS 11.0, iOS 14.0, tvOS 12.2, watchOS 7.0, *)
public extension NSUIFont.TextStyle {
    /// A SwiftUI representation of the text style.
    var swiftUI: Font.TextStyle {
        switch self {
        #if os(macOS) || os(iOS)
            case .largeTitle: return .largeTitle
        #endif
        case .title1: return .title
        case .title2: return .title2
        case .title3: return .title3
        case .headline: return .headline
        case .subheadline: return .subheadline
        case .body: return .body
        case .callout: return .callout
        case .footnote: return .footnote
        case .caption1: return .caption
        case .caption2: return .caption2
        default:
            return .body
        }
    }
}

@available(macOS 11.0, iOS 13.0, watchOS 7.0, *)
public extension NSUIFontDescriptor.SystemDesign {
    /// A SwiftUI representation of the system design.
    var swiftUI: Font.Design {
        switch self {
        case .monospaced: return .monospaced
        case .rounded: return .rounded
        case .serif: return .serif
        default: return Font.Design.default
        }
    }
}

@available(macOS 11.0, iOS 13.0, *)
public extension NSUIImage.SymbolScale {
    /// A SwiftUI representation of the symbol scale.
    var swiftUI: Image.Scale {
        switch self {
        case .medium: return .medium
        case .large: return .large
        case .small: return .small
        default: return .medium
        }
    }
}

@available(macOS 11.0, iOS 13.0, *)
public extension NSUIImage.SymbolWeight {
    /// A SwiftUI representation of the symbol weight.
    var swiftUI: Font.Weight {
        switch self {
        case .ultraLight: return .ultraLight
        case .thin: return .thin
        case .light: return .light
        case .regular: return .regular
        case .medium: return .medium
        case .heavy: return .heavy
        case .semibold: return .semibold
        case .bold: return .bold
        case .black: return .black
        default: return .regular
        }
    }
}

public extension NSUIFont.Weight {
    /// A SwiftUI representation of the font weight.
    var swiftUI: Font.Weight {
        switch self {
        case .ultraLight: return .ultraLight
        case .thin: return .thin
        case .light: return .light
        case .regular: return .regular
        case .medium: return .medium
        case .heavy: return .heavy
        case .semibold: return .semibold
        case .bold: return .bold
        case .black: return .black
        default: return .regular
        }
    }
}
