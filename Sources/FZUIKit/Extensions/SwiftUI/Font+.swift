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
    init(_ font: NSUIFont) {
        self = Font(font as CTFont)
    }

    var lineHeight: CGFloat {
        NSUIFont.preferredFont(from: self).lineHeight
    }

    var pointSize: CGFloat {
        NSUIFont.preferredFont(from: self).pointSize
    }
}

public extension NSUIFont {
    var swiftUI: Font {
        return Font(self)
    }

    static func preferredFont(from font: Font) -> NSUIFont {
        let font = font.weight(.regular)
        let nsUIFont: NSUIFont
        if #available(macOS 11.0, iOS 14.0, *) {
            switch font {
            case .largeTitle.weight(.regular):
                nsUIFont = .largeTitle
            case .title.weight(.regular):
                nsUIFont = .title
            case .title2.weight(.regular):
                nsUIFont = .title2
            case .title3.weight(.regular):
                nsUIFont = .title3
            case .caption2.weight(.regular):
                nsUIFont = .caption2
            case .headline.weight(.regular):
                nsUIFont = .headline
            case .subheadline.weight(.regular):
                nsUIFont = .subheadline
            case .callout.weight(.regular):
                nsUIFont = .callout
            case .caption.weight(.regular):
                nsUIFont = .caption

            case .footnote.weight(.regular):
                nsUIFont = .footnote
            case .body.weight(.regular):
                nsUIFont = .body
            default:
                nsUIFont = .body
            }
        } else {
            switch font {
            case .largeTitle.weight(.regular):
                nsUIFont = .largeTitle
            case .title.weight(.regular):
                nsUIFont = .title
            case .headline.weight(.regular):
                nsUIFont = .headline
            case .subheadline.weight(.regular):
                nsUIFont = .subheadline
            case .callout.weight(.regular):
                nsUIFont = .callout
            case .caption.weight(.regular):
                nsUIFont = .caption
            case .footnote.weight(.regular):
                nsUIFont = .footnote
            case .body.weight(.regular):
                nsUIFont = .body
            default:
                nsUIFont = .body
            }
        }
        return nsUIFont
    }
}

@available(macOS 11.0, iOS 14.0, tvOS 12.2, watchOS 5.2, *)
public extension NSUIFont.TextStyle {
    var swiftUI: Font.TextStyle {
        switch self {
        case .largeTitle: return .largeTitle
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

@available(macOS 11.0, iOS 13.0, *)
public extension NSUIFontDescriptor.SystemDesign {
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

/*
 public extension Font {
 func weight(ui weight: NSUIFont.Weight) -> Font {
 switch weight {
 case .ultraLight: return self.weight(.ultraLight)
 case .thin: return self.weight(.thin)
 case .light: return self.weight(.light)
 case .regular: return self.weight(.regular)
 case .medium: return self.weight(.medium)
 case .heavy: return self.weight(.heavy)
 case .semibold: return self.weight(.semibold)
 case .bold: return self.weight(.bold)
 case .black: return self.weight(.black)
 default:
 return self
 }
 }
 }
 */
