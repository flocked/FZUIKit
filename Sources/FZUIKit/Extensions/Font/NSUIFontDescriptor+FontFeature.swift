//
//  NSUIFontDescriptor+FontFeature.swift
//  
//
//  Created by Florian Zand on 20.06.26.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import FZSwiftUtils

extension NSUIFontDescriptor {
    /// Returns the typographic features supported by the font.
    public var availableFeatures: [FontFeature] {
        let selections = Dictionary(uniqueKeysWithValues: featureSelections.map({ ($0.typeIdentifier, $0.selectorIdentifier) }))
        return (CTFontCopyFeatures(font) as? [[String: Any]] ?? []).compactMap {
            FontFeature($0, selections)
        }
    }

    /// A typographic feature supported by a font.
    public struct FontFeature: CustomStringConvertible {
        /// The localized name of the feature.
        public let name: String
        /// The feature identifier.
        public let identifier: Int?
        /// A localized brief description or tooltip explaining the feature.
        public let tooltipText: String?
        /// A Boolean value indicating whether only one selector can be enabled at a time.
        public let isExclusive: Bool
        /// The OpenType tag associated with the feature.
        public let openTypeTag: String?
        /// A sample string demonstrating the effect of this feature.
        public let sampleText: String?
        /// The selectors available for the feature.
        public let selectors: [FeatureSelector]
        
        public var description: String {
            var strings = [[openTypeTag,
                            "\"\(name)\"",
                            isExclusive ? "isExclusive" : nil,
                            identifier?.string
                           ].nonNil.joined(separator: " ")]
            strings += selectors.map({ "  \($0)" })
            return strings.joined(separator: "\n")
        }
        
        /// A selectable option within a font feature.
        public struct FeatureSelector: CustomStringConvertible {
            /// The localized name of the selector.
            public let name: String
            /// The selector identifier.
            public let identifier: Int?
            /// A Boolean value indicating whether the selector is the default option.
            public let isDefault: Bool
            /// The OpenType tag associated with the selector.
            public let openTypeTag: String?
            /// The OpenType value associated with the selector.
            public let featureValue: Double?
            /// A Boolean value indicating whether the selector is currently selected.
            public internal(set) var isSelected: Bool
            
            public var description: String {
                [openTypeTag,
                 "\"\(name)\"",
                 featureValue?.string,
                 isSelected ? "✓" : nil,
                 isDefault ? "*" : nil,
                 identifier?.string
                ].nonNil.joined(separator: " ")
            }
            
            init?(_ dic: [String: Any]) {
                guard let name = dic["CTFeatureSelectorName"] as? String else { return nil }
                self.name = name
                self.identifier = dic[typed: "CTFeatureSelectorIdentifier"]
                self.featureValue = dic[typed: "CTFeatureOpenTypeValue"]
                self.isDefault = dic[typed: "CTFeatureSelectorDefault"] ?? false
                self.openTypeTag = dic[typed: "CTFeatureOpenTypeTag"]
                self.isSelected = dic[typed: kCTFontFeatureSelectorSettingKey as String] ?? isDefault
            }
        }
        
        init?(_ dic: [String: Any], _ selections: [Int: Int]) {
            guard let name = dic["CTFeatureTypeName"] as? String, var selectors = (dic["CTFeatureTypeSelectors"] as? [[String: Any]])?.compactMap({ FeatureSelector($0) }) else { return nil }
            self.name = name
            self.sampleText = dic[typed: "CTFeatureSampleText"]
            self.tooltipText = dic[typed: "CTFeatureTooltipText"]
            self.openTypeTag = dic[typed: "CTFeatureOpenTypeTag"]
            self.isExclusive = dic[typed: "CTFeatureTypeExclusive"] ?? false
            self.identifier = dic[typed: "CTFeatureTypeIdentifier"]
            if let identifier = identifier, let selection = selections[identifier], selectors.contains(where: { $0.identifier == selection }) {
                selectors.editEach({ $0.isSelected = $0.identifier == selection })
            }
            self.selectors = selectors
        }
    }
}

extension NSUIFontDescriptor {
    /// The non-default font feature settings applied to the descriptor.
    public var featureSelections: [FeatureSelection] {
        return (object(forKey: .featureSettings) as? [[FeatureKey: Int]] ?? []).compactMap { .init($0) }
    }

    /**
     Returns a font descriptor with the specified feature settings.

     The returned descriptor replaces any existing feature settings with the provided values.

     - Parameter featureSettings: The feature settings to apply to the descriptor, or `nil` to remove any feature settings.
     - Returns: A font descriptor containing the specified feature settings.
     */
    public func withFeatureSelections(_ featureSettings: [FeatureSelection]?) -> NSUIFontDescriptor {
        let settings = featureSettings?.map(\.dictionary) ?? []
        var fontAttributes = fontAttributes
        fontAttributes[.featureSettings] = settings.isEmpty ? nil : settings
        return NSUIFontDescriptor(fontAttributes: fontAttributes)
    }
    
    /// A Core Text font feature identified by a feature type and selector.
    public struct FeatureSelection: Hashable, CustomStringConvertible {
        /**
         The font feature type identifier.

         The value identifies a feature type, such as ligatures, number spacing, or character shape.
         */
        public let typeIdentifier: Int
        /**
         The font feature selector identifier.

         The value identifies a selector for the feature type, such as common ligatures off or monospaced numbers.
         */
        public let selectorIdentifier: Int
 
        /// Creates a font feature from the specified type and selector identifier.
        public init(typeIdentifier: Int, selectorIdentifier: Int) {
            self.typeIdentifier = typeIdentifier
            self.selectorIdentifier = selectorIdentifier
        }

        init?(_ dic: [NSUIFontDescriptor.FeatureKey: Int]) {
            #if os(macOS)
            guard let typeID = dic[.typeIdentifier], let selectorID = dic[.selectorIdentifier] else { return nil }
            #else
            guard let typeID = dic[.type], let selectorID = dic[.selector] else { return nil }
            #endif
            self.typeIdentifier = typeID
            self.selectorIdentifier = selectorID
        }

        var dictionary: [NSUIFontDescriptor.FeatureKey: Int] {
            #if os(macOS)
            [.selectorIdentifier: selectorIdentifier, .typeIdentifier: typeIdentifier]
            #else
            [.selector: selectorIdentifier, .type: typeIdentifier]
            #endif
        }

        /// Creates a feature that toggles all typographic features.
        public static func allTypographic(_ state: FeatureState) -> Self {
            .init(typeIdentifier: 0, selectorIdentifier: state.rawValue)
        }

        /// Creates a ligature feature.
        public static func ligatures(_ selector: LigatureSelector) -> Self {
            .init(typeIdentifier: 1, selectorIdentifier: selector.rawValue)
        }

        /// Creates a cursive connection feature.
        public static func cursiveConnection(_ selector: CursiveConnectionSelector) -> Self {
            .init(typeIdentifier: 2, selectorIdentifier: selector.rawValue)
        }

        /// Creates a deprecated letter case feature.
        public static func letterCase(_ selector: LetterCaseSelector) -> Self {
            .init(typeIdentifier: 3, selectorIdentifier: selector.rawValue)
        }

        /// Creates a vertical substitution feature.
        public static func verticalSubstitution(_ state: FeatureState) -> Self {
            .init(typeIdentifier: 4, selectorIdentifier: state.rawValue)
        }

        /// Creates a linguistic rearrangement feature.
        public static func linguisticRearrangement(_ state: FeatureState) -> Self {
            .init(typeIdentifier: 5, selectorIdentifier: state.rawValue)
        }

        /// Creates a number spacing feature.
        public static func numberSpacing(_ selector: NumberSpacingSelector) -> Self {
            .init(typeIdentifier: 6, selectorIdentifier: selector.rawValue)
        }

        /// Creates a smart swash feature.
        public static func smartSwash(_ selector: SmartSwashSelector) -> Self {
            .init(typeIdentifier: 8, selectorIdentifier: selector.rawValue)
        }

        /// Creates a diacritics feature.
        public static func diacritics(_ selector: DiacriticsSelector) -> Self {
            .init(typeIdentifier: 9, selectorIdentifier: selector.rawValue)
        }

        /// Creates a vertical position feature.
        public static func verticalPosition(_ selector: VerticalPositionSelector) -> Self {
            .init(typeIdentifier: 10, selectorIdentifier: selector.rawValue)
        }

        /// Creates a fractions feature.
        public static func fractions(_ selector: FractionsSelector) -> Self {
            .init(typeIdentifier: 11, selectorIdentifier: selector.rawValue)
        }

        /// Creates an overlapping characters feature.
        public static func overlappingCharacters(_ state: FeatureState) -> Self {
            .init(typeIdentifier: 13, selectorIdentifier: state.rawValue)
        }

        /// Creates a typographic extras feature.
        public static func typographicExtras(_ selector: TypographicExtrasSelector) -> Self {
            .init(typeIdentifier: 14, selectorIdentifier: selector.rawValue)
        }

        /// Creates a mathematical extras feature.
        public static func mathematicalExtras(_ selector: MathematicalExtrasSelector) -> Self {
            .init(typeIdentifier: 15, selectorIdentifier: selector.rawValue)
        }

        /// Creates an ornament set feature.
        public static func ornamentSets(_ selector: OrnamentSetsSelector) -> Self {
            .init(typeIdentifier: 16, selectorIdentifier: selector.rawValue)
        }

        /// Creates a character alternatives feature.
        public static func characterAlternatives(_ selector: CharacterAlternativesSelector) -> Self {
            .init(typeIdentifier: 17, selectorIdentifier: selector.rawValue)
        }

        /// Creates a design complexity feature.
        public static func designComplexity(_ selector: DesignComplexitySelector) -> Self {
            .init(typeIdentifier: 18, selectorIdentifier: selector.rawValue)
        }

        /// Creates a style options feature.
        public static func styleOptions(_ selector: StyleOptionsSelector) -> Self {
            .init(typeIdentifier: 19, selectorIdentifier: selector.rawValue)
        }

        /// Creates a character shape feature.
        public static func characterShape(_ selector: CharacterShapeSelector) -> Self {
            .init(typeIdentifier: 20, selectorIdentifier: selector.rawValue)
        }

        /// Creates a number case feature.
        public static func numberCase(_ selector: NumberCaseSelector) -> Self {
            .init(typeIdentifier: 21, selectorIdentifier: selector.rawValue)
        }

        /// Creates a text spacing feature.
        public static func textSpacing(_ selector: TextSpacingSelector) -> Self {
            .init(typeIdentifier: 22, selectorIdentifier: selector.rawValue)
        }

        /// Creates a transliteration feature.
        public static func transliteration(_ selector: TransliterationSelector) -> Self {
            .init(typeIdentifier: 23, selectorIdentifier: selector.rawValue)
        }

        /// Creates an annotation feature.
        public static func annotation(_ selector: AnnotationSelector) -> Self {
            .init(typeIdentifier: 24, selectorIdentifier: selector.rawValue)
        }

        /// Creates a kana spacing feature.
        public static func kanaSpacing(_ selector: KanaSpacingSelector) -> Self {
            .init(typeIdentifier: 25, selectorIdentifier: selector.rawValue)
        }

        /// Creates an ideographic spacing feature.
        public static func ideographicSpacing(_ selector: IdeographicSpacingSelector) -> Self {
            .init(typeIdentifier: 26, selectorIdentifier: selector.rawValue)
        }

        /// Creates a Unicode decomposition feature.
        public static func unicodeDecomposition(_ selector: UnicodeDecompositionSelector) -> Self {
            .init(typeIdentifier: 27, selectorIdentifier: selector.rawValue)
        }

        /// Creates a ruby kana feature.
        public static func rubyKana(_ selector: RubyKanaSelector) -> Self {
            .init(typeIdentifier: 28, selectorIdentifier: selector.rawValue)
        }

        /// Creates a CJK symbol alternatives feature.
        public static func cjkSymbolAlternatives(_ selector: CJKSymbolAlternativesSelector) -> Self {
            .init(typeIdentifier: 29, selectorIdentifier: selector.rawValue)
        }

        /// Creates an ideographic alternatives feature.
        public static func ideographicAlternatives(_ selector: IdeographicAlternativesSelector) -> Self {
            .init(typeIdentifier: 30, selectorIdentifier: selector.rawValue)
        }

        /// Creates a CJK vertical roman placement feature.
        public static func cjkVerticalRomanPlacement(_ selector: CJKVerticalRomanPlacementSelector) -> Self {
            .init(typeIdentifier: 31, selectorIdentifier: selector.rawValue)
        }

        /// Creates an italic CJK roman feature.
        public static func italicCJKRoman(_ selector: ItalicCJKRomanSelector) -> Self {
            .init(typeIdentifier: 32, selectorIdentifier: selector.rawValue)
        }

        /// Creates a case-sensitive layout feature.
        public static func caseSensitiveLayout(_ selector: CaseSensitiveLayoutSelector) -> Self {
            .init(typeIdentifier: 33, selectorIdentifier: selector.rawValue)
        }

        /// Creates an alternate kana feature.
        public static func alternateKana(_ selector: AlternateKanaSelector) -> Self {
            .init(typeIdentifier: 34, selectorIdentifier: selector.rawValue)
        }

        /// Creates a stylistic alternatives feature.
        public static func stylisticAlternatives(_ selector: StylisticAlternativesSelector) -> Self {
            .init(typeIdentifier: 35, selectorIdentifier: selector.rawValue)
        }

        /// Creates a contextual alternates feature.
        public static func contextualAlternates(_ selector: ContextualAlternatesSelector) -> Self {
            .init(typeIdentifier: 36, selectorIdentifier: selector.rawValue)
        }

        /// Creates a lowercase feature.
        public static func lowerCase(_ selector: LowerCaseSelector) -> Self {
            .init(typeIdentifier: 37, selectorIdentifier: selector.rawValue)
        }

        /// Creates an uppercase feature.
        public static func upperCase(_ selector: UpperCaseSelector) -> Self {
            .init(typeIdentifier: 38, selectorIdentifier: selector.rawValue)
        }

        /// Creates a CJK roman spacing feature.
        public static func cjkRomanSpacing(_ selector: CJKRomanSpacingSelector) -> Self {
            .init(typeIdentifier: 103, selectorIdentifier: selector.rawValue)
        }
    }
}

public extension NSUIFontDescriptor.FeatureSelection {
    /// A Boolean-like state for feature selectors that can be enabled or disabled.
    enum FeatureState: Int, Hashable, ExpressibleByBooleanLiteral {
        /// Enables the selected feature.
        case on = 0
        /// Disables the selected feature.
        case off = 1

        /// Creates a feature state from a Boolean literal.
        public init(booleanLiteral value: Bool) {
            self = value ? .on : .off
        }
    }

    /// A selector for ligature-related font features.
    enum LigatureSelector: Hashable {
        /// Selects required ligatures.
        case required(FeatureState)
        /// Selects common ligatures.
        case common(FeatureState)
        /// Selects rare ligatures.
        case rare(FeatureState)
        /// Selects logo ligatures.
        case logos(FeatureState)
        /// Selects rebus picture ligatures.
        case rebusPictures(FeatureState)
        /// Selects diphthong ligatures.
        case diphthong(FeatureState)
        /// Selects squared ligatures.
        case squared(FeatureState)
        /// Selects abbreviated squared ligatures.
        case abbreviatedSquared(FeatureState)
        /// Selects symbol ligatures.
        case symbol(FeatureState)
        /// Selects contextual ligatures.
        case contextual(FeatureState)
        /// Selects historical ligatures.
        case historical(FeatureState)

        /// The Core Text selector identifier for the ligature selector.
        var rawValue: Int {
            switch self {
            case .required(let featureState): 0 + featureState.rawValue
            case .common(let featureState): 2 + featureState.rawValue
            case .rare(let featureState): 4 + featureState.rawValue
            case .logos(let featureState): 6 + featureState.rawValue
            case .rebusPictures(let featureState): 8 + featureState.rawValue
            case .diphthong(let featureState): 10 + featureState.rawValue
            case .squared(let featureState): 12 + featureState.rawValue
            case .abbreviatedSquared(let featureState): 14 + featureState.rawValue
            case .symbol(let featureState): 16 + featureState.rawValue
            case .contextual(let featureState): 18 + featureState.rawValue
            case .historical(let featureState): 20 + featureState.rawValue
            }
        }
    }

    /// A selector for cursive connection behavior.
    enum CursiveConnectionSelector: Int, Hashable {
        /// Selects unconnected cursive forms.
        case unconnected = 0
        /// Selects partially connected cursive forms.
        case partiallyConnected = 1
        /// Selects cursive connected forms.
        case cursive = 2
    }

    /// A selector for deprecated letter case behavior.
    enum LetterCaseSelector: Int, Hashable {
        /// Selects mixed uppercase and lowercase letter forms.
        case upperAndLowerCase = 0
        /// Selects all caps letter forms.
        case allCaps = 1
        /// Selects all lowercase letter forms.
        case allLowerCase = 2
        /// Selects small caps letter forms.
        case smallCaps = 3
        /// Selects initial caps letter forms.
        case initialCaps = 4
        /// Selects initial caps with small caps letter forms.
        case initialCapsAndSmallCaps = 5
    }

    /// A selector for number glyph spacing.
    enum NumberSpacingSelector: Int, Hashable {
        /// Selects monospaced number glyphs.
        case monospacedNumbers = 0
        /// Selects proportional number glyphs.
        case proportionalNumbers = 1
        /// Selects third-width number glyphs.
        case thirdWidthNumbers = 2
        /// Selects quarter-width number glyphs.
        case quarterWidthNumbers = 3
    }

    /// A selector for contextual swash behavior.
    enum SmartSwashSelector: Hashable {
        /// Selects word-initial swashes.
        case wordInitial(FeatureState)
        /// Selects word-final swashes.
        case wordFinal(FeatureState)
        /// Selects line-initial swashes.
        case lineInitial(FeatureState)
        /// Selects line-final swashes.
        case lineFinal(FeatureState)
        /// Selects non-final swashes.
        case nonFinal(FeatureState)

        /// The Core Text selector identifier for the smart swash selector.
        var rawValue: Int {
            switch self {
            case .wordInitial(let featureState): 0 + featureState.rawValue
            case .wordFinal(let featureState): 2 + featureState.rawValue
            case .lineInitial(let featureState): 4 + featureState.rawValue
            case .lineFinal(let featureState): 6 + featureState.rawValue
            case .nonFinal(let featureState): 8 + featureState.rawValue
            }
        }
    }

    /// A selector for diacritic display behavior.
    enum DiacriticsSelector: Int, Hashable {
        /// Shows diacritic marks.
        case show = 0
        /// Hides diacritic marks.
        case hide = 1
        /// Decomposes diacritic marks.
        case decompose = 2
    }

    /// A selector for vertical glyph positioning.
    enum VerticalPositionSelector: Int, Hashable {
        /// Selects the normal vertical position.
        case normal = 0
        /// Selects superior glyph positioning.
        case superiors = 1
        /// Selects inferior glyph positioning.
        case inferiors = 2
        /// Selects ordinal glyph positioning.
        case ordinals = 3
        /// Selects scientific inferior glyph positioning.
        case scientificInferiors = 4
    }

    /// A selector for fraction formatting.
    enum FractionsSelector: Int, Hashable {
        /// Disables fraction substitution.
        case none = 0
        /// Selects vertical fractions.
        case vertical = 1
        /// Selects diagonal fractions.
        case diagonal = 2
    }

    /// A selector for typographic substitutions and extras.
    enum TypographicExtrasSelector: Hashable {
        /// Selects hyphen-to-em-dash conversion.
        case hyphensToEmDash(FeatureState)
        /// Selects hyphen-to-en-dash conversion.
        case hyphenToEnDash(FeatureState)
        /// Selects slashed zero forms.
        case slashedZero(FeatureState)
        /// Selects interrobang formation.
        case formInterrobang(FeatureState)
        /// Selects smart quote substitution.
        case smartQuotes(FeatureState)
        /// Selects periods-to-ellipsis conversion.
        case periodsToEllipsis(FeatureState)

        /// The Core Text selector identifier for the typographic extras selector.
        var rawValue: Int {
            switch self {
            case .hyphensToEmDash(let featureState): 0 + featureState.rawValue
            case .hyphenToEnDash(let featureState): 2 + featureState.rawValue
            case .slashedZero(let featureState): 4 + featureState.rawValue
            case .formInterrobang(let featureState): 6 + featureState.rawValue
            case .smartQuotes(let featureState): 8 + featureState.rawValue
            case .periodsToEllipsis(let featureState): 10 + featureState.rawValue
            }
        }
    }

    /// A selector for mathematical substitutions and extras.
    enum MathematicalExtrasSelector: Hashable {
        /// Selects hyphen-to-minus conversion.
        case hyphenToMinus(FeatureState)
        /// Selects asterisk-to-multiply conversion.
        case asteriskToMultiply(FeatureState)
        /// Selects slash-to-divide conversion.
        case slashToDivide(FeatureState)
        /// Selects inequality ligatures.
        case inequalityLigatures(FeatureState)
        /// Selects exponent forms.
        case exponents(FeatureState)
        /// Selects mathematical Greek forms.
        case mathematicalGreek(FeatureState)

        /// The Core Text selector identifier for the mathematical extras selector.
        var rawValue: Int {
            switch self {
            case .hyphenToMinus(let featureState): 0 + featureState.rawValue
            case .asteriskToMultiply(let featureState): 2 + featureState.rawValue
            case .slashToDivide(let featureState): 4 + featureState.rawValue
            case .inequalityLigatures(let featureState): 6 + featureState.rawValue
            case .exponents(let featureState): 8 + featureState.rawValue
            case .mathematicalGreek(let featureState): 10 + featureState.rawValue
            }
        }
    }

    /// A selector for ornament glyph sets.
    enum OrnamentSetsSelector: Int, Hashable {
        /// Disables ornament substitutions.
        case none = 0
        /// Selects dingbat ornaments.
        case dingbats = 1
        /// Selects pi character ornaments.
        case piCharacters = 2
        /// Selects fleuron ornaments.
        case fleurons = 3
        /// Selects decorative border ornaments.
        case decorativeBorders = 4
        /// Selects international symbol ornaments.
        case internationalSymbols = 5
        /// Selects math symbol ornaments.
        case mathSymbols = 6
    }

    /// A selector for character alternative behavior.
    enum CharacterAlternativesSelector: Int, Hashable {
        /// Disables character alternatives.
        case none = 0
    }

    /// A selector for design complexity levels.
    enum DesignComplexitySelector: Int, Hashable {
        /// Selects design complexity level one.
        case level1 = 0
        /// Selects design complexity level two.
        case level2 = 1
        /// Selects design complexity level three.
        case level3 = 2
        /// Selects design complexity level four.
        case level4 = 3
        /// Selects design complexity level five.
        case level5 = 4
    }

    /// A selector for stylistic text options.
    enum StyleOptionsSelector: Int, Hashable {
        /// Disables style options.
        case none = 0
        /// Selects display text styling.
        case displayText = 1
        /// Selects engraved text styling.
        case engravedText = 2
        /// Selects illuminated caps styling.
        case illuminatedCaps = 3
        /// Selects titling caps styling.
        case titlingCaps = 4
        /// Selects tall caps styling.
        case tallCaps = 5
    }

    /// A selector for regional and stylistic character shapes.
    enum CharacterShapeSelector: Int, Hashable {
        /// Selects traditional character shapes.
        case traditionalCharacters = 0
        /// Selects simplified character shapes.
        case simplifiedCharacters = 1
        /// Selects JIS 1978 character shapes.
        case jis1978Characters = 2
        /// Selects JIS 1983 character shapes.
        case jis1983Characters = 3
        /// Selects JIS 1990 character shapes.
        case jis1990Characters = 4
        /// Selects the first traditional alternate character shape.
        case traditionalAltOne = 5
        /// Selects the second traditional alternate character shape.
        case traditionalAltTwo = 6
        /// Selects the third traditional alternate character shape.
        case traditionalAltThree = 7
        /// Selects the fourth traditional alternate character shape.
        case traditionalAltFour = 8
        /// Selects the fifth traditional alternate character shape.
        case traditionalAltFive = 9
        /// Selects expert character shapes.
        case expertCharacters = 10
        /// Selects JIS 2004 character shapes.
        case jis2004Characters = 11
        /// Selects Hojo character shapes.
        case hojoCharacters = 12
        /// Selects NLC character shapes.
        case nlcCharacters = 13
        /// Selects traditional names character shapes.
        case traditionalNamesCharacters = 14
    }

    /// A selector for number case forms.
    enum NumberCaseSelector: Int, Hashable {
        /// Selects lowercase number forms.
        case lowerCaseNumbers = 0
        /// Selects uppercase number forms.
        case upperCaseNumbers = 1
    }

    /// A selector for text glyph spacing.
    enum TextSpacingSelector: Int, Hashable {
        /// Selects proportional text spacing.
        case proportional = 0
        /// Selects monospaced text spacing.
        case monospaced = 1
        /// Selects half-width text spacing.
        case halfWidth = 2
        /// Selects third-width text spacing.
        case thirdWidth = 3
        /// Selects quarter-width text spacing.
        case quarterWidth = 4
        /// Selects alternate proportional text spacing.
        case alternateProportional = 5
        /// Selects alternate half-width text spacing.
        case alternateHalfWidth = 6
    }

    /// A selector for script transliteration behavior.
    enum TransliterationSelector: Int, Hashable {
        /// Disables transliteration.
        case none = 0
        /// Selects Hanja-to-Hangul transliteration.
        case hanjaToHangul = 1
        /// Selects Hiragana-to-Katakana transliteration.
        case hiraganaToKatakana = 2
        /// Selects Katakana-to-Hiragana transliteration.
        case katakanaToHiragana = 3
        /// Selects kana-to-romanization transliteration.
        case kanaToRomanization = 4
        /// Selects romanization-to-Hiragana transliteration.
        case romanizationToHiragana = 5
        /// Selects romanization-to-Katakana transliteration.
        case romanizationToKatakana = 6
        /// Selects the first alternate Hanja-to-Hangul transliteration.
        case hanjaToHangulAltOne = 7
        /// Selects the second alternate Hanja-to-Hangul transliteration.
        case hanjaToHangulAltTwo = 8
        /// Selects the third alternate Hanja-to-Hangul transliteration.
        case hanjaToHangulAltThree = 9
    }

    /// A selector for annotation glyph forms.
    enum AnnotationSelector: Int, Hashable {
        /// Disables annotation forms.
        case none = 0
        /// Selects box annotation forms.
        case box = 1
        /// Selects rounded box annotation forms.
        case roundedBox = 2
        /// Selects circle annotation forms.
        case circle = 3
        /// Selects inverted circle annotation forms.
        case invertedCircle = 4
        /// Selects parenthesis annotation forms.
        case parenthesis = 5
        /// Selects period annotation forms.
        case period = 6
        /// Selects roman numeral annotation forms.
        case romanNumeral = 7
        /// Selects diamond annotation forms.
        case diamond = 8
        /// Selects inverted box annotation forms.
        case invertedBox = 9
        /// Selects inverted rounded box annotation forms.
        case invertedRoundedBox = 10
    }

    /// A selector for kana glyph spacing.
    enum KanaSpacingSelector: Int, Hashable {
        /// Selects full-width kana spacing.
        case fullWidth = 0
        /// Selects proportional kana spacing.
        case proportional = 1
    }

    /// A selector for ideographic glyph spacing.
    enum IdeographicSpacingSelector: Int, Hashable {
        /// Selects full-width ideographic spacing.
        case fullWidth = 0
        /// Selects proportional ideographic spacing.
        case proportional = 1
        /// Selects half-width ideographic spacing.
        case halfWidth = 2
    }

    /// A selector for Unicode composition and decomposition behavior.
    enum UnicodeDecompositionSelector: Hashable {
        /// Selects canonical composition.
        case canonicalComposition(FeatureState)
        /// Selects compatibility composition.
        case compatibilityComposition(FeatureState)
        /// Selects transcoding composition.
        case transcodingComposition(FeatureState)

        /// The Core Text selector identifier for the Unicode decomposition selector.
        var rawValue: Int {
            switch self {
            case .canonicalComposition(let featureState): 0 + featureState.rawValue
            case .compatibilityComposition(let featureState): 2 + featureState.rawValue
            case .transcodingComposition(let featureState): 4 + featureState.rawValue
            }
        }
    }

    /// A selector for ruby kana forms.
    enum RubyKanaSelector: Int, Hashable {
        /// Selects no ruby kana forms.
        case none = 0
        /// Selects legacy ruby kana forms.
        case ruby = 1
        /// Enables ruby kana forms.
        case on = 2
        /// Disables ruby kana forms.
        case off = 3
    }

    /// A selector for CJK symbol alternatives.
    enum CJKSymbolAlternativesSelector: Int, Hashable {
        /// Disables CJK symbol alternatives.
        case none = 0
        /// Selects the first CJK symbol alternative.
        case altOne = 1
        /// Selects the second CJK symbol alternative.
        case altTwo = 2
        /// Selects the third CJK symbol alternative.
        case altThree = 3
        /// Selects the fourth CJK symbol alternative.
        case altFour = 4
        /// Selects the fifth CJK symbol alternative.
        case altFive = 5
    }

    /// A selector for ideographic alternatives.
    enum IdeographicAlternativesSelector: Int, Hashable {
        /// Disables ideographic alternatives.
        case none = 0
        /// Selects the first ideographic alternative.
        case altOne = 1
        /// Selects the second ideographic alternative.
        case altTwo = 2
        /// Selects the third ideographic alternative.
        case altThree = 3
        /// Selects the fourth ideographic alternative.
        case altFour = 4
        /// Selects the fifth ideographic alternative.
        case altFive = 5
    }

    /// A selector for roman glyph placement in vertical CJK text.
    enum CJKVerticalRomanPlacementSelector: Int, Hashable {
        /// Centers roman glyphs in vertical CJK text.
        case centered = 0
        /// Aligns roman glyphs to the horizontal baseline in vertical CJK text.
        case horizontalBaseline = 1
    }

    /// A selector for italic roman forms in CJK text.
    enum ItalicCJKRomanSelector: Int, Hashable {
        /// Selects no italic CJK roman forms.
        case none = 0
        /// Selects legacy italic CJK roman forms.
        case italic = 1
        /// Enables italic CJK roman forms.
        case on = 2
        /// Disables italic CJK roman forms.
        case off = 3
    }

    /// A selector for case-sensitive layout and spacing behavior.
    enum CaseSensitiveLayoutSelector: Hashable {
        /// Selects case-sensitive layout.
        case layout(FeatureState)
        /// Selects case-sensitive spacing.
        case spacing(FeatureState)

        /// The Core Text selector identifier for the case-sensitive layout selector.
        var rawValue: Int {
            switch self {
            case .layout(let featureState): 0 + featureState.rawValue
            case .spacing(let featureState): 2 + featureState.rawValue
            }
        }
    }

    /// A selector for alternate kana forms.
    enum AlternateKanaSelector: Hashable {
        /// Selects alternate horizontal kana.
        case horizontal(FeatureState)
        /// Selects alternate vertical kana.
        case vertical(FeatureState)

        /// The Core Text selector identifier for the alternate kana selector.
        var rawValue: Int {
            switch self {
            case .horizontal(let featureState): 0 + featureState.rawValue
            case .vertical(let featureState): 2 + featureState.rawValue
            }
        }
    }

    /// A selector for numbered stylistic alternatives.
    enum StylisticAlternativesSelector: Hashable {
        /// Disables stylistic alternatives.
        case none
        /// Selects a numbered stylistic alternative from one through twenty.
        case alt(Int, FeatureState)

        /// The Core Text selector identifier for the stylistic alternatives selector.
        var rawValue: Int {
            switch self {
            case .none:
                return 0
            case .alt(let number, let featureState):
                precondition((1...20).contains(number), "Stylistic alternative number must be between 1 and 20.")
                return (number * 2) + featureState.rawValue
            }
        }
    }

    /// A selector for contextual alternate forms.
    enum ContextualAlternatesSelector: Hashable {
        /// Selects contextual alternates.
        case contextual(FeatureState)
        /// Selects swash alternates.
        case swash(FeatureState)
        /// Selects contextual swash alternates.
        case contextualSwash(FeatureState)

        /// The Core Text selector identifier for the contextual alternates selector.
        var rawValue: Int {
            switch self {
            case .contextual(let featureState): 0 + featureState.rawValue
            case .swash(let featureState): 2 + featureState.rawValue
            case .contextualSwash(let featureState): 4 + featureState.rawValue
            }
        }
    }

    /// A selector for lowercase glyph forms.
    enum LowerCaseSelector: Int, Hashable {
        /// Selects default lowercase forms.
        case `default` = 0
        /// Selects lowercase small caps forms.
        case smallCaps = 1
        /// Selects lowercase petite caps forms.
        case petiteCaps = 2
    }

    /// A selector for uppercase glyph forms.
    enum UpperCaseSelector: Int, Hashable {
        /// Selects default uppercase forms.
        case `default` = 0
        /// Selects uppercase small caps forms.
        case smallCaps = 1
        /// Selects uppercase petite caps forms.
        case petiteCaps = 2
    }

    /// A selector for roman glyph spacing in CJK text.
    enum CJKRomanSpacingSelector: Int, Hashable {
        /// Selects half-width CJK roman spacing.
        case halfWidth = 0
        /// Selects proportional CJK roman spacing.
        case proportional = 1
        /// Selects default CJK roman spacing.
        case `default` = 2
        /// Selects full-width CJK roman spacing.
        case fullWidth = 3
    }
}

public extension NSUIFontDescriptor.FeatureSelection {
    var description: String {
        switch (typeIdentifier, selectorIdentifier) {
        case (0, 0): return "allTypographic.on"
        case (0, 1): return "allTypographic.off"
        case (1, 0): return "ligatures.required.on"
        case (1, 1): return "ligatures.required.off"
        case (1, 2): return "ligatures.common.on"
        case (1, 3): return "ligatures.common.off"
        case (1, 4): return "ligatures.rare.on"
        case (1, 5): return "ligatures.rare.off"
        case (1, 6): return "ligatures.logos.on"
        case (1, 7): return "ligatures.logos.off"
        case (1, 8): return "ligatures.rebusPictures.on"
        case (1, 9): return "ligatures.rebusPictures.off"
        case (1, 10): return "ligatures.diphthong.on"
        case (1, 11): return "ligatures.diphthong.off"
        case (1, 12): return "ligatures.squared.on"
        case (1, 13): return "ligatures.squared.off"
        case (1, 14): return "ligatures.abbreviatedSquared.on"
        case (1, 15): return "ligatures.abbreviatedSquared.off"
        case (1, 16): return "ligatures.symbol.on"
        case (1, 17): return "ligatures.symbol.off"
        case (1, 18): return "ligatures.contextual.on"
        case (1, 19): return "ligatures.contextual.off"
        case (1, 20): return "ligatures.historical.on"
        case (1, 21): return "ligatures.historical.off"
        case (2, 0): return "cursiveConnection.unconnected"
        case (2, 1): return "cursiveConnection.partiallyConnected"
        case (2, 2): return "cursiveConnection.cursive"
        case (3, 0): return "letterCase.upperAndLowerCase"
        case (3, 1): return "letterCase.allCaps"
        case (3, 2): return "letterCase.allLowerCase"
        case (3, 3): return "letterCase.smallCaps"
        case (3, 4): return "letterCase.initialCaps"
        case (3, 5): return "letterCase.initialCapsAndSmallCaps"
        case (4, 0): return "verticalSubstitution.on"
        case (4, 1): return "verticalSubstitution.off"
        case (5, 0): return "linguisticRearrangement.on"
        case (5, 1): return "linguisticRearrangement.off"
        case (6, 0): return "numberSpacing.monospacedNumbers"
        case (6, 1): return "numberSpacing.proportionalNumbers"
        case (6, 2): return "numberSpacing.thirdWidthNumbers"
        case (6, 3): return "numberSpacing.quarterWidthNumbers"
        case (8, 0): return "smartSwash.wordInitial.on"
        case (8, 1): return "smartSwash.wordInitial.off"
        case (8, 2): return "smartSwash.wordFinal.on"
        case (8, 3): return "smartSwash.wordFinal.off"
        case (8, 4): return "smartSwash.lineInitial.on"
        case (8, 5): return "smartSwash.lineInitial.off"
        case (8, 6): return "smartSwash.lineFinal.on"
        case (8, 7): return "smartSwash.lineFinal.off"
        case (8, 8): return "smartSwash.nonFinal.on"
        case (8, 9): return "smartSwash.nonFinal.off"
        case (9, 0): return "diacritics.show"
        case (9, 1): return "diacritics.hide"
        case (9, 2): return "diacritics.decompose"
        case (10, 0): return "verticalPosition.normal"
        case (10, 1): return "verticalPosition.superiors"
        case (10, 2): return "verticalPosition.inferiors"
        case (10, 3): return "verticalPosition.ordinals"
        case (10, 4): return "verticalPosition.scientificInferiors"
        case (11, 0): return "fractions.none"
        case (11, 1): return "fractions.vertical"
        case (11, 2): return "fractions.diagonal"
        case (13, 0): return "overlappingCharacters.on"
        case (13, 1): return "overlappingCharacters.off"
        case (14, 0): return "typographicExtras.hyphensToEmDash.on"
        case (14, 1): return "typographicExtras.hyphensToEmDash.off"
        case (14, 2): return "typographicExtras.hyphenToEnDash.on"
        case (14, 3): return "typographicExtras.hyphenToEnDash.off"
        case (14, 4): return "typographicExtras.slashedZero.on"
        case (14, 5): return "typographicExtras.slashedZero.off"
        case (14, 6): return "typographicExtras.formInterrobang.on"
        case (14, 7): return "typographicExtras.formInterrobang.off"
        case (14, 8): return "typographicExtras.smartQuotes.on"
        case (14, 9): return "typographicExtras.smartQuotes.off"
        case (14, 10): return "typographicExtras.periodsToEllipsis.on"
        case (14, 11): return "typographicExtras.periodsToEllipsis.off"
        case (15, 0): return "mathematicalExtras.hyphenToMinus.on"
        case (15, 1): return "mathematicalExtras.hyphenToMinus.off"
        case (15, 2): return "mathematicalExtras.asteriskToMultiply.on"
        case (15, 3): return "mathematicalExtras.asteriskToMultiply.off"
        case (15, 4): return "mathematicalExtras.slashToDivide.on"
        case (15, 5): return "mathematicalExtras.slashToDivide.off"
        case (15, 6): return "mathematicalExtras.inequalityLigatures.on"
        case (15, 7): return "mathematicalExtras.inequalityLigatures.off"
        case (15, 8): return "mathematicalExtras.exponents.on"
        case (15, 9): return "mathematicalExtras.exponents.off"
        case (15, 10): return "mathematicalExtras.mathematicalGreek.on"
        case (15, 11): return "mathematicalExtras.mathematicalGreek.off"
        case (16, 0): return "ornamentSets.none"
        case (16, 1): return "ornamentSets.dingbats"
        case (16, 2): return "ornamentSets.piCharacters"
        case (16, 3): return "ornamentSets.fleurons"
        case (16, 4): return "ornamentSets.decorativeBorders"
        case (16, 5): return "ornamentSets.internationalSymbols"
        case (16, 6): return "ornamentSets.mathSymbols"
        case (17, 0): return "characterAlternatives.none"
        case (18, 0): return "designComplexity.level1"
        case (18, 1): return "designComplexity.level2"
        case (18, 2): return "designComplexity.level3"
        case (18, 3): return "designComplexity.level4"
        case (18, 4): return "designComplexity.level5"
        case (19, 0): return "styleOptions.none"
        case (19, 1): return "styleOptions.displayText"
        case (19, 2): return "styleOptions.engravedText"
        case (19, 3): return "styleOptions.illuminatedCaps"
        case (19, 4): return "styleOptions.titlingCaps"
        case (19, 5): return "styleOptions.tallCaps"
        case (20, 0): return "characterShape.traditionalCharacters"
        case (20, 1): return "characterShape.simplifiedCharacters"
        case (20, 2): return "characterShape.jis1978Characters"
        case (20, 3): return "characterShape.jis1983Characters"
        case (20, 4): return "characterShape.jis1990Characters"
        case (20, 5): return "characterShape.traditionalAltOne"
        case (20, 6): return "characterShape.traditionalAltTwo"
        case (20, 7): return "characterShape.traditionalAltThree"
        case (20, 8): return "characterShape.traditionalAltFour"
        case (20, 9): return "characterShape.traditionalAltFive"
        case (20, 10): return "characterShape.expertCharacters"
        case (20, 11): return "characterShape.jis2004Characters"
        case (20, 12): return "characterShape.hojoCharacters"
        case (20, 13): return "characterShape.nlcCharacters"
        case (20, 14): return "characterShape.traditionalNamesCharacters"
        case (21, 0): return "numberCase.lowerCaseNumbers"
        case (21, 1): return "numberCase.upperCaseNumbers"
        case (22, 0): return "textSpacing.proportional"
        case (22, 1): return "textSpacing.monospaced"
        case (22, 2): return "textSpacing.halfWidth"
        case (22, 3): return "textSpacing.thirdWidth"
        case (22, 4): return "textSpacing.quarterWidth"
        case (22, 5): return "textSpacing.alternateProportional"
        case (22, 6): return "textSpacing.alternateHalfWidth"
        case (23, 0): return "transliteration.none"
        case (23, 1): return "transliteration.hanjaToHangul"
        case (23, 2): return "transliteration.hiraganaToKatakana"
        case (23, 3): return "transliteration.katakanaToHiragana"
        case (23, 4): return "transliteration.kanaToRomanization"
        case (23, 5): return "transliteration.romanizationToHiragana"
        case (23, 6): return "transliteration.romanizationToKatakana"
        case (23, 7): return "transliteration.hanjaToHangulAltOne"
        case (23, 8): return "transliteration.hanjaToHangulAltTwo"
        case (23, 9): return "transliteration.hanjaToHangulAltThree"
        case (24, 0): return "annotation.none"
        case (24, 1): return "annotation.box"
        case (24, 2): return "annotation.roundedBox"
        case (24, 3): return "annotation.circle"
        case (24, 4): return "annotation.invertedCircle"
        case (24, 5): return "annotation.parenthesis"
        case (24, 6): return "annotation.period"
        case (24, 7): return "annotation.romanNumeral"
        case (24, 8): return "annotation.diamond"
        case (24, 9): return "annotation.invertedBox"
        case (24, 10): return "annotation.invertedRoundedBox"
        case (25, 0): return "kanaSpacing.fullWidth"
        case (25, 1): return "kanaSpacing.proportional"
        case (26, 0): return "ideographicSpacing.fullWidth"
        case (26, 1): return "ideographicSpacing.proportional"
        case (26, 2): return "ideographicSpacing.halfWidth"
        case (27, 0): return "unicodeDecomposition.canonicalComposition.on"
        case (27, 1): return "unicodeDecomposition.canonicalComposition.off"
        case (27, 2): return "unicodeDecomposition.compatibilityComposition.on"
        case (27, 3): return "unicodeDecomposition.compatibilityComposition.off"
        case (27, 4): return "unicodeDecomposition.transcodingComposition.on"
        case (27, 5): return "unicodeDecomposition.transcodingComposition.off"
        case (28, 0): return "rubyKana.none"
        case (28, 1): return "rubyKana.ruby"
        case (28, 2): return "rubyKana.on"
        case (28, 3): return "rubyKana.off"
        case (29, 0): return "cjkSymbolAlternatives.none"
        case (29, 1): return "cjkSymbolAlternatives.altOne"
        case (29, 2): return "cjkSymbolAlternatives.altTwo"
        case (29, 3): return "cjkSymbolAlternatives.altThree"
        case (29, 4): return "cjkSymbolAlternatives.altFour"
        case (29, 5): return "cjkSymbolAlternatives.altFive"
        case (30, 0): return "ideographicAlternatives.none"
        case (30, 1): return "ideographicAlternatives.altOne"
        case (30, 2): return "ideographicAlternatives.altTwo"
        case (30, 3): return "ideographicAlternatives.altThree"
        case (30, 4): return "ideographicAlternatives.altFour"
        case (30, 5): return "ideographicAlternatives.altFive"
        case (31, 0): return "cjkVerticalRomanPlacement.centered"
        case (31, 1): return "cjkVerticalRomanPlacement.horizontalBaseline"
        case (32, 0): return "italicCJKRoman.none"
        case (32, 1): return "italicCJKRoman.italic"
        case (32, 2): return "italicCJKRoman.on"
        case (32, 3): return "italicCJKRoman.off"
        case (33, 0): return "caseSensitiveLayout.layout.on"
        case (33, 1): return "caseSensitiveLayout.layout.off"
        case (33, 2): return "caseSensitiveLayout.spacing.on"
        case (33, 3): return "caseSensitiveLayout.spacing.off"
        case (34, 0): return "alternateKana.horizontal.on"
        case (34, 1): return "alternateKana.horizontal.off"
        case (34, 2): return "alternateKana.vertical.on"
        case (34, 3): return "alternateKana.vertical.off"
        case (35, 0): return "stylisticAlternatives.none"
        case (35, 2...41):
            let number = selectorIdentifier / 2
            let state = selectorIdentifier.isMultiple(of: 2) ? "on" : "off"
            return "stylisticAlternatives.alt\(number).\(state)"
        case (36, 0): return "contextualAlternates.contextual.on"
        case (36, 1): return "contextualAlternates.contextual.off"
        case (36, 2): return "contextualAlternates.swash.on"
        case (36, 3): return "contextualAlternates.swash.off"
        case (36, 4): return "contextualAlternates.contextualSwash.on"
        case (36, 5): return "contextualAlternates.contextualSwash.off"
        case (37, 0): return "lowerCase.default"
        case (37, 1): return "lowerCase.smallCaps"
        case (37, 2): return "lowerCase.petiteCaps"
        case (38, 0): return "upperCase.default"
        case (38, 1): return "upperCase.smallCaps"
        case (38, 2): return "upperCase.petiteCaps"
        case (103, 0): return "cjkRomanSpacing.halfWidth"
        case (103, 1): return "cjkRomanSpacing.proportional"
        case (103, 2): return "cjkRomanSpacing.default"
        case (103, 3): return "cjkRomanSpacing.fullWidth"
        default: return "FeatureSelection(typeIdentifier: \(typeIdentifier), selectorIdentifier: \(selectorIdentifier))"
        }
    }
}

fileprivate extension Dictionary where Key == String {
    subscript(key: CFString) -> Value? {
        self[key as String]
    }
}

fileprivate extension Dictionary where Key == String, Value == Any {
    subscript<V>(typed key: CFString) -> V? {
        self[key as String] as? V
    }
}
