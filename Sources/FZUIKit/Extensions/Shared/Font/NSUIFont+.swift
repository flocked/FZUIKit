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
    static var caption2: NSUIFont {
        if #available(macOS 11.0, iOS 12.2, tvOS 12.2, watchOS 5.2, *) {
            return .preferredFont(forTextStyle: .caption2)
        }
        return .systemFont(ofSize: NSUIFont.systemFontSize - 6)
    }

    static var caption: NSUIFont {
        if #available(macOS 11.0, iOS 12.2, tvOS 12.2, watchOS 5.2, *) {
            return .preferredFont(forTextStyle: .caption1)
        }
        return .systemFont(ofSize: NSUIFont.systemFontSize - 5)
    }

    static var footnote: NSUIFont {
        if #available(macOS 11.0, iOS 12.2, tvOS 12.2, watchOS 5.2, *) {
            return .preferredFont(forTextStyle: .footnote)
        }
        return .systemFont(ofSize: NSUIFont.systemFontSize - 4)
    }

    static var callout: NSUIFont {
        if #available(macOS 11.0, iOS 12.2, tvOS 12.2, watchOS 5.2, *) {
            return .preferredFont(forTextStyle: .callout)
        }
        return .systemFont(ofSize: NSUIFont.systemFontSize - 1)
    }

    static var body: NSUIFont {
        if #available(macOS 11.0, iOS 12.2, tvOS 12.2, watchOS 5.2, *) {
            return .preferredFont(forTextStyle: .body)
        }
        return .systemFont(ofSize: NSUIFont.systemFontSize)
    }

    static var subheadline: NSUIFont {
        if #available(macOS 11.0, iOS 12.2, tvOS 12.2, watchOS 5.2, *) {
            return .preferredFont(forTextStyle: .subheadline)
        }
        return .systemFont(ofSize: NSUIFont.systemFontSize - 2)
    }

    static var headline: NSUIFont {
        if #available(macOS 11.0, iOS 12.2, tvOS 12.2, watchOS 5.2, *) {
            return .preferredFont(forTextStyle: .headline)
        }
        return .systemFont(ofSize: NSUIFont.systemFontSize - 2, weight: .semibold)
    }

    static var title3: NSUIFont {
        if #available(macOS 11.0, iOS 12.2, tvOS 12.2, watchOS 5.2, *) {
            return .preferredFont(forTextStyle: .title3)
        }
        return .systemFont(ofSize: NSUIFont.systemFontSize + 3)
    }

    static var title2: NSUIFont {
        if #available(macOS 11.0, iOS 12.2, tvOS 12.2, watchOS 5.2, *) {
            return .preferredFont(forTextStyle: .title2)
        }
        return .systemFont(ofSize: NSUIFont.systemFontSize + 5)
    }

    static var title: NSUIFont {
        if #available(macOS 11.0, iOS 12.2, tvOS 12.2, watchOS 5.2, *) {
            return .preferredFont(forTextStyle: .title1)
        }
        return .systemFont(ofSize: NSUIFont.systemFontSize + 11)
    }

    static var largeTitle: NSUIFont {
        if #available(macOS 11.0, iOS 12.2, tvOS 12.2, watchOS 5.2, *) {
            return .preferredFont(forTextStyle: .largeTitle)
        }
        return .systemFont(ofSize: NSUIFont.systemFontSize + 17)
    }

    convenience init?(name: String) {
        self.init(name: name, size: NSUIFont.systemFontSize)
    }
}

public extension NSUIFont {
    static func system(size: CGFloat, weight: NSUIFont.Weight, design: NSUIFontDescriptor.SystemDesign = .default) -> NSUIFont {
        let descriptor = NSUIFont.systemFont(ofSize: size, weight: weight).fontDescriptor.withDesign(design)!
        #if os(macOS)
        return NSUIFont(descriptor: descriptor, size: size)!
        #else
        return NSUIFont(descriptor: descriptor, size: size)
        #endif
    }

    @available(macOS 11.0, iOS 12.2, tvOS 12.2, watchOS 5.2, *)
    static func system(_ style: NSUIFont.TextStyle, design: NSUIFontDescriptor.SystemDesign = .default) -> NSUIFont {
        #if os(macOS)
        let descriptor = NSUIFontDescriptor.preferredFontDescriptor(forTextStyle: style).withDesign(design)!
        return NSUIFont(descriptor: descriptor, size: 0)!
        #else
        let descriptor = NSUIFontDescriptor.preferredFontDescriptor(withTextStyle: style).withDesign(design)!
        return NSUIFont(descriptor: descriptor, size: 0)
        #endif
    }

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
