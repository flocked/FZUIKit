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
    /// The standard system font with standard system size.
    static var systemFont = NSUIFont.systemFont(ofSize: NSUIFont.systemFontSize)
    
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

    #if os(macOS) || os(iOS)
        /// A font with the large title text style.
        static var largeTitle: NSUIFont {
            if #available(macOS 11.0, iOS 12.2, tvOS 12.2, watchOS 5.2, *) {
                return .preferredFont(forTextStyle: .largeTitle)
            }
            return .systemFont(ofSize: NSUIFont.systemFontSize + 17)
        }
    #endif
    
    #if os(macOS)
    /// The current font with the specified font matrix.
    func matrix(_ matrix: AffineTransform) -> NSUIFont {
        NSUIFont(descriptor: fontDescriptor.withMatrix(matrix), size: 0) ?? self
    }
    #else
    /// The current font with the specified font matrix.
    func matrix(_ matrix: CGAffineTransform) -> NSUIFont {
        NSUIFont(descriptor: fontDescriptor.withMatrix(matrix), size: 0)
    }
    #endif
    
    /// The current font with the specified design style.
    func design(_ design: NSUIFontDescriptor.SystemDesign) -> NSUIFont {
        guard let descriptor = fontDescriptor.withDesign(design) else { return self }
        return NSUIFont(descriptor) ?? self
    }
    
    /// The current font with the specified symbolic traits taking precedence over the existing ones.
    func withSymbolicTraits(_ symbolTraits: NSUIFontDescriptor.SymbolicTraits) -> NSUIFont {
        #if os(macOS)
        NSUIFont(descriptor: fontDescriptor.withSymbolicTraits(symbolTraits), size: 0) ?? self
        #else
        guard let descriptor = fontDescriptor.withSymbolicTraits(symbolTraits) else { return self }
        return NSUIFont(descriptor: descriptor, size: 0)
        #endif
    }
    
    /// The current font with the specified symbolic traits.
    func symbolicTraits(_ symbolTraits: NSUIFontDescriptor.SymbolicTraits) -> NSUIFont {
        var attributes = fontDescriptor.fontAttributes
        attributes[.traits] = symbolTraits
        return NSUIFont(NSUIFontDescriptor(fontAttributes: attributes)) ?? self
    }
    
    /// The current font with the specified face.
    func face(_ face: String) -> NSUIFont {
        NSUIFont(fontDescriptor.withFace(face)) ?? self
    }
    
    /// The current font with the specified font weight.
    func weight(_ weight: NSUIFont.Weight) -> NSUIFont {
        NSUIFont(fontDescriptor.withWeight(weight)) ?? self
    }
    
    internal convenience init?(_ descriptor: NSUIFontDescriptor, size: CGFloat = 0) {
        self.init(descriptor: descriptor, size: size)
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
    static func systemFont(ofSize size: CGFloat, weight: NSUIFont.Weight, design: NSUIFontDescriptor.SystemDesign) -> NSUIFont {
        NSUIFont.systemFont(ofSize: size, weight: weight).design(design)
    }

    @available(macOS 11.0, iOS 12.2, tvOS 12.2, watchOS 5.2, *)
    /**
     Returns the standard system font for the specified style and design.

     - Parameters:
        - textStyle: The font text style.
        - design: The font design.
     */
    static func systemFont(_ textStyle: NSUIFont.TextStyle, design: NSUIFontDescriptor.SystemDesign = .default) -> NSUIFont {
        NSUIFont.preferredFont(forTextStyle: textStyle).design(design)
    }

    /// The font with a italic style.
    var italic: NSUIFont {
        includingSymbolicTraits(.nsUIItalic)
    }
    
    /// The font with a italic style.doc://com.apple.documentation/documentation/appkit/nsimage/symbolconfiguration/3656511-init
    func italic(_ italic: Bool) -> NSUIFont {
        italic ? self.italic : withoutSymbolicTraits(.nsUIItalic)
    }

    /// The font characters with same width.
    var monospaced: NSUIFont {
        includingSymbolicTraits(.nsUIMonoSpace)
    }
    
    /// The font characters with same width.
    func monospaced(_ monospaced: Bool) -> NSUIFont {
        monospaced ? self.monospaced : withoutSymbolicTraits(.nsUIMonoSpace)
    }

    /// The font with a bold style.
    var bold: NSUIFont {
        includingSymbolicTraits(.nsUIBold)
    }
    
    /// The font with a bold style.
    func bold(_ bold: Bool) -> NSUIFont {
        bold ? self.bold : withoutSymbolicTraits(.nsUIBold)
    }
    
    /// The font with a serif design.
    @available(macOS 10.15, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    var serif: NSUIFont {
        design(.serif)
    }
    
    /// The font with a serif design.
    @available(macOS 10.15, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    func serif(_ serif: Bool) -> NSUIFont {
        if serif {
            return self.serif
        } else if fontDescriptor.design == .serif {
            return design(.default)
        }
        return self
    }

    /// The font with a rounded appearance.
    var rounded: NSUIFont {
        design(.rounded)
    }
    
    func rounded(_ rounded: Bool) -> NSUIFont {
        if rounded {
            return self.rounded
        } else if fontDescriptor.design == .rounded {
            return design(.default)
        }
        return self
    }
    
    /*
    /// The leading value of the font.
    var leading: FontLeading {
        let symbolicTraits = fontDescriptor.symbolicTraits
        #if os(macOS)
        if symbolicTraits.contains(.looseLeading) {
            return .loose
        } else if symbolicTraits.contains(.tightLeading) {
            return .tight
        }
        return .standard
        #else
        if symbolicTraits.contains(.traitLooseLeading) {
            return .loose
        } else if symbolicTraits.contains(.traitTightLeading) {
            return .tight
        }
        return .standard
        #endif
    }
     */

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
    
    /*
    /// The width of the font’s characters.
    var width: FontWidth {
        let symbolicTraits = fontDescriptor.symbolicTraits
        #if os(macOS)
        if symbolicTraits.contains(.expanded) {
            return .expanded
        } else if symbolicTraits.contains(.condensed) {
            return .condensed
        }
        return .standard
        #else
        if symbolicTraits.contains(.traitExpanded) {
            return .expanded
        } else if symbolicTraits.contains(.traitCondensed) {
            return .condensed
        }
        return .standard
        #endif
    }
     */

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
                return includingSymbolicTraits(.expanded, without: .condensed)
            #else
                return includingSymbolicTraits(.traitExpanded, without: .traitCondensed)
            #endif
        case .condensed:
            #if os(macOS)
                return includingSymbolicTraits(.condensed, without: .expanded)
            #else
                return includingSymbolicTraits(.traitCondensed, without: .traitExpanded)
            #endif
        }
    }

    /// The width of the font’s characters.
    enum FontWidth {
        /// The font uses a leading value that’s greater than the default.
        case condensed
        /// The font uses a leading value that’s less than the default.
        case expanded
        /// The font uses a standard leading value.
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

    internal func includingSymbolicTraits(_ symbolicTraits: NSUIFontDescriptor.SymbolicTraits, without: NSUIFontDescriptor.SymbolicTraits? = nil) -> NSUIFont {
        var traits = fontDescriptor.symbolicTraits
        guard traits.contains(symbolicTraits) == false else { return self }
        if let without = without {
            traits.remove(without)
        }
        traits.insert(symbolicTraits)
        return withSymbolicTraits(symbolicTraits)
    }

    internal func withoutSymbolicTraits(_ symbolicTraits: NSUIFontDescriptor.SymbolicTraits) -> NSUIFont {
        var traits = fontDescriptor.symbolicTraits
        guard traits.contains(symbolicTraits) == true else { return self }
        traits.remove(symbolicTraits)
        return withSymbolicTraits(symbolicTraits)
    }

    internal func addingAttributes(_ attributes: [NSUIFontDescriptor.AttributeName: Any]) -> NSUIFont {
        let font = NSUIFont(descriptor: fontDescriptor.addingAttributes(attributes), size: 0)
        #if os(macOS)
            return font!
        #else
            return font
        #endif
    }
}

#if os(tvOS) || os(watchOS)
    extension NSUIFont {
        static var systemFontSize: CGFloat {
            UIFont.preferredFont(forTextStyle: .body).pointSize
        }
    }
#endif
