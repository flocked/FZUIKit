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
import FZSwiftUtils

public extension NSUIFont {
    /// The available font names.
    static var availableFonts: [String] {
        availableFontDescriptors.compactMap({ $0.name })
    }
    
    /// Returns the available font names with the specified font traits.
    static func availableFonts(with symbolicTraits: NSUIFontDescriptor.SymbolicTraits) -> [String] {
        availableFontDescriptors.filter({ $0.symbolicTraits.contains(symbolicTraits) }).compactMap({ $0.name })
    }
    
    /// Returns the available font names for the specified locale.
    static func availableFonts(for locale: Locale) -> [String] {
        var language = locale.identifier
        if #available(macOS 13, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            guard let languageCode = locale.language.languageCode?.identifier else {
                return []
            }
            language = languageCode
        }
        let attributes = [ kCTFontLanguagesAttribute: [language] ] as CFDictionary
        let descriptor = CTFontDescriptorCreateWithAttributes(attributes)
        return (CTFontDescriptorCreateMatchingFontDescriptors(descriptor, nil) as? [NSUIFontDescriptor] ?? []).compactMap({ $0.name })
    }
    
    private static var availableFontDescriptors: [NSUIFontDescriptor] {
        let descriptor = CTFontDescriptorCreateWithAttributes([CFString: Any]() as CFDictionary)
        return (CTFontDescriptorCreateMatchingFontDescriptors(descriptor, nil) as? [NSUIFontDescriptor] ?? [])
    }
    
    /// The standard system font with standard system size.
    static var system = NSUIFont.systemFont(ofSize: NSUIFont.systemFontSize)

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

extension NSUIFont {
    /**
     Returns the localized name for the specified name type.

     - Returns: The localized string and locale of the localized string, or `nil` if the name type couldn't be localized.

     The name is localized based on the user’s global language preference precedence. That is, the user’s language preference is a list of languages in order of precedence.

     So, for example, if the list is [Japanese, English], then a font that did not have Japanese name strings but had English strings would return the English strings.
     */
    public func localizedName(for key: NameKey) -> (name: String, locale: Locale)? {
        var actualLanguage: Unmanaged<CFString>?
        guard let name = CTFontCopyLocalizedName(self, key.value, &actualLanguage) as String?, let language = actualLanguage?.takeRetainedValue() as? String else { return nil }
        return (name, Locale(identifier: language))
    }

    /// A list of font name keys that can be used to access specific names in a font..
    public enum NameKey {
        /// The full name of the font (e.g., "Helvetica-Bold").
        case full
        /// The font's family name (e.g., "Helvetica").
        case family
        /// The font's subfamily name (e.g., "Bold").
        case subFamily
        /// The font's style name.
        case style
        /// A unique name for the font that distinguishes it from others.
        case unique
        /// The version string of the font (e.g., "Version 1.0").
        case version
        /// The PostScript name used internally by PostScript.
        case postScript
        /// Trademark information for the font.
        case trademark
        /// Name of the font's manufacturer.
        case manufacturer
        /// Name of the font's designer.
        case designer
        /// Description of the font's design or purpose.
        case description
        /// Name of the URL to the font vendor's website.
        case vendorURL
        /// Name of the URL to the font designer's website.
        case designerURL
        /// Name of the font's license.
        case license
        /// Name of the URL to the font's license text.
        case licenseURL
        /// Sample text string to show the font style.
        case sampleText
        /// The PostScript CID name (used for CID-keyed fonts).
        case postScriptCID
        /// Copyright notice for the font.
        case copyright

        /// The corresponding `CFString` name key used by Core Text.
        var value: CFString {
            switch self {
            case .full:           return kCTFontFullNameKey
            case .family:         return kCTFontFamilyNameKey
            case .subFamily:      return kCTFontSubFamilyNameKey
            case .style:          return kCTFontStyleNameKey
            case .unique:         return kCTFontUniqueNameKey
            case .version:        return kCTFontVersionNameKey
            case .postScript:     return kCTFontPostScriptNameKey
            case .trademark:      return kCTFontTrademarkNameKey
            case .manufacturer:   return kCTFontManufacturerNameKey
            case .designer:       return kCTFontDesignerNameKey
            case .description:    return kCTFontDescriptionNameKey
            case .vendorURL:      return kCTFontVendorURLNameKey
            case .designerURL:    return kCTFontDesignerURLNameKey
            case .license:        return kCTFontLicenseNameKey
            case .licenseURL:     return kCTFontLicenseURLNameKey
            case .sampleText:     return kCTFontSampleTextNameKey
            case .postScriptCID:  return kCTFontPostScriptCIDNameKey
            case .copyright:      return kCTFontCopyrightNameKey
            }
        }
    }

    /// The features of the font.
    public var features: [Feature] {
        (CTFontCopyFeatures(self) as? [[String: Any]] ?? []).compactMap { .init($0) }
    }

    /// A feature of a font.
    public struct Feature: CustomStringConvertible, CustomDebugStringConvertible {
        /// The identifier of the feature.
        public let identifier: Int
        /// The name of the feature.
        public let name: String?
        /// A Boolean value indicating whether a selector is selected exclusively.
        public let isExclusive: Bool
        /// The values of the feature.
        public let values: [FeatureValue]

        public var description: String {
            if isExclusive {
                return "\"\(name ?? "\(identifier)")\", values: \(values.count), isExclusive"
            }
            return "\"\(name ?? "\(identifier)")\", values: \(values.count)"
        }

        public var debugDescription: String {
            let valuesString = values.isEmpty ? "" : "\n  " + values.map({ $0.description }).joined(separator: "\n  ")
            if isExclusive {
                return "\"\(name ?? "\(identifier)")\" isExclusive" + valuesString
            }
            return "\"\(name ?? "\(identifier)")\"" + valuesString
        }

        /// A value of a feature.
        public struct FeatureValue: CustomStringConvertible {
            /// The identifier of the feature value.
            public let identifier: Int
            /// The name of the feature value.
            public let name: String?
            /// A Boolean value indicating whether the feature value is selected.
            public let isSelected: Bool
            /// A Boolean value indicating whether the feature value is the default selector.
            public let isDefault: Bool

            public var description: String {
                let nameString = "\"\(name ?? "\(identifier)")\""
                var strings: [String] = []
                if isSelected {
                    strings += "isSelected"
                }
                if isDefault {
                    strings += "isDefault"
                }
                if !strings.isEmpty {
                    return nameString + " (\(strings.joined(separator: ", ")))"
                }
                return nameString
            }

            init?(_ dictionary: [String: Any]) {
                guard let idCFNumber = dictionary[kCTFontFeatureSelectorIdentifierKey as String] as? NSNumber else {
                    return nil
                }
                identifier = idCFNumber.intValue
                name = dictionary[kCTFontFeatureSelectorNameKey as String] as? String
                isDefault = (dictionary[kCTFontFeatureSelectorDefaultKey as String] as? NSNumber)?.boolValue ?? false
                isSelected = (dictionary[kCTFontFeatureSelectorSettingKey as String] as? NSNumber)?.boolValue ?? isDefault
            }
        }

        init?(_ dictionary: [String: Any]) {
            guard let idCFNumber = dictionary[kCTFontFeatureTypeIdentifierKey as String] as? NSNumber, let selectorDictionaries = dictionary[kCTFontFeatureTypeSelectorsKey as String] as? [[String: Any]] else {
                return nil
            }
            self.identifier = idCFNumber.intValue
            self.values = selectorDictionaries.compactMap { .init($0) }
            self.name = dictionary[kCTFontFeatureTypeNameKey as String] as? String
            self.isExclusive = (dictionary[kCTFontFeatureTypeExclusiveKey as String] as? NSNumber)?.boolValue ?? false
        }
    }
}

#if os(tvOS) || os(watchOS)
extension NSUIFont {
    static var systemFontSize: CGFloat {
        UIFont.preferredFont(forTextStyle: .body).pointSize
    }
}
#endif
