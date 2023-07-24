//
//  ContentConfiguration+Font.swift
//  
//
//  Created by Florian Zand on 24.07.23.
//

/*
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import SwiftUI

@available(macOS 12.0, iOS 16.0, tvOS 16.0, watchOS 7.0, *)
public extension ContentConfiguration.SymbolConfiguration {
    struct FontConfigurationNew: Hashable {
        public typealias Design = Font.Design
        public typealias Weight = Font.Weight
        public typealias Style = Font.TextStyle
        
        /// A system font with the specified text style.
        public static func system(_ style: Style) -> Self {
            Self(style: style)
        }
        
        /// A system font with the specified point size.
        public static func system(size: CGFloat) -> Self {
            Self(size: size)
        }
        
        /// The font you use for body text.
        public static var body: Self { system(.body) }
        /// The font you use for callouts.
        public static var callout: Self { system(.callout) }
        /// The font you use for standard captions.
        public static var caption1: Self { system(.caption) }
        /// The font you use for alternate captions.
        public static var caption2: Self { system(.caption2) }
        /// The font you use in footnotes.
        public static var footnote: Self { system(.footnote) }
        /// The font you use for headings.
        public static var headline: Self { system(.headline) }
        /// The font you use for subheadings.
        public static var subheadline: Self { system(.subheadline) }
        /// The font you use for large titles.
        public static var largeTitle: Self { system(.largeTitle) }
        /// The font you use for first-level hierarchical headings.
        public static var title1: Self { system(.title) }
        /// The font you use for second-level hierarchical headings.
        public static var title2: Self { system(.title2) }
        /// The font you use for third-level hierarchical headings.
        public static var title3: Self { system(.title3) }
        
        /// Sets the weight of the font.
        public func weight(_ weight: Weight) -> Self {
            var new = self
            new.weight = weight
            return new
        }
        
        /// Sets the design of the font.
        public func design(_ design: Design) -> Self {
            var new = self
            new.design = design
            return new
        }
        
        internal var size: CGFloat? = nil
        internal var style: Style? = nil
        internal var weight: Weight = .regular
        internal var design: Design = .default
        
        internal var font: NSUIFont {
            if let style = style {
                return NSUIFont.system(style.nsUI).weight(weight.nSUI).design(design.nsUI)
            } else {
                return NSUIFont.system(size: size!, weight: .regular).weight(weight.nSUI).design(design.nsUI)
            }
        }
        
        internal var swiftui: Font {
            if let style = style {
                return Font.system(style, design: design).weight(weight)
            } else {
                return Font.system(size: size!, design: design).weight(weight)
            }
        }
        
        internal init(style: Style, weight: Weight = .regular, design: Design = .default) {
            self.style = style
            self.weight = weight
            self.design = design
        }
        
        internal init(size: CGFloat, weight: Weight = .regular, design: Design = .default) {
            self.size = size
            self.weight = weight
            self.design = design
        }
    }
}

internal extension Font.Design {
    var nsUI: NSUIFontDescriptor.SystemDesign {
        switch self {
        case .default: return .default
        case .serif: return .serif
        case .rounded: return .rounded
        case .monospaced: return .monospaced
        @unknown default: return .default
        }
    }
}

internal extension Font.Weight {
    var nSUI: NSUIFont.Weight {
        switch self {
        case .black: return .black
        case .bold: return .bold
        case .heavy: return .heavy
        case .light: return .light
        case .medium: return .medium
        case .regular: return .regular
        case .semibold: return .semibold
        case .thin: return .thin
        case .ultraLight: return .ultraLight
        default: return .regular
        }
    }
}

internal extension NSUIFont {
    func design(_ design: NSUIFontDescriptor.SystemDesign) -> NSUIFont {
        if let descriptor = fontDescriptor.withDesign(design) {
            return NSUIFont(descriptor: descriptor, size: 0) ?? self
        }
        return self
    }
}

@available(macOS 11.0, iOS 10.0, *)
internal extension Font.TextStyle {
    var nsUI: NSUIFont.TextStyle {
        switch self {
        case .largeTitle: return .largeTitle
        case .title: return .title1
        case .title2: return .title2
        case .title3: return .title3
        case .headline: return .headline
        case .subheadline: return .subheadline
        case .body: return .body
        case .callout: return .callout
        case .footnote: return .footnote
        case .caption: return .caption1
        case .caption2: return .caption2
        @unknown default: return .body
        }
    }
}
*/
