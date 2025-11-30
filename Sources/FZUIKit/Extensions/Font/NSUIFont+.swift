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
    static func availableFonts(with symbolicTraits: SymbolicTraits) -> [String] {
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
        let attributes = [kCTFontLanguagesAttribute: [language]] as CFDictionary
        let descriptor = CTFontDescriptorCreateWithAttributes(attributes)
        return (CTFontDescriptorCreateMatchingFontDescriptors(descriptor, nil) as? [NSUIFontDescriptor] ?? []).compactMap({ $0.name })
    }
    
    static var availableFontDescriptors: [NSUIFontDescriptor] {
        let descriptor = CTFontDescriptorCreateWithAttributes([CFString: Any]() as CFDictionary)
        return (CTFontDescriptorCreateMatchingFontDescriptors(descriptor, nil) as? [NSUIFontDescriptor] ?? [])
    }
    
    /// The standard system font with standard system size.
    static var system = NSUIFont.systemFont(ofSize: NSUIFont.systemFontSize)

    /// A font with the alternate caption text style.
    static var caption2: NSUIFont {
        if #available(macOS 11.0, iOS 7.0, tvOS 7.0, watchOS 2.0, *) {
            return .preferredFont(forTextStyle: .caption2)
        }
        return .systemFont(ofSize: NSUIFont.systemFontSize - 6)
    }

    /// A font with the caption text style.
    static var caption: NSUIFont {
        if #available(macOS 11.0, iOS 7.0, tvOS 7.0, watchOS 2.0, *) {
            return .preferredFont(forTextStyle: .caption1)
        }
        return .systemFont(ofSize: NSUIFont.systemFontSize - 5)
    }

    /// A font with the footnote text style.
    static var footnote: NSUIFont {
        if #available(macOS 11.0, iOS 7.0, tvOS 7.0, watchOS 2.0, *) {
            return .preferredFont(forTextStyle: .footnote)
        }
        return .systemFont(ofSize: NSUIFont.systemFontSize - 4)
    }

    /// A font with the callout text style.
    static var callout: NSUIFont {
        if #available(macOS 11.0, iOS 7.0, tvOS 7.0, watchOS 2.0, *) {
            return .preferredFont(forTextStyle: .callout)
        }
        return .systemFont(ofSize: NSUIFont.systemFontSize - 1)
    }

    /// A font with the body text style.
    static var body: NSUIFont {
        if #available(macOS 11.0, iOS 7.0, tvOS 7.0, watchOS 2.0, *) {
            return .preferredFont(forTextStyle: .body)
        }
        return .systemFont(ofSize: NSUIFont.systemFontSize)
    }

    /// A font with the subheadline text style.
    static var subheadline: NSUIFont {
        if #available(macOS 11.0, iOS 7.0, tvOS 7.0, watchOS 2.0, *) {
            return .preferredFont(forTextStyle: .subheadline)
        }
        return .systemFont(ofSize: NSUIFont.systemFontSize - 2)
    }

    /// A font with the headline text style.
    static var headline: NSUIFont {
        if #available(macOS 11.0, iOS 7.0, tvOS 7.0, watchOS 2.0, *) {
            return .preferredFont(forTextStyle: .headline)
        }
        return .systemFont(ofSize: NSUIFont.systemFontSize - 2, weight: .semibold)
    }

    /// Create a font for third level hierarchical headings.
    static var title3: NSUIFont {
        if #available(macOS 11.0, iOS 7.0, tvOS 7.0, watchOS 2.0, *) {
            return .preferredFont(forTextStyle: .title3)
        }
        return .systemFont(ofSize: NSUIFont.systemFontSize + 3)
    }

    /// Create a font for second level hierarchical headings.
    static var title2: NSUIFont {
        if #available(macOS 11.0, iOS 7.0, tvOS 7.0, watchOS 2.0, *) {
            return .preferredFont(forTextStyle: .title2)
        }
        return .systemFont(ofSize: NSUIFont.systemFontSize + 5)
    }

    /// A font with the title text style.
    static var title: NSUIFont {
        if #available(macOS 11.0, iOS 12.2, tvOS 12.2, watchOS 5.0, *) {
            return .preferredFont(forTextStyle: .title1)
        }
        return .systemFont(ofSize: NSUIFont.systemFontSize + 11)
    }

    #if os(macOS) || os(iOS) || os(watchOS)
    /// A font with the large title text style.
    static var largeTitle: NSUIFont {
        if #available(macOS 11.0, iOS 7.0, tvOS 7.0, watchOS 2.0, *) {
            return .preferredFont(forTextStyle: .largeTitle)
        }
        return .systemFont(ofSize: NSUIFont.systemFontSize + 17)
    }

    /// A font with the extra large title text style.
    static var extraLargeTitle1: NSUIFont {
        if #available(macOS 15.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *) {
            return .preferredFont(forTextStyle: .init(rawValue: "UICTFontTextStyleExtraLargeTitle"))
        }
        return .largeTitle.withSize(36.0)
    }
    
    /// A font with the extra extra large title text style.
    static var extraLargeTitle2: NSUIFont {
        if #available(macOS 15.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *) {
            return .preferredFont(forTextStyle: .init(rawValue: "UICTFontTextStyleExtraLargeTitle2"))
        }
        return .largeTitle.withSize(28.0)
    }
    #endif

    #if os(macOS)
    /// The current font with the specified matrix.
    func matrix(_ matrix: AffineTransform) -> NSUIFont {
        descriptor(fontDescriptor.withMatrix(matrix))
    }
    #else
    /// The current font with the specified matrix.
    func matrix(_ matrix: CGAffineTransform) -> NSUIFont {
        descriptor(fontDescriptor.withMatrix(matrix))
    }
    #endif
    
    /// Constants for font designs, such as monospace, rounded, and serif.
    typealias SystemDesign = NSUIFontDescriptor.SystemDesign
    
    /// A symbolic description of the stylistic aspects of a font.
    typealias SymbolicTraits = NSUIFontDescriptor.SymbolicTraits

    /// The current font with the specified design style.
    func design(_ design: SystemDesign) -> NSUIFont {
        descriptor(fontDescriptor.withDesign(design))
    }

    /// The current font with the specified symbolic traits taking precedence over the existing ones.
    func symbolicTraits(_ symbolTraits: SymbolicTraits) -> NSUIFont {
        descriptor(fontDescriptor.withSymbolicTraits(symbolTraits))
    }

    /// The current font with the specified face.
    func face(_ face: String) -> NSUIFont {
        descriptor(fontDescriptor.withFace(face))
    }

    /// The current font with the specified font weight.
    func weight(_ weight: Weight) -> NSUIFont {
        descriptor(fontDescriptor.withWeight(weight))
    }
    
    private func descriptor(_ descriptor: NSUIFontDescriptor?) -> NSUIFont {
        guard let descriptor = descriptor else { return self }
        #if os(macOS)
        return .init(descriptor: descriptor, size: pointSize) ?? self
        #else
        return .init(descriptor: descriptor, size: pointSize)
        #endif
    }
        
    #if os(macOS)
    /**
     Returns a font that matches the specified font descriptor.
     
     - Parameter descriptor: The font descriptor to match.
     - Returns: A font object for the specified descriptor.
     */
    convenience init?(descriptor: NSFontDescriptor) {
        self.init(descriptor: descriptor, size: descriptor.pointSize)
    }
    #else
    /**
     Returns a font that matches the specified font descriptor.
     
     - Parameter descriptor: The font descriptor to match.
     - Returns: A font object for the specified descriptor.
     */
    convenience init(descriptor: UIFontDescriptor) {
        self.init(descriptor: descriptor, size: descriptor.pointSize)
    }
    #endif
    
    #if os(tvOS) || os(watchOS)
    /// The size, in points, of the standard system font.
    static var systemFontSize: CGFloat {
        UIFont.preferredFont(forTextStyle: .body).pointSize
    }
    #endif
}

public extension NSUIFont {
    /**
     Returns the standard system font for the specified style and design.

     - Parameters:
        - textStyle: The text style for which to return a font.
        - design: The design of the font.
     */
    @available(macOS 11.0, iOS 12.2, tvOS 12.2, watchOS 5.2, *)
    static func systemFont(_ textStyle: TextStyle, design: SystemDesign = .default) -> NSUIFont {
        preferredFont(forTextStyle: textStyle).design(design)
    }
    
    #if os(macOS)
    /**
     Returns the standard system font with the specified size, design and weight.
     
     - Parameters:
        - size: The font size. If you specify `0.0` or a negative number for this parameter, the method returns the system font at the default size.
        - weight: The weight of the font.
        - design: The design of the font.
     */
    static func systemFont(ofSize size: CGFloat, weight: Weight = .regular, design: SystemDesign) -> NSUIFont {
        systemFont(ofSize: size, weight: weight).design(design)
    }
    
    /**
     Creates and returns a font object for the specified font name and size.

     - Parameters:
        - fontName: The fully specified name of the font. This name incorporates both the font family name and the specific style information for the font.
        - fontSize: The font size. If you specify `0.0` or a negative number for this parameter, the method returns the system font at the default size.
     - Returns: A font object of the specified name and size.
     */
    static func named(_ fontName: String, size fontSize: CGFloat) -> NSUIFont? {
        NSUIFont(name: fontName, size: fontSize)
    }
    #else
    /**
     Returns the standard system font with the specified size, design and weight.
     
     - Parameters:
        - size: The size (in points) to which the font is scaled. This value must be greater than `0.0.
        - weight: The weight of the font.
        - design: The design of the font.
     */
    static func systemFont(ofSize size: CGFloat, weight: Weight = .regular, design: SystemDesign) -> NSUIFont {
        systemFont(ofSize: size, weight: weight).design(design)
    }
    
    /**
     Creates and returns a font object for the specified font name and size.

     - Parameters:
        - fontName: The fully specified name of the font. This name incorporates both the font family name and the specific style information for the font.
        - fontSize: The size (in points) to which the font is scaled. This value must be greater than `0.0`.
     - Returns: A font object of the specified name and size.
     */
    static func named(_ fontName: String, size fontSize: CGFloat) -> NSUIFont? {
        NSUIFont(name: fontName, size: fontSize)
    }
    #endif

    /// The font with an italic style.
    var italic: NSUIFont {
        includingSymbolicTraits(._italic)
    }

    /// The font with an italic style.
    func italic(_ italic: Bool) -> NSUIFont {
        italic ? self.italic : withoutSymbolicTraits(._italic)
    }

    /// The font characters with same width.
    var monospaced: NSUIFont {
        includingSymbolicTraits(._monoSpace)
    }

    /// The font characters with same width.
    func monospaced(_ monospaced: Bool) -> NSUIFont {
        monospaced ? self.monospaced : withoutSymbolicTraits(._monoSpace)
    }

    /// The font with a bold style.
    var bold: NSUIFont {
        includingSymbolicTraits(._bold)
    }

    /// The font with a bold style.
    func bold(_ bold: Bool) -> NSUIFont {
        bold ? self.bold : withoutSymbolicTraits(._bold)
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

    /// The font with a rounded appearance.
    func rounded(_ rounded: Bool) -> NSUIFont {
        if rounded {
            return self.rounded
        } else if fontDescriptor.design == .rounded {
            return design(.default)
        }
        return self
    }
    
    /// Returns the font with the specified width of the font’s characters.
    func width(_ width: SymbolicTraits.Width) -> NSUIFont {
        var symbolicTraits = fontDescriptor.symbolicTraits
        guard symbolicTraits.width != width else { return self }
        symbolicTraits.width = width
        return self.symbolicTraits(symbolicTraits)
    }
    
    /// Returns the font with the specified font’s leading value.
    func leading(_ leading: SymbolicTraits.Leading) -> NSUIFont {
        var symbolicTraits = fontDescriptor.symbolicTraits
        guard symbolicTraits.leading != leading else { return self }
        symbolicTraits.leading = leading
        return self.symbolicTraits(symbolicTraits)
    }

    internal func includingSymbolicTraits(_ symbolicTraits: SymbolicTraits) -> NSUIFont {
        var traits = fontDescriptor.symbolicTraits
        guard !traits.contains(symbolicTraits) else { return self }
        traits.insert(symbolicTraits)
        return self.symbolicTraits(traits)
    }

    internal func withoutSymbolicTraits(_ symbolicTraits: SymbolicTraits) -> NSUIFont {
        var traits = fontDescriptor.symbolicTraits
        guard traits.contains(any: symbolicTraits) else { return self }
        traits.remove(symbolicTraits)
        return self.symbolicTraits(traits)
    }
}

extension NSUIFont {
    /**
     Returns the name for the specified name type.
     
     - Returns: The requested name for the font, or `nil` if the font does not have an entry for the requested name.
     */
    public func name(of nameKey: NameKey) -> String? {
        CTFontCopyName(self, nameKey.rawValue) as String?
    }
    
    /**
     Returns the localized name for the specified name type.

     The name is localized based on the user’s global language preference precedence. That is, the user’s language preference is a list of languages in order of precedence.

     So, for example, if the list is [Japanese, English], then a font that did not have Japanese name strings but had English strings would return the English strings.
     
     - Returns: The localized string and locale of the localized string, or `nil` if the name type couldn't be localized.
     */
    public func localizedName(for key: NameKey) -> (name: String, locale: Locale)? {
        var actualLanguage: Unmanaged<CFString>?
        guard let name = CTFontCopyLocalizedName(self, key.rawValue, &actualLanguage) as String?, let language = actualLanguage?.takeRetainedValue() as? String else { return nil }
        return (name, Locale(identifier: language))
    }

    /// A list of font name keys that can be used to access specific names in a font.
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
   
        /// The corresponding name key used by Core Text.
        public var rawValue: CFString {
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
    
    /**
     The scaled font ascent metric.

     The font ascent metric scaled based on the point size and matrix of the font reference.
     */
    public var ascent: CGFloat {
        CTFontGetAscent(self)
    }

    /**
     The scaled font descent metric.

     The font descent metric scaled based on the point size and matrix of the font reference.
     */
    public var descent: CGFloat {
        CTFontGetDescent(self)
    }

    /**
     The number of glyphs.

     The number of glyphs in the font.
     */
    public var countOfGlyphs: Int {
        CTFontGetGlyphCount(self)
    }

    /**
     The scaled bounding box.

     The design bounding box of the font, which is the rectangle defined by `xMin`, `yMin`, `xMax`, and `yMax` values for the font.
     */
    public var boundingBox: CGRect {
        CTFontGetBoundingBox(self)
    }

    /**
     The scaled underline position.

     The font underline position metric scaled based on the point size and matrix of the font reference.
     */
    public var underlinePosition: CGFloat {
        CTFontGetUnderlinePosition(self)
    }

    /**
     The scaled underline thickness metric.

     The font underline thickness metric scaled based on the point size and matrix of the font reference.
     */
    public var underlineThickness: CGFloat {
        CTFontGetUnderlineThickness(self)
    }

    /**
     The slant angle of the font.

     The transformed slant angle of the font. This is equivalent to the italic or caret angle with any skew from the transformation matrix applied.
     */
    public var slantAngle: CGFloat {
        CTFontGetSlantAngle(self)
    }
}

public extension NSUIFont {
    /**
     Returns the font with a point size that is adjusted so that the specified text fits within the given height.

     This method determines the largest point size at which the rendered height of the string does not exceed the provided value.

     - Parameters:
       - height: The maximum allowed height for the rendered text.
       - text: The text whose rendered height should fit within the specified value.

     - Returns: The font sized so the text fits within the provided height.
     */
    func sizedToFit(height: CGFloat, for text: String) -> NSUIFont {
        var low: CGFloat = 1.0
        var high: CGFloat = max(height, 1.0)
        while high - low > 0.1 {
            let mid = (low + high) / 2.0
            if text.size(withAttributes: [.font: withSize(mid)]).height <= height {
                low = mid
            } else {
                high = mid
            }
        }
        return withSize(low)
    }

    /**
     Returns the font with a point size that is adjusted so that the specified text fits within the given width.

     This method determines the largest point size at which the rendered width of the string does not exceed the provided value.
     
     - Parameters:
       - width: The maximum allowed width for the rendered text.
       - text: The text whose rendered width should fit within the specified value.

     - Returns: The font sized so the text fits within the provided width.
     */
    func sizedToFit(width: CGFloat, for text: String) -> NSUIFont {
        let baseWidth = text.size(withAttributes: [.font: self]).width
        var low: CGFloat = 1.0
        var upper = baseWidth > 0.0 ? max(1.0, (width / baseWidth) * pointSize) :  max(1.0, width)
        while upper - low > 0.1 {
            let mid = (low + upper) / 2.0
            if text.size(withAttributes: [.font: withSize(mid)]).width <= width {
                low = mid
            } else {
                upper = mid
            }
        }
        return withSize(low)
    }
}


#if os(macOS)
@available(macOS 15.0, *)
extension NSFont.TextStyle {
    ///  The font style for extra large titles.
    public static let extraLargeTitle = Self(rawValue: "UICTFontTextStyleExtraLargeTitle")
    
    ///  The font style for extra extra large titles.
    public static let extraLargeTitle2 = Self(rawValue: "UICTFontTextStyleExtraLargeTitle2")
}
#endif

@available(macOS 11.0, iOS 9.0, tvOS 9.0, watchOS 3.0, *)
extension NSUIFont.TextStyle: CaseIterable {
    /// A collection of all text style values.
    public static var allCases: [Self] {
        #if os(macOS) || os(iOS) || os(watchOS)
        if #available(macOS 15.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *) {
            return [.body, .subheadline, .headline, .caption1, .caption2, .callout, .footnote, .title1, .title2, .title3, .largeTitle, .extraLargeTitle, .extraLargeTitle2]
        }
        return [.body, .subheadline, .headline, .caption1, .caption2, .callout, .footnote, .title1, .title2, .title3, .largeTitle]
        #else
        if #available(tvOS 17.0, *) {
            return [.body, .subheadline, .headline, .caption1, .caption2, .callout, .footnote, .title1, .title2, .title3, .extraLargeTitle, .extraLargeTitle2]
        }
        return [.body, .subheadline, .headline, .caption1, .caption2, .callout, .footnote, .title1, .title2, .title3]
        #endif
    }
}
