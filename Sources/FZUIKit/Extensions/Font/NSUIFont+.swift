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
    #if os(macOS)
    /**
     Returns a font object for the specified font name and matrix.

     - Parameters:
        - name: The fully specified family-face name of the font.
        - matrix: A transformation matrix applied to the font.
     - Returns: A font object for the specified name and transformation matrix.
     */
    convenience init?(name: String, matrix: CGAffineTransform) {
        guard NSUIFont(name: name, size: 0) != nil else { return nil }
        var matrix = matrix
        self.init(descriptor: (CTFontCreateWithName(name as CFString, 0, &matrix) as NSUIFont).fontDescriptor)
    }

    #else
    /**
     Returns a font object for the specified font name and matrix.

     - Parameters:
        - name: The fully specified family-face name of the font.
        - matrix: A transformation matrix applied to the font.
     - Returns: A font object for the specified name and transformation matrix.
     */
    convenience init?(name: String, matrix: CGAffineTransform) {
        guard NSUIFont(name: name, size: 0) != nil else { return nil }
        self.init(descriptor: .init(name: name, matrix: matrix))
    }
    #endif

    /// The available font names.
    static var availableFonts: [String] {
        availableFontDescriptors.compactMap { $0.name }
    }

    /// Returns the available font names with the specified font traits.
    static func availableFonts(with symbolicTraits: SymbolicTraits) -> [String] {
        availableFontDescriptors.filter { $0.symbolicTraits.contains(symbolicTraits) }.compactMap { $0.name }
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
        return (CTFontDescriptorCreateMatchingFontDescriptors(descriptor, nil) as? [NSUIFontDescriptor] ?? []).compactMap { $0.name }
    }

    static var availableFontDescriptors: [NSUIFontDescriptor] {
        let descriptor = CTFontDescriptorCreateWithAttributes([CFString: Any]() as CFDictionary)
        return (CTFontDescriptorCreateMatchingFontDescriptors(descriptor, nil) as? [NSUIFontDescriptor] ?? [])
    }

    /// The PostScript names of the fonts available in the system.
    static var availablePostScriptNames: [String] {
        CTFontManagerCopyAvailablePostScriptNames() as? [String] ?? []
    }

    /// The file URLs of the fonts available in the system.
    static var availableFontURLs: [URL] {
        (CTFontManagerCopyAvailableFontURLs() as? [URL]) ?? []
    }

    /// The standard system font with standard system size.
    static var system = NSUIFont.systemFont(ofSize: NSUIFont.systemFontSize)

    /// A font with the alternate caption text style.
    static var caption2: NSUIFont = .preferredFont(forTextStyle: .caption2)

    /// A font with the caption text style.
    static var caption: NSUIFont = .preferredFont(forTextStyle: .caption1)

    /// A font with the footnote text style.
    static var footnote: NSUIFont = .preferredFont(forTextStyle: .footnote)

    /// A font with the callout text style.
    static var callout: NSUIFont = .preferredFont(forTextStyle: .callout)

    /// A font with the body text style.
    static var body: NSUIFont = .preferredFont(forTextStyle: .body)

    /// A font with the subheadline text style.
    static var subheadline: NSUIFont = .preferredFont(forTextStyle: .subheadline)

    /// A font with the headline text style.
    static var headline: NSUIFont = .preferredFont(forTextStyle: .headline)

    /// Create a font for third level hierarchical headings.
    static var title3: NSUIFont = .preferredFont(forTextStyle: .title3)

    /// Create a font for second level hierarchical headings.
    static var title2: NSUIFont = .preferredFont(forTextStyle: .title2)

    /// A font with the title text style.
    static var title: NSUIFont = .preferredFont(forTextStyle: .title1)

    #if os(macOS) || os(iOS) || os(watchOS)
    /// A font with the large title text style.
    static var largeTitle: NSUIFont = .preferredFont(forTextStyle: .largeTitle)
    #endif

    /// A font with the extra large title text style.
    @available(macOS 15.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
    static var extraLargeTitle1: NSUIFont = .preferredFont(forTextStyle: .init(rawValue: "UICTFontTextStyleExtraLargeTitle"))

    /// A font with the extra extra large title text style.
    @available(macOS 15.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
    static var extraLargeTitle2: NSUIFont = .preferredFont(forTextStyle: .init(rawValue: "UICTFontTextStyleExtraLargeTitle2"))

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

    /// The current font with the specified symbolic traits and the current one.
    func symbolTraits(adding symbolTraits: SymbolicTraits) -> NSUIFont {
        self.symbolicTraits(fontDescriptor.symbolicTraits + symbolTraits)
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
    var serif: NSUIFont {
        design(.serif)
    }

    /// The font with a serif design.
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

public extension NSUIFont {
    /**
     Returns the name for the specified name type.

     - Returns: The requested name for the font, or `nil` if the font does not have an entry for the requested name.
     */
    func name(of nameKey: NameKey) -> String? {
        CTFontCopyName(self, nameKey.rawValue)?.asSwift()
    }

    /**
     Returns the localized name for the specified name type.

     The name is localized based on the user’s global language preference precedence. That is, the user’s language preference is a list of languages in order of precedence.

     So, for example, if the list is [Japanese, English], then a font that did not have Japanese name strings but had English strings would return the English strings.

     - Returns: The localized string and locale of the localized string, or `nil` if the name type couldn't be localized.
     */
    func localizedName(for key: NameKey) -> (name: String, locale: Locale)? {
        var actualLanguage: Unmanaged<CFString>?
        guard let name = CTFontCopyLocalizedName(self, key.rawValue, &actualLanguage) as String?, let language = actualLanguage?.takeRetainedValue() as? String else { return nil }
        return (name, Locale(identifier: language))
    }

    /// A list of font name keys that can be used to access specific names in a font.
    enum NameKey {
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
            case .full: return kCTFontFullNameKey
            case .family: return kCTFontFamilyNameKey
            case .subFamily: return kCTFontSubFamilyNameKey
            case .style: return kCTFontStyleNameKey
            case .unique: return kCTFontUniqueNameKey
            case .version: return kCTFontVersionNameKey
            case .postScript: return kCTFontPostScriptNameKey
            case .trademark: return kCTFontTrademarkNameKey
            case .manufacturer: return kCTFontManufacturerNameKey
            case .designer: return kCTFontDesignerNameKey
            case .description: return kCTFontDescriptionNameKey
            case .vendorURL: return kCTFontVendorURLNameKey
            case .designerURL: return kCTFontDesignerURLNameKey
            case .license: return kCTFontLicenseNameKey
            case .licenseURL: return kCTFontLicenseURLNameKey
            case .sampleText: return kCTFontSampleTextNameKey
            case .postScriptCID: return kCTFontPostScriptCIDNameKey
            case .copyright: return kCTFontCopyrightNameKey
            }
        }
    }

    /**
     The scaled font ascent metric.

     The font ascent metric scaled based on the point size and matrix of the font reference.
     */
    var ascent: CGFloat {
        #if os(macOS)
        CTFontGetAscent(cleanedFont)
        #else
        CTFontGetAscent(self)
        #endif
    }

    /**
     The scaled font descent metric.

     The font descent metric scaled based on the point size and matrix of the font reference.
     */
    var descent: CGFloat {
        #if os(macOS)
        CTFontGetDescent(cleanedFont)
        #else
        CTFontGetDescent(self)
        #endif
    }

    /**
     The number of glyphs.

     The number of glyphs in the font.
     */
    var countOfGlyphs: Int {
        CTFontGetGlyphCount(self)
    }

    /**
     The scaled bounding box.

     The design bounding box of the font, which is the rectangle defined by `xMin`, `yMin`, `xMax`, and `yMax` values for the font.
     */
    var boundingBox: CGRect {
        CTFontGetBoundingBox(self)
    }

    /**
     The scaled underline position.

     The font underline position metric scaled based on the point size and matrix of the font reference.
     */
    var underlinePosition: CGFloat {
        CTFontGetUnderlinePosition(self)
    }

    /**
     The scaled underline thickness metric.

     The font underline thickness metric scaled based on the point size and matrix of the font reference.
     */
    var underlineThickness: CGFloat {
        CTFontGetUnderlineThickness(self)
    }

    /**
     The slant angle of the font.

     The transformed slant angle of the font. This is equivalent to the italic or caret angle with any skew from the transformation matrix applied.
     */
    var slantAngle: CGFloat {
        CTFontGetSlantAngle(self)
    }

    /// The units-per-em metric of the font.
    var unitsPerEm: UInt32 {
        CTFontGetUnitsPerEm(self)
    }

    /// `CGFont` representation of the font.
    var cgFont: CGFont {
        CTFontCopyGraphicsFont(self, nil)
    }

    /**
     Returns the special user-interface font for the specified type and size.

     - Parameters:
        - type: The intended user-interface use for the requested font.
        - size: The point size of the font. If `0.0` is specified, the default size for the requested user-interface type is used.
        - locale: The locale of the font.
     - Returns: The correct font for various user-interface uses.
     */
    static func uiFont(for type: CTFontUIFontType, size: CGFloat = 0.0, locale: Locale = .current) -> NSUIFont? {
        CTFontCreateUIFontForLanguage(type, size, locale.identifier as CFString)
    }

    #if os(macOS)
    /**
     Returns the special user-interface font for the specified type and size.

     - Parameters:
        - type: The intended user-interface use for the requested font.
        - size: The control size of the font.
        - locale: The locale of the font.
     - Returns: The correct font for various user-interface uses.
     */
    static func uiFont(for type: CTFontUIFontType, size: NSControl.ControlSize, locale: Locale = .current) -> NSUIFont? {
        uiFont(for: type, size: NSFont.systemFontSize(for: size), locale: locale)
    }
    #endif

    /// Returns the width of the space character in points.
    var spaceCharacterWidth: CGFloat {
        guard let glyph = glyph(for: 0x20) else { return 0.0 }
        let advancement = advancement(forCGGlyph: glyph)
        return (advancement.width * 100.0).rounded() / 100.0
    }

    /**
     Returns the glyph corresponding to a single `UniChar`.

     - Parameter char: The `UniChar`.
     - Returns: The `CGGlyph` for the character, or `nil` if the font does not contain it.
     */
    func glyph(for char: UniChar) -> CGGlyph? {
        var char = char
        var glyph = CGGlyph()
        guard CTFontGetGlyphsForCharacters(self, &char, &glyph, 1) else { return nil }
        return glyph
    }

    /**
     Returns the glyphs corresponding to a `Character`.

     - Parameter character: The character.
     - Returns: the glyphs corresponding to the character, or `nil` if the font does not contain the character.
     */
    func glyphs(for character: Character) -> [CGGlyph]? {
        let utf16 = Array(character.utf16)
        var glyphs = [CGGlyph](repeating: 0, count: utf16.count)
        guard CTFontGetGlyphsForCharacters(self, utf16, &glyphs, utf16.count) else { return nil }
        return glyphs
    }
    
    /// Returns a Boolean value indicating whether the file at the specified URL contains a supported font.
    static func supportsFont(at url: URL) -> Bool {
        CTFontManagerIsSupportedFont(url as CFURL)
    }
    
    /**
     Registers the fonts contained in the file at the specified URL.

     - Parameters:
       - url: The URL of the font file to register.
       - scope: The registration scope to use when registering the fonts.
     - Throws: An error if the fonts could not be registered.
     */
    static func registerFonts(at url: URL, scope: CTFontManagerScope = .process) throws {
        var error: Unmanaged<CFError>?
        guard CTFontManagerRegisterFontsForURL(url as CFURL, scope, &error) else {
            throw (error?.takeRetainedValue() as Error?) ??
                CocoaError(.fileReadUnknown)
        }
    }

    /**
     Unregisters the fonts contained in the specified files.

     - Parameters:
       - urls: The URLs of the font files to unregister.
       - scope: The registration scope from which the fonts should be unregistered.
       - handler: A closure invoked as errors occur and when the operation completes. Return `false` to stop the unregistration process.
     */
    static func unregisterFonts(at urls: [URL], scope: CTFontManagerScope = .process, handler: ((_ errors: [Error], _ done: Bool) -> Bool)? = nil) {
        CTFontManagerUnregisterFontURLs(urls as CFArray, scope) { errors, done in
            handler?(errors as? [Error] ?? [], done) ?? true
        }
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
        sizedToFit(maximumSize: height, measuring: { text.size(withAttributes: [.font: $0]).height })
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
        sizedToFit(maximumSize: width, measuring: { text.size(withAttributes: [.font: $0]).width })
    }

    private func sizedToFit(maximumSize: CGFloat, minimumPointSize: CGFloat = 1.0, precision: CGFloat = 0.1, measuring measure: (NSUIFont) -> CGFloat) -> NSUIFont {
        guard maximumSize > 0 else { return withSize(minimumPointSize) }
        var low = minimumPointSize
        var high = max(pointSize, minimumPointSize)
        while measure(withSize(high)) <= maximumSize {
            low = high
            high *= 2.0
        }
        while high - low > precision {
            let mid = (low + high) / 2.0
            if measure(withSize(mid)) <= maximumSize {
                low = mid
            } else {
                high = mid
            }
        }
        return withSize(low)
    }
}

#if os(macOS)
@available(macOS 15.0, *)
public extension NSFont.TextStyle {
    ///  The font style for extra large titles.
    static let extraLargeTitle = Self(rawValue: "UICTFontTextStyleExtraLargeTitle")

    ///  The font style for extra extra large titles.
    static let extraLargeTitle2 = Self(rawValue: "UICTFontTextStyleExtraLargeTitle2")
}
#endif

extension NSUIFont.TextStyle: Swift.CaseIterable {
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

#if !os(macOS)
public extension UIFont {
    /**
     Returns the nominal spacing for the given glyph—the distance the current point moves after showing the glyph—accounting for the receiver’s size.

     The spacing is given according to the glyph’s movement direction, which is either strictly horizontal or strictly vertical.

     - Parameter glyph: The glyph whose advancement is returned.
     - Returns: The advancement spacing in points.
     */
    func advancement(forCGGlyph glyph: CGGlyph) -> CGSize {
        var advance: CGSize = .zero
        CTFontGetAdvancesForGlyphs(self, .default, [glyph], &advance, 1)
        return advance
    }
}
#endif

public extension CTFontSymbolicTraits {
    /// The font uses a leading value that’s greater than the default.
    static let traitLooseLeading = Self(rawValue: 1 << 15)
    /// The font uses a leading value that’s less than the default.
    static let traitTightLeading = Self(rawValue: 1 << 16)
}

public extension NSUIFont.TextStyle {
    /// The point size for the font with the text style.
    var pointSize: CGFloat {
        NSUIFont.preferredFont(forTextStyle: self).pointSize
    }

    /// The font weight for the font with the text style.
    var weight: NSUIFont.Weight? {
        NSUIFont.preferredFont(forTextStyle: self).fontDescriptor.weight
    }

    #if canImport(UIKit)
    var uictName: String? {
        UIFont.preferredFont(forTextStyle: self).fontDescriptor.object(forKey: .textStyle) as? String
    }
    #endif
}
