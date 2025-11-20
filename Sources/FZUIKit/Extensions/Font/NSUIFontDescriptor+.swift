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
    
    /// Returns the font for the specified font size.
    func font(size fontSize: CGFloat) -> NSUIFont? {
        NSUIFont(descriptor: self, size: fontSize)
    }
    
    /**
     Returns an ordered list of font descriptors that the system will use as fallback fonts when the original font does not support a particular Unicode character, according to the specified locale.
     
     When the original font used for text layout and rendering does not support a certain Unicode character from the provided text, the system follows this list to pick a fallback font that includes the character.
     
     The font alternatives in the cascade list match the original font’s style, weight, and width.
     
     - Parameter locale: The locale for which to retrieve the font fallback list.
     - Returns: An array of `NSFontDescriptor` objects representing the fallback fonts. Returns an empty array if no cascade list is available.
     */
    func fontDescriptors(for locale: Locale) -> [NSUIFontDescriptor] {
        CTFontCopyDefaultCascadeListForLanguages(font(size: 0)!, [locale.languageCode ?? "en"] as CFArray) as? [NSUIFontDescriptor] ?? []
    }
    
    ///  The localized family name of the font (e.g., “Helvetica-Bold”).
    var localizedName: String? {
        font(size: 10)?.localizedName(for: .full)?.name
    }
    
    ///  The localized family name of the font (e.g., “Helvetica”).
    var localizedFamilyName: String? {
        font(size: 10)?.localizedName(for: .family)?.name
    }
    
    /// The localized face name of the font (e.g., “Bold”).
    var localizedFaceName: String? {
        font(size: 10)?.localizedName(for: .subFamily)?.name
    }
    
    /*
    ///  The localized family name of the font for the specified locale.
    func localizedName(for locale: Locale) -> String? {
        guard let fontDescriptor = fontDescriptor(for: locale) else { return nil }
        return fontDescriptor.name
    }
    
    ///  The localized family name of the font for the specified locale.
    func localizedFamilyName(for locale: Locale) -> String? {
        guard let fontDescriptor = fontDescriptor(for: locale) else { return nil }
        return fontDescriptor.familyName
    }
    
    /// The localized face name of the font for the specified locale.
    func localizedFaceName(for locale: Locale) -> String? {
        guard let fontDescriptor = fontDescriptor(for: locale) else { return nil }
        return fontDescriptor.faceName
    }
    */
    /*/
     #if os(macOS)
     ///  The localized family name of the font.
     var localizedFamilyName: String? {
         guard let familyName = familyName else { return nil }
         return NSFontManager.shared.localizedName(forFamily: familyName, face: nil)
     }
    
     /// The localized face name of the font.
     var localizedFaceName: String? {
         guard let familyName = familyName, let faceName = faceName else { return nil }
         return NSFontManager.shared.localizedName(forFamily: familyName, face: faceName)
     }
    
     ///  The localized family name of the font for the specified locale.
     func localizedFamilyName(for locale: Locale) -> String? {
         guard let fontDescriptor = fontDescriptor(for: locale) else { return nil }
         return fontDescriptor.localizedFamilyName
     }
    
     /// The localized face name of the font for the specified locale.
     func localizedFaceName(for locale: Locale) -> String? {
         guard let fontDescriptor = fontDescriptor(for: locale) else { return nil }
         return fontDescriptor.localizedFaceName
     }
     #endif
      */
    
    /// The value that overrides the glyph advancement specified by the font.
    var fixedAdvance: CGFloat {
        object(forKey: .fixedAdvance) as? CGFloat ?? 0.0
    }
    
    #if os(macOS)
    /// The set of Unicode characters covered by the font.
    var characterSet: CharacterSet {
        object(forKey: .characterSet) as? CharacterSet ?? NSUIFont(descriptor: self, size: pointSize)!.coveredCharacterSet
    }
    #else
    /// The set of Unicode characters covered by the font.
    var characterSet: CharacterSet? {
        object(forKey: .characterSet) as? CharacterSet
    }
    #endif
    
    #if os(macOS)
    /*
     /// The non-default font feature settings.
     var featureSettings: [FeatureSetting] {
         guard let values = object(forKey: .featureSettings) as? [[NSFontDescriptor.FeatureKey: Int]] else { return [] }
         return values.compactMap({ .init($0) })
     }
      */
    
    struct FeatureSetting {
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
    #endif
    
    /**
     The relative slant angle value.
     
     A value between`-1.0` to `1.0`. The value of `0.0` corresponds to `0` degree clockwise rotation from the vertical and` 1.0` corresponds to `30` degrees clockwise rotation.
     */
    var slant: CGFloat? {
        traits?[.slant] as? CGFloat
    }
    
    /**
     The relative inter-glyph spacing.
     
     A value between `-1.0` and `1.0`. The value of `0.0` corresponds to the regular glyph spacing.
     */
    var width: CGFloat? {
        traits?[.width] as? CGFloat
    }

    /// The system design of the font.
    var design: SystemDesign? {
        if let rawValue = traits?[.design] as? String {
            return SystemDesign(rawValue: rawValue)
        }
        return nil
    }

    /// The weight of the font.
    var weight: NSUIFont.Weight? {
        guard let rawValue = traits?[.weight] as? CGFloat else { return nil }
        return .init(rawValue: rawValue)
    }
    
    /// Returns a new font descriptor based on the current object, but with the specified weight.
    func withWeight(_ weight: NSUIFont.Weight) -> NSUIFontDescriptor {
        var traits = traits ?? [:]
        traits[.weight] = weight.rawValue
        return addingAttributes([.traits : traits])
    }
    
    /// A dictionary of the traits.
    internal var traits: [TraitKey: Any]? {
        (object(forKey: .traits) as? [String: Any])?.mapKeys({ TraitKey(rawValue: $0) })
    }

    /// The text style of the font descriptor.
    @available(macOS 11.0, iOS 10.0, tvOS 10.0, watchOS 3.0, *)
    var textStyle: NSUIFont.TextStyle? {
        guard let rawValue = object(forKey: .textStyle) as? String else { return nil }
        return .init(rawValue: rawValue)
    }
    
    #if os(macOS)
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
    
    /*
     /// A dictionary of variation axis tags (e.g. `"wght"`, `"wdth"`) and their corresponding values.
     var variations: Varations? {
         Swift.print(object(forKey: .variation) ?? "nil")
         guard let variations = object(forKey: .variation) as? [NSFontDescriptor.VariationKey: Any] else { return nil }
         Swift.print(variations.keys.map({$0.rawValue}))
         return Varations(variations)
     }
    
     public struct Varations {
         /// The localized variation axis name.
         public let name: String
         /// The axis identifier value
         public let identifier: Int
         /// The minimum axis value.
         public let minimumValue: Double
         /// The maximum axis value.
         public let maximumValue: Double
         /// The default axis value.
         public let defaultValue: Double
        
         init?(_ variations: [NSFontDescriptor.VariationKey: Any]) {
             guard let name = variations[.name] as? String, let id = variations[.identifier] as? Int, let minValue = variations[.minimumValue] as? Double, let maxValue = variations[.maximumValue] as? Double, let defaultValue = variations[.defaultValue] as? Double else { return nil }
             self.name = name
             self.identifier = id
             self.minimumValue = minValue
             self.maximumValue = maxValue
             self.defaultValue = defaultValue
         }
     }
     */
    #endif
}

public extension NSUIFontDescriptor.TraitKey {
    /// The normalized design value.
    static var design: Self {
        .init(rawValue: "NSCTFontUIFontDesignTrait")
    }
}

extension NSUIFontDescriptor.SymbolicTraits: Hashable {
    static var nsUIBold: Self {
        #if os(macOS)
        .bold
        #else
        .traitBold
        #endif
    }
    
    static var nsUIMonoSpace: Self {
        #if os(macOS)
        .monoSpace
        #else
        .traitMonoSpace
        #endif
    }
    
    static var nsUIItalic: Self {
        #if os(macOS)
        .italic
        #else
        .traitItalic
        #endif
    }
}

public extension NSUIFontDescriptor.AttributeName {
    #if os(macOS)
    /**
     The text style attribute.
     
     The value is an `NSString object that contains the specified text style.
     */
    static let textStyle = NSFontDescriptor.AttributeName.init("NSCTFontUIUsageAttribute")
    #endif
    
    #if canImport(UIKit)
    /// A dictionary that fully describes the font traits.
    static var traits: Self {
        .init(rawValue: "NSCTFontSizeCategoryAttribute")
    }
    #endif

    /// A string that specifies the font size category.
    static var sizeCategory: Self {
        .init(rawValue: "NSCTFontSizeCategoryAttribute")
    }

    /// A string that specifies the font UI usage.
    static var uiUsage: Self {
        .init(rawValue: "NSCTFontUIUsageAttribute")
    }

    /*
     enum UIUsage: String {
         case systemUltraLight = "CTFontUltraLightUsage"
         case systemThin = "CTFontThinUsage"
         case systemLight = "CTFontLightUsage"
         case systemRegular = "CTFontRegularUsage"
         case systemMedium = "CTFontMediumUsage"
         case systemSemiBold = "CTFontDemiUsage"
         case systemBold = "CTFontBoldUsage"
         case systemHeavy = "CTFontHeavyUsage"
         case systemBlack = "CTFontBlackUsage"

         case body = "UICTFontTextStyleBody"
         case callout = "UICTFontTextStyleCallout"
         case caption1 = "UICTFontTextStyleCaption1"
         case caption2 = "UICTFontTextStyleCaption2"
         case headline = "UICTFontTextStyleHeadline"
         case subheadline = "UICTFontTextStyleSubhead"
         case largeTitle = "UICTFontTextStyleTitle0"
         case title1 = "UICTFontTextStyleTitle1"
         case title2 = "UICTFontTextStyleTitle2"
         case title3 = "UICTFontTextStyleTitle3"
         var textstyle: NSUIFont.TextStyle? {
             switch self {
             case .body: return .body
             case .callout: return .callout
             case .caption1: return .caption1
             case .caption2: return .caption2
             case .headline: return .headline
             case .subheadline: return .subheadline
             case .largeTitle: return .largeTitle
             case .title1: return .title1
             case .title2: return .title2
             case .title3: return .title3
             default: return nil
             }
         }
     }
      */
}
