//
//  NSFont+FontFamily.swift
//
//
//  Created by Florian Zand on 25.02.24.
//

#if os(macOS)
import AppKit

extension NSFont {
    /// the font families available in the system.
    public static var availableFontFamilies: [FontFamily] {
        NSFontManager.shared.availableFontFamilies.compactMap({FontFamily($0)})
    }
    
    /// The font family.
    public var fontFamily: FontFamily? {
        guard let familyName = familyName, NSFontManager.shared.availableFontFamilies.contains(familyName) else { return nil }
        return FontFamily(familyName)
    }
        
    /// Font family.
    public struct FontFamily: Hashable {
        
        /// The name of the font family.
        public let name: String
        
        /// The localized name of the font family.
        public let localizedName: String
        
        /// The members of the font family (e.g. `regular`, `light` or `bold`).
        public let members: [FontMember]
        
        /// The font with the specified size.
        public func font(withSize size: CGFloat = NSFont.systemFontSize) -> NSFont? {
            NSFont(name: name, size: size)
        }
        
        init(_ name: String) {
            self.name = name
            let localizedName = NSFontManager.shared.localizedName(forFamily: name, face: nil)
            self.localizedName = localizedName
            self.members = (NSFontManager.shared.availableMembers(ofFontFamily: name) ?? []).compactMap({FontMember($0, name, localizedName)})
        }
    }
    
    /// A member of a font family.
    public struct FontMember: Hashable {
        /// The full name of the font, as used in PostScript language code—for example, “Times-Roman” or “Helvetica-Oblique.”
        public let fontName: String
        
        /// The family name of the font—for example, “Times” or “Helvetica.”
        public let familyName: String
        
        /// The localized family name.
        public let localizedFamilyName: String
        
        /// The face name of the font—for example, “Regular”, "Light" or “Bold”.
        public let faceName: String
        
        /// The localized face name of the font.
        public let localizedFaceName: String
        
        /**
         The approximated weight of the font.
         
         An approximation of the weight of the given font, where `0` indicates the lightest possible weight, `5` indicates a normal or book weight, and `9` or more indicates a bold or heavier weight.
         */
        public let weight: CGFloat
        
        /// The traits of the font.
        public let traits: NSFontDescriptor.SymbolicTraits
        
        /// The font with the specified size.
        public func font(withSize size: CGFloat = NSFont.systemFontSize) -> NSFont? {
            NSFont(name: fontName, size: size)
        }
        
        init?(_ value: [Any], _ familyName: String, _ localizedFamilyName: String) {
            guard let fontName = value[safe: 0] as? String, let faceName = value[safe: 1] as? String, let weight = value[safe: 2] as? CGFloat, let traits = value[safe: 3] as? UInt32 else {
                return nil
            }
            self.fontName = fontName
            self.faceName = faceName
            self.familyName = familyName
            self.localizedFamilyName = localizedFamilyName
            self.traits = .init(rawValue: traits)
            self.weight = weight
            self.localizedFaceName = NSFontManager.shared.localizedName(forFamily: familyName, face: faceName)
        }
    }
}

#endif
