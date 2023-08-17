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

public extension NSUIFontDescriptor.TraitKey {
    enum Design: String {
        case rounded = "NSCTFontUIFontDesignRounded"
        case monospaced = "NSCTFontUIFontDesignMonospaced"
        case serif = "NSCTFontUIFontDesignSerif"
    }

    /// The normalized design value.
    static var design: Self {
        return .init(rawValue: "NSCTFontUIFontDesignTrait")
    }
}


public extension NSUIFontDescriptor.AttributeName {
    /// An optional string object that specifies the font size category.
    static var sizeCategory: Self {
        return .init(rawValue: "NSCTFontSizeCategoryAttribute")
    }

    /// An optional string object that specifies the font UI usage.
    static var uiUsage: Self {
        return .init(rawValue: "NSCTFontUIUsageAttribute")
    }

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
    }
}
