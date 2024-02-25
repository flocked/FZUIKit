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
    
    /// A dictionary that describes the font’s variation axis.
    var variation: [VariationKey: Any]? {
        object(forKey: .variation) as? [VariationKey: Any]
    }
    #endif
    
    /// The value that overrides the glyph advancement specified by the font.
    var fixedAdvance: CGFloat? {
        object(forKey: .fixedAdvance) as? CGFloat
    }
    
    /// The set of Unicode characters covered by the font.
    var characterSet: CharacterSet? {
        object(forKey: .characterSet) as? CharacterSet
    }
    
    /// The relative slant angle value.
    var slant: CGFloat? {
        traits?[.slant] as? CGFloat
    }
    
    /// The relative inter-glyph spacing.
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
        if let rawValue = traits?[.weight] as? CGFloat {
            switch rawValue {
            case -0.8: return .ultraLight
            case -0.6: return .thin
            case -0.4: return .light
            case 0: return .regular
            case 0.23: return .medium
            case 0.3: return .semibold
            case 0.4: return .bold
            case 0.56: return .heavy
            case 0.62: return .black
            default: return nil
            }
        }
        return nil
    }
    
    /// A dictionary of the traits.
    internal var traits: [TraitKey: Any]? {
        object(forKey: .traits) as? [TraitKey: Any]
    }

    /// The text style of the font descriptor.
    @available(macOS 11.0, iOS 10.0, tvOS 10.0, watchOS 3.0, *)
    var textStyle: NSUIFont.TextStyle? {
        if let rawValue = fontAttributes[.uiUsage] as? String, rawValue.contains("UICTFontTextStyle") {
            switch rawValue {
            case let str where str.contains("Body"): return .body
            case let str where str.contains("Callout"): return .callout
            case let str where str.contains("Caption1"): return .caption1
            case let str where str.contains("Caption2"): return .caption2
            case let str where str.contains("Headline"): return .headline
            case let str where str.contains("Subhead"): return .subheadline
            #if os(macOS) || os(iOS)
                case let str where str.contains("Title0"): return .largeTitle
            #endif
            case let str where str.contains("Title1"): return .title1
            case let str where str.contains("Title2"): return .title2
            case let str where str.contains("Title3"): return .title3
            default: break
            }
            return NSUIFont.TextStyle(rawValue: rawValue)
        }
        return nil
    }
}

public extension NSUIFontDescriptor.TraitKey {
    /// The normalized design value.
    static var design: Self {
        .init(rawValue: "NSCTFontUIFontDesignTrait")
    }
}

extension NSUIFontDescriptor.SymbolicTraits: Hashable {
    
}

public extension NSUIFontDescriptor.AttributeName {
    #if canImport(UIKit)
        /// A dictionary that fully describes the font traits.
        static var traits: Self {
            .init(rawValue: "NSCTFontSizeCategoryAttribute")
        }
    #endif

    /// An optional string object that specifies the font size category.
    static var sizeCategory: Self {
        .init(rawValue: "NSCTFontSizeCategoryAttribute")
    }

    /// An optional string object that specifies the font UI usage.
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
