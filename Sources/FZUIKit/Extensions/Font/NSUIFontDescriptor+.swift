//
//  NSUIFontDescriptor+.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import FZSwiftUtils

public extension NSUIFontDescriptor {
    /// The name of the font, including family and face names, to use when displaying the font information to the user.
    var displayName: String? {
        object(forKey: .visibleName) as? String
    }
    
    ///  The family name of the font.
    var familyName: String? {
        object(forKey: .family) as? String
    }
    
    /// The face name of the font.
    var faceName: String? {
        object(forKey: .face) as? String
    }
    
    /// The font name.
    var name: String? {
        object(forKey: .name) as? String
    }
    
    /// Returns the font for the font descriptor.
    var font: NSUIFont {
        #if os(macOS)
        .init(descriptor: self)!
        #else
        .init(descriptor: self)
        #endif
    }
    
    /// Returns the font for the font descriptor with the specified font size.
    func font(withSize fontSize: CGFloat) -> NSUIFont {
        #if os(macOS)
        .init(descriptor: self, size: fontSize)!
        #else
        .init(descriptor: self, size: fontSize)
        #endif
    }
    
    /**
     The localized family name of the font (e.g., “Helvetica-Bold”).
     
     The name is localized based on the user’s global language preference precedence. That is, the user’s language preference is a list of languages in order of precedence.
     */
    var localizedName: String? {
        font.localizedName(for: .full)?.name
    }
    
    /**
     The localized family name of the font (e.g., “Helvetica”)
     
     The family name is localized based on the user’s global language preference precedence. That is, the user’s language preference is a list of languages in order of precedence.
     */
    var localizedFamilyName: String? {
        font.localizedName(for: .family)?.name
    }
    
    /**
     The localized face name of the font (e.g., “Bold”).
     
     The face name is localized based on the user’s global language preference precedence. That is, the user’s language preference is a list of languages in order of precedence.
     */
    var localizedFaceName: String? {
        font.localizedName(for: .subFamily)?.name
    }
    
    /**
     Returns an ordered list of font descriptors that the system will use as fallback fonts when the original font does not support a particular Unicode character, according to the specified locale.
     
     When the original font used for text layout and rendering does not support a certain Unicode character from the provided text, the system follows this list to pick a fallback font that includes the character.
     
     The font alternatives in the cascade list match the original font’s style, weight, and width.
     
     - Parameter locale: The locale for which to retrieve the font fallback list.
     - Returns: An array of font descriptors  representing the fallback fonts. The array is empty, if no cascade list is available.
     */
    func fontDescriptors(for locale: Locale) -> [NSUIFontDescriptor] {
        CTFontCopyDefaultCascadeListForLanguages(font, [locale.languageCode ?? "en"] as CFArray) as? [NSUIFontDescriptor] ?? []
    }
    
    /// The value that overrides the glyph advancement specified by the font.
    var fixedAdvance: CGFloat {
        object(forKey: .fixedAdvance) ?? 0.0
    }
    
    /// The set of Unicode characters covered by the font.
    var characterSet: CharacterSet {
        object(forKey: .characterSet)!
    }
    
    /**
     The relative slant angle value (between`-1.0` and `1.0`).
     
     A value of `0.0` corresponds to `0` degree clockwise rotation from the vertical and` 1.0` corresponds to `30` degrees clockwise rotation.
     */
    var slant: CGFloat {
        traits?[.slant] as? CGFloat ?? 0.0
    }
    
    /**
     Returns a new font descriptor based on the current object, but with the specified relative slant angle value (between`-1.0` and `1.0`).
     
     A value of `0.0` corresponds to `0` degree clockwise rotation from the vertical and` 1.0` corresponds to `30` degrees clockwise rotation.
     */
    func withSlant(_ slant: CGFloat) -> NSUIFontDescriptor {
        guard slant != self.slant, slant.isBetween(-1.0...1.0) else { return self }
        var traits = traits ?? [:]
        traits[.slant] = slant
        return addingAttributes([.traits : traits])
    }
    
    /**
     The relative inter-glyph spacing (between `-1.0` and `1.0`).
     
     A value of `0.0` corresponds to the regular glyph spacing.
     */
    var width: CGFloat {
        traits?[.width] as? CGFloat ?? 0.0
    }
    
    /**
     Returns a new font descriptor based on the current object, but with the specified relative inter-glyph spacing (between `-1.0` and `1.0`).
     
     A value of `0.0` corresponds to the regular glyph spacing.
     */
    func withWidth(_ width: CGFloat) -> NSUIFontDescriptor {
        guard width != self.width, width.isBetween(-1.0...1.0) else { return self }
        var traits = traits ?? [:]
        traits[.width] = width
        return addingAttributes([.traits : traits])
    }

    /// The system design of the font.
    var design: SystemDesign {
        guard let rawValue = traits?[.design] as? String else { return .default }
        return SystemDesign(rawValue: rawValue) ?? .default
    }

    /// The weight of the font.
    var weight: NSUIFont.Weight {
        guard let rawValue = traits?[.weight] as? CGFloat else { return .regular }
        return .init(rawValue: rawValue) ?? .regular
    }
    
    /// Returns a new font descriptor based on the current object, but with the specified weight.
    func withWeight(_ weight: NSUIFont.Weight) -> NSUIFontDescriptor {
        guard weight != self.weight else { return self }
        var traits = traits ?? [:]
        traits[.weight] = weight.rawValue
        return addingAttributes([.traits : traits])
    }
    
    /// A dictionary of the traits.
    private var traits: [TraitKey: Any]? {
        object(forKey: .traits)
    }
    
    /// Returns a new font descriptor based on the current object, but with the specified traits.
    private func withTraits(_ traits: [TraitKey: Any]) -> NSUIFontDescriptor {
        addingAttributes([.traits : traits])
    }

    /// The text style of the font descriptor.
    @available(macOS 11.0, iOS 10.0, tvOS 10.0, watchOS 3.0, *)
    var textStyle: NSUIFont.TextStyle? {
        guard let rawValue = object(forKey: .textStyle) as? String else { return nil }
        return .init(rawValue: rawValue)
    }
    
    /// The covered languages for the font.
    var supportedLanguages: [Locale] {
        (object(forKey: .languages) as? [String] ?? []).map({ Locale(identifier: $0 )})
    }
    
    /// The recognized format of a font.
    enum Format: UInt32, CustomStringConvertible {
        /// Unrecognized format.
        case unrecognized
        /// OpenType format containing PostScript data.
        case openTypePostScript
        /// OpenType format containing TrueType data.
        case openTypeTrueType
        /// TrueType format.
        case trueType
        /// PostScript format.
        case postScript
        /// Bitmap-only format.
        case bitmap
        
        public var description: String {
            switch self {
            case .unrecognized: return "unrecognized"
            case .openTypePostScript: return "openTypePostScript"
            case .openTypeTrueType: return "openTypeTrueType"
            case .trueType: return "trueType"
            case .postScript: return "postScript"
            case .bitmap: return "bitmap"
            }
        }
    }
    
    /// The recognized format of the font.
    var format: Format {
        .init(rawValue: object(forKey: .format) ?? 0) ?? .unrecognized
    }
    
    /// The URL to the font.
    var url: URL? {
        object(forKey: .url)
    }
    
    /**
     Returns the font attribute specified by the given key.
     
     - Parameter attribute: The font attribute key.
     - Returns: The font attribute corresponding to `attribute`.
     */
    func object<Value>(forKey attribute: AttributeName) -> Value? {
        object(forKey: attribute) as? Value
    }
    
    /// Returns all available font descriptors.
    static var all: [NSUIFontDescriptor] {
        let descriptor = CTFontDescriptorCreateWithAttributes([CFString: Any]() as CFDictionary)
        return (CTFontDescriptorCreateMatchingFontDescriptors(descriptor, nil) as? [NSUIFontDescriptor] ?? [])
    }
    
    /// Returns all available font descriptors matching the specified font attributes.
    static func all(matchingAttributes fontAttributes: [AttributeName: Any]) -> [NSUIFontDescriptor] {
        (CTFontDescriptorCreateMatchingFontDescriptors(NSUIFontDescriptor(fontAttributes: fontAttributes), nil) as? [NSUIFontDescriptor] ?? [])
    }
    
    /// Returns all available font descriptors for the specified font family name (e.g. "Helvetica").
    static func all(forFamilyName familyName: String) -> [NSUIFontDescriptor] {
        all(matchingAttributes: [.family:familyName])
    }
    
    /// Returns all available font descriptors for the specified locale.
    static func all(forLocale locale: Locale) -> [NSUIFontDescriptor] {
        guard let languageCode = locale.languageCode else { return [] }
        return all(matchingAttributes: [.languages: [languageCode]])
    }
    
    /// Returns all available font descriptors for the specified symbol traits.
    static func all(withSymbolTraits symbolicTraits: SymbolicTraits) -> [NSUIFontDescriptor] {
        all.filter({ $0.symbolicTraits.contains(symbolicTraits) })
    }
    
    #if !os(macOS)
    /**
     Returns a normalized font descriptor whose specified attributes match those of the receiver.
 
     If more than one font matches the `[.name, .family, .visibleName, .face]` attributes, the list of font descriptors is filtered by the other mandatory keys, if any, and the top result that is returned is the same as the first element returned from [matchingFontDescriptors(withMandatoryKeys:)](https://developer.apple.com/documentation/uikit/uifontdescriptor/matchingfontdescriptors(withmandatorykeys:)).
 
     - Parameter mandatoryKeys: Keys that must be identical to be matched. Can be `nil`.
     - Returns: The matching font descriptor. If there is no font that matches the given mandatory key values, returns `nil`.
 
     */
    func matchingFontDescriptor(withMandatoryKeys mandatoryKeys: Set<AttributeName>?) -> NSUIFontDescriptor? {
        CTFontDescriptorCreateMatchingFontDescriptor(self, mandatoryKeys?.map({$0.rawValue as CFString}) as? NSSet)
    }
    #endif
}

public extension NSUIFontDescriptor.TraitKey {
    /// The normalized design value.
    static let design = Self(rawValue: "NSCTFontUIFontDesignTrait")
}

extension NSUIFontDescriptor.AttributeName: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
    
    /// A string that specifies the covered languages for the font.
    public static let languages = Self(rawValue: kCTFontLanguagesAttribute as String)
    
    /// A string that specifies the orientation for the glyphs of the font.
    public static let orientation = Self(rawValue: kCTFontOrientationAttribute as String)
    
    /// A string that specifies the recognized format of the font.
    public static let format = Self(rawValue: kCTFontFormatAttribute as String)
    
    /// A string that specifies the font features of the font.
    public static let features = Self(rawValue: kCTFontFeaturesAttribute as String)
    
    /// A string that specifies the font url.
    public static let url = Self(rawValue: kCTFontURLAttribute as String)
    
    /// A string that specifies the font size category.
    public static let sizeCategory = Self(rawValue: "NSCTFontSizeCategoryAttribute")

    /// A string that specifies the font UI usage.
    public static let uiUsage = Self(rawValue: "NSCTFontUIUsageAttribute")
    #if os(macOS)
    /**
     The text style attribute.
 
     The value is an `NSString` object that contains the specified text style.
     */
    public static let textStyle = Self("NSCTFontUIUsageAttribute")
    #endif
}

extension NSUIFontDescriptor.SymbolicTraits: Swift.Hashable, Swift.CustomStringConvertible {
    /// The width of the font’s characters.
    public enum Width: Hashable, Codable {
        /// The font’s characters have a condensed width.
        case condensed
        /// The font’s characters have an expanded width.
        case expanded
        /// The font’s characters have a standard width.
        case standard
    }
    
    /// The width of the font’s characters.
    public var width: Width {
        get { contains(._expanded) ? .expanded : contains(._condensed) ? .condensed : .standard }
        set {
            self[._expanded] = newValue == .expanded
            self[._condensed] = newValue == .condensed
        }
    }
    
    /// The font’s leading value.
    public enum Leading: Hashable, Codable {
        /// The font uses a standard leading value.
        case standard
        /// The font uses a leading value that’s greater than the default.
        case loose
        /// The font uses a leading value that’s less than the default.
        case tight
    }
    
    /// The font’s leading value.
    public var leading: Leading {
        get { contains(._tightLeading) ? .tight : contains(._looseLeading) ? .loose : .standard }
        set {
            self[._tightLeading] = newValue == .tight
            self[._looseLeading] = newValue == .loose
        }
    }
    
    public var description: String {
        var strings: [String] = []
        for element in elements() {
            switch element {
            #if os(macOS)
            case ._bold: strings += "bold"
            case ._italic: strings += "italic"
            case ._monoSpace: strings += "monoSpace"
            case ._vertical: strings += "vertical"
            case ._looseLeading: strings += "looseLeading"
            case ._tightLeading: strings += "tightLeading"
            case ._expanded: strings += "expanded"
            case ._condensed: strings += "condensed"
            #else
            case .traitBold: strings += "traitBold"
            case .traitItalic: strings += "traitItalic"
            case .traitMonoSpace: strings += "traitMonoSpace"
            case .traitVertical: strings += "traitVertical"
            case .traitLooseLeading: strings += "traitLooseLeading"
            case .traitTightLeading: strings += "traitTightLeading"
            case .traitExpanded: strings += "traitExpanded"
            case .traitCondensed: strings += "traitCondensed"
            case .traitUIOptimized: strings += "traitUIOptimized"
            #endif
            case .classMask: strings += "classMask"
            case .classScripts: strings += "classScripts"
            case .classSymbolic: strings += "classSymbolic"
            case .classOrnamentals: strings += "classOrnamentals"
            case .classSansSerif: strings += "classSansSerif"
            case .classSlabSerifs: strings += "classSlabSerifs"
            case .classModernSerifs: strings += "classModernSerifs"
            case .classFreeformSerifs: strings += "classFreeformSerifs"
            case .classClarendonSerifs: strings += "classClarendonSerifs"
            case .classTransitionalSerifs: strings += "classTransitionalSerifs"
            case .classOldStyleSerifs: strings += "classOldStyleSerifs"
            default: strings += "\(element.rawValue)"
            }
        }
        return "[\(strings.joined(separator: ", "))]"
    }
    
    static let _italic = Self(rawValue: 1)
    static let _bold = Self(rawValue: 2)
    static let _expanded = Self(rawValue: 32)
    static let _condensed = Self(rawValue: 64)
    static let _monoSpace = Self(rawValue: 1024)
    static let _vertical = Self(rawValue: 2048)
    static let _tightLeading = Self(rawValue: 32768)
    static let _looseLeading = Self(rawValue: 65536)
}

#if os(macOS)
extension NSUIFontDescriptor {
    /// A dictionary of variation axis tags (e.g. `"wght"`, `"wdth") and their corresponding values.
    var variationAxes: [String: Double] {
        if let variationAxes = _variationAxes {
            return variationAxes
        }
        guard let rawVariations = object(forKey: .variation) as? [NSNumber: NSNumber] else {
            return [:]
        }
        return rawVariations.mapKeys({ UTCreateStringForOSType($0.uint32Value).takeRetainedValue() as String? ?? "Unknown" }).mapValues({ $0.doubleValue })
    }

    fileprivate var _variationAxes: [String: Double]? {
        guard let rawVariations = object(forKey: .variation) as? [NSFontDescriptor.VariationKey: Any] else {
            return nil
        }
        return rawVariations.mapKeys({$0.rawValue}).compactMapValues({ $0 as? NSNumber}).mapValues({$0.doubleValue})
    }

    /// The variation axis of the font.
    internal var variationAxis: VarationAxis? {
        .init(object(forKey: .variation) as? [VariationKey: Any] ?? [:])
    }

    /// The variation axis of a font.
    internal struct VarationAxis: CustomStringConvertible {
        /// The localized name of the variation axis.
        public let name: String
        /// The identifier of the variation axis.
        public let identifier: Int
        /// The minimum valuer of the variation axis.
        public let minimumValue: CGFloat
        /// The maximum valuer of the variation axis.
        public let maximumValue: CGFloat
        /// The default valuer of the variation axis.
        public let defaultValue: CGFloat
    
        public var description: String {
            "(\(identifier), name: \(name), minumum: \(minimumValue), maximum: \(maximumValue), default: \(defaultValue))"
        }
    
        init?(_ variations: [VariationKey: Any]) {
            guard !variations.isEmpty else { return nil }
            self.name = variations[.name] as! String
            self.identifier = variations[.identifier] as! Int
            self.minimumValue = variations[.minimumValue] as! CGFloat
            self.maximumValue = variations[.maximumValue] as! CGFloat
            self.defaultValue = variations[.defaultValue] as! CGFloat
        }
    }

    /// The non-default font feature settings.
    internal var featureSettings: [FeatureSetting] {
        guard let values = object(forKey: .featureSettings) as? [[NSFontDescriptor.FeatureKey: Int]] else { return [] }
        return values.compactMap({ .init($0) })
    }

    internal struct FeatureSetting {
        /**
         The type of the font feature.
 
         The value specifies a font feature type such as ligature, character shape, and so on.
         */
        public let typeIdentifier: Int
        /**
         The selector of the font feature.
 
         The value specifies a font feature selector such as common ligature off, traditional character shape, and so on.
         */
        public let selectorIdentifier: Int

        init?(_ dic: [NSUIFontDescriptor.FeatureKey: Int]) {
            guard let typeID = dic[.typeIdentifier], let selectorID = dic[.selectorIdentifier] else { return nil }
            self.typeIdentifier = typeID
            self.selectorIdentifier = selectorID
        }
    }
}

extension CTFontSymbolicTraits {
    /// The width of the font’s characters.
    public enum Width: Hashable, Codable {
        /// The font’s characters have a condensed width.
        case condensed
        /// The font’s characters have an expanded width.
        case expanded
        /// The font’s characters have a standard width.
        case standard
    }
    
    /// The width of the font’s characters.
    public var width: Width {
        get { contains(.traitExpanded) ? .expanded : contains(.traitCondensed) ? .condensed : .standard }
        set {
            self[.traitExpanded] = newValue == .expanded
            self[.traitCondensed] = newValue == .condensed
        }
    }
    
    /// The font’s leading value.
    public enum Leading: Hashable, Codable {
        /// The font uses a standard leading value.
        case standard
        /// The font uses a leading value that’s greater than the default.
        case loose
        /// The font uses a leading value that’s less than the default.
        case tight
    }
    
    /// The font’s leading value.
    public var leading: Leading {
        get { contains(.traitTightLeading) ? .tight : contains(.traitLooseLeading) ? .loose : .standard }
        set {
            self[.traitTightLeading] = newValue == .tight
            self[.traitLooseLeading] = newValue == .loose
        }
    }
}
#endif
