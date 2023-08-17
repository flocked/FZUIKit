//
//  NSUIFont+.swift
//
//
//  Created by Florian Zand on 18.05.22.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public extension NSUIFont {
    /// A font with the alternate caption text style.
    static var caption2: NSUIFont {
        if #available(macOS 11.0, iOS 12.2, tvOS 12.2, watchOS 5.2, *) {
            return .preferredFont(forTextStyle: .caption2)
        }
        return .systemFont(ofSize: NSUIFont.systemFontSize - 6)
    }

    /// A font with the caption text style.
    static var caption: NSUIFont {
        if #available(macOS 11.0, iOS 12.2, tvOS 12.2, watchOS 5.2, *) {
            return .preferredFont(forTextStyle: .caption1)
        }
        return .systemFont(ofSize: NSUIFont.systemFontSize - 5)
    }

    /// A font with the footnote text style.
    static var footnote: NSUIFont {
        if #available(macOS 11.0, iOS 12.2, tvOS 12.2, watchOS 5.2, *) {
            return .preferredFont(forTextStyle: .footnote)
        }
        return .systemFont(ofSize: NSUIFont.systemFontSize - 4)
    }

    /// A font with the callout text style.
    static var callout: NSUIFont {
        if #available(macOS 11.0, iOS 12.2, tvOS 12.2, watchOS 5.2, *) {
            return .preferredFont(forTextStyle: .callout)
        }
        return .systemFont(ofSize: NSUIFont.systemFontSize - 1)
    }

    /// A font with the body text style.
    static var body: NSUIFont {
        if #available(macOS 11.0, iOS 12.2, tvOS 12.2, watchOS 5.2, *) {
            return .preferredFont(forTextStyle: .body)
        }
        return .systemFont(ofSize: NSUIFont.systemFontSize)
    }

    /// A font with the subheadline text style.
    static var subheadline: NSUIFont {
        if #available(macOS 11.0, iOS 12.2, tvOS 12.2, watchOS 5.2, *) {
            return .preferredFont(forTextStyle: .subheadline)
        }
        return .systemFont(ofSize: NSUIFont.systemFontSize - 2)
    }

    /// A font with the headline text style.
    static var headline: NSUIFont {
        if #available(macOS 11.0, iOS 12.2, tvOS 12.2, watchOS 5.2, *) {
            return .preferredFont(forTextStyle: .headline)
        }
        return .systemFont(ofSize: NSUIFont.systemFontSize - 2, weight: .semibold)
    }

    /// Create a font for third level hierarchical headings.
    static var title3: NSUIFont {
        if #available(macOS 11.0, iOS 12.2, tvOS 12.2, watchOS 5.2, *) {
            return .preferredFont(forTextStyle: .title3)
        }
        return .systemFont(ofSize: NSUIFont.systemFontSize + 3)
    }

    /// Create a font for second level hierarchical headings.
    static var title2: NSUIFont {
        if #available(macOS 11.0, iOS 12.2, tvOS 12.2, watchOS 5.2, *) {
            return .preferredFont(forTextStyle: .title2)
        }
        return .systemFont(ofSize: NSUIFont.systemFontSize + 5)
    }

    /// A font with the title text style.
    static var title: NSUIFont {
        if #available(macOS 11.0, iOS 12.2, tvOS 12.2, watchOS 5.2, *) {
            return .preferredFont(forTextStyle: .title1)
        }
        return .systemFont(ofSize: NSUIFont.systemFontSize + 11)
    }

    /// A font with the large title text style.
    static var largeTitle: NSUIFont {
        if #available(macOS 11.0, iOS 12.2, tvOS 12.2, watchOS 5.2, *) {
            return .preferredFont(forTextStyle: .largeTitle)
        }
        return .systemFont(ofSize: NSUIFont.systemFontSize + 17)
    }
}

public extension NSUIFont {
    /**
     Returns the standard system font with the specified size, design and weight.

     - Parameters:
        - size: The font size. If you specify 0.0 or a negative number for this parameter, the method returns the system font at the default size.
        - weight: The font weight.
        - design: The font design.
     */
    static func systemFont(ofSize size: CGFloat, weight: NSUIFont.Weight, design: NSUIFontDescriptor.SystemDesign = .default) -> NSUIFont {
        let descriptor = NSUIFont.systemFont(ofSize: size, weight: weight).fontDescriptor.withDesign(design)!
        #if os(macOS)
        return NSUIFont(descriptor: descriptor, size: size)!
        #else
        return NSUIFont(descriptor: descriptor, size: size)
        #endif
    }

    @available(macOS 11.0, iOS 12.2, tvOS 12.2, watchOS 5.2, *)
    /**
     Returns the standard system font for the specified style and design.

     - Parameters:
        - textStyle: The font text style.
        - design: The font design.
     */
    static func systemFont(_ textStyle: NSUIFont.TextStyle, design: NSUIFontDescriptor.SystemDesign = .default) -> NSUIFont {
        #if os(macOS)
        let descriptor = NSUIFontDescriptor.preferredFontDescriptor(forTextStyle: textStyle).withDesign(design)!
        return NSUIFont(descriptor: descriptor, size: 0)!
        #else
        let descriptor = NSUIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle).withDesign(design)!
        return NSUIFont(descriptor: descriptor, size: 0)
        #endif
    }

    /// Applies the specified weight to the font.
    func weight(_ weight: NSUIFont.Weight) -> NSUIFont {
        addingAttributes([
            NSUIFontDescriptor.AttributeName.traits: [
                NSUIFontDescriptor.TraitKey.weight: weight.rawValue,
            ],
        ])
    }

    /// The font with a italic style.
    var italic: NSUIFont {
        #if os(macOS)
        includingSymbolicTraits(.italic)
        #else
        includingSymbolicTraits(.traitItalic)
        #endif
    }

    /// The font characters with same width.
    var monospaced: NSUIFont {
        #if os(macOS)
        includingSymbolicTraits(.monoSpace)
        #else
        includingSymbolicTraits(.traitMonoSpace)
        #endif
    }

    /// The font with a bold style.
    var bold: NSUIFont {
        #if os(macOS)
        includingSymbolicTraits(.bold)
        #else
        includingSymbolicTraits(.traitBold)
        #endif
    }

    /// The font with a serif design.
    var serif: NSUIFont {
        if let descriptor = fontDescriptor.withDesign(.serif) {
            #if os(macOS)
                return NSUIFont(descriptor: descriptor, size: 0) ?? self
            #elseif canImport(UIKit)
                return NSUIFont(descriptor: descriptor, size: 0)
            #endif
        }
        return self
    }

    /// The font with a rounded appearance.
    var rounded: NSUIFont {
        if let descriptor = fontDescriptor.withDesign(.rounded) {
        #if os(macOS)
            return NSUIFont(descriptor: descriptor, size: 0) ?? self
        #elseif canImport(UIKit)
            return NSUIFont(descriptor: descriptor, size: 0)
        #endif
        }
        return self
    }

    /// Applies the specified leading value to the font.
    func leading(_ leading: FontLeading) -> NSUIFont {
        switch leading {
        case .standard:
            #if os(macOS)
            return withoutSymbolicTraits([.looseLeading, .tightLeading])
            #else
            return withoutSymbolicTraits([.traitLooseLeading, .traitTightLeading])
            #endif
        case .loose:
            #if os(macOS)
            return includingSymbolicTraits(.looseLeading, without: .tightLeading)
            #else
            return includingSymbolicTraits(.traitLooseLeading, without: .traitTightLeading)
            #endif
        case .tight:
            #if os(macOS)
            return includingSymbolicTraits(.tightLeading, without: .looseLeading)
            #else
            return includingSymbolicTraits(.traitTightLeading, without: .traitLooseLeading)
            #endif
        }
    }
    
    

    /// Applies the specified width value to the font.
    func width(_ width: FontWidth) -> NSUIFont {
        switch width {
        case .standard:
            #if os(macOS)
            return withoutSymbolicTraits([.expanded, .condensed])
            #else
            return withoutSymbolicTraits([.traitExpanded, .traitCondensed])
            #endif
        case .expanded:
            #if os(macOS)
            return includingSymbolicTraits( .expanded , without: .condensed)
            #else
            return includingSymbolicTraits(.traitExpanded, without: .traitCondensed)
            #endif
            default:
            #if os(macOS)
            return includingSymbolicTraits( .condensed , without: .expanded)
            #else
            return includingSymbolicTraits(.traitCondensed, without: .traitExpanded)
            #endif
        }
    }
    
    /// The font width.
    enum FontWidth {
        /// The font uses a standard leading value.
        case compressed
        /// The font uses a leading value that’s greater than the default.
        case condensed
        /// The font uses a leading value that’s less than the default.
        case expanded
        case standard
    }

    /// The font leading.
    enum FontLeading {
        /// The font uses a standard leading value.
        case standard
        /// The font uses a leading value that’s greater than the default.
        case loose
        /// The font uses a leading value that’s less than the default.
        case tight
    }
    
    /// Applies the specified design to the font.
    func design(_ design: NSUIFontDescriptor.SystemDesign) -> NSUIFont {
        let descriptor = self.fontDescriptor.withDesign(design)!
        #if os(macOS)
        return NSUIFont(descriptor: descriptor, size: self.pointSize)!
        #else
        return NSUIFont(descriptor: descriptor, size: self.pointSize)
        #endif
    }
    
    /// Applies the specified symbolic traits to the font.
    func symbolicTraits(_ symbolicTraits: NSUIFontDescriptor.SymbolicTraits) -> NSUIFont {
        var descriptor = fontDescriptor.withSymbolicTraits(symbolicTraits)
        #if os(macOS)
        return NSUIFont(descriptor: descriptor, size: 0)!
        #else
        return NSUIFont(descriptor: descriptor!, size: 0)
        #endif
    }

    
    internal func includingSymbolicTraits(_ symbolicTraits: NSUIFontDescriptor.SymbolicTraits, without: NSUIFontDescriptor.SymbolicTraits? = nil) -> NSUIFont {
        var traits = fontDescriptor.symbolicTraits
        guard traits.contains(symbolicTraits) == false else { return self }
        if let without = without {
            traits.remove(without)
        }
        traits.insert(symbolicTraits)
        return self.symbolicTraits(symbolicTraits)
    }

    internal func withoutSymbolicTraits(_ symbolicTraits: NSUIFontDescriptor.SymbolicTraits) -> NSUIFont {
        var traits = fontDescriptor.symbolicTraits
        guard traits.contains(symbolicTraits) == true else { return self }
        traits.remove(symbolicTraits)
        return self.symbolicTraits(symbolicTraits)
    }

    internal func addingAttributes(_ attributes: [NSUIFontDescriptor.AttributeName: Any]) -> NSUIFont {
        let font = NSUIFont(descriptor: fontDescriptor.addingAttributes(attributes), size: pointSize)
        #if os(macOS)
        return font!
        #else
        return font
        #endif
    }
}
