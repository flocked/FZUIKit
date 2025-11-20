//
//  NSFont+FontFamily.swift
//
//
//  Created by Florian Zand on 25.02.24.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif

#if os(macOS)
extension NSFont {
    public static var availableFontFamilyNames: [String] {
        NSFontManager.shared.availableFontFamilies
    }
    
    /// The font families available in the system.
    public static var availableFontFamilies: [FontFamily] {
        availableFontFamilyNames.map({FontFamily($0)})
    }
    
    /// The font members of the font family with the specified name.
    public static func availableFontMembers(ofFontFamily fontFamily: String) -> [FontMember]? {
        NSFontManager.shared.availableMembers(ofFontFamily: fontFamily)?.map({FontMember($0, fontFamily)})
    }
    
    /// The font family.
    public var fontFamily: FontFamily? {
        guard let familyName = familyName, NSFontManager.shared.availableFontFamilies.contains(familyName) else { return nil }
        return FontFamily(familyName)
    }
    
    public var fontMember: FontMember? {
        fontFamily?.members.first(where: {$0.fontName == fontName})
    }
        
    /// Font family.
    public struct FontFamily: Hashable, CustomStringConvertible, CustomDebugStringConvertible {
        
        /// The name of the font family.
        public let name: String
        
        /// The localized name of the font family.
        public var localizedName: String {
            NSFontManager.shared.localizedName(forFamily: name, face: nil)
        }
        
        public var description: String {
            "(\"\(name)\", \(members.map({$0.faceName})))"
        }
        
        public var debugDescription: String {
            "(\"\(name)\", \(members.map({$0.fontName})))"
        }
        
        /// The members of the font family (e.g. `regular`, `light` or `bold`).
        public var members: [FontMember] {
            (NSFontManager.shared.availableMembers(ofFontFamily: name) ?? []).map({FontMember($0, name)})
        }
        
        /// The font with the specified size.
        public func font(withSize size: CGFloat = NSFont.systemFontSize) -> NSFont? {
            NSFont(name: name, size: size)
        }
        
        init(_ name: String) {
            self.name = name
        }
    }
    
    /// A member of a font family.
    public struct FontMember: Hashable, CustomStringConvertible, CustomDebugStringConvertible {
        /// The full name of the font, as used in PostScript language code—for example, “Times-Roman” or “Helvetica-Oblique.”
        public let fontName: String
        
        /// The family name of the font—for example, “Times” or “Helvetica.”
        public let familyName: String
        
        /// The face name of the font—for example, “Regular”, "Light" or “Bold”.
        public let faceName: String
        
        public var description: String {
            "\(fontName)"
        }
        
        public var debugDescription: String {
            "(\(fontName), face: \(faceName)"
        }
        
        /// The localized face name of the font.
        public var localizedFaceName: String {
            NSFontManager.shared.localizedName(forFamily: familyName, face: faceName)
        }
        
        /**
         The approximated weight of the font.
         
         An approximation of the weight of the given font, where `0` indicates the lightest possible weight, `5` indicates a regular weight, and `9` or more indicates a bold or heavier weight.
         */
        public let weight: CGFloat
        
        /// The traits of the font.
        public let traits: NSFontDescriptor.SymbolicTraits
        
        /// The font with the specified size.
        public func font(withSize size: CGFloat = 0.0) -> NSFont? {
            NSFont(name: fontName, size: size)
        }
        
        init(_ value: [Any], _ familyName: String) {
            self.fontName = value[0] as! String
            self.faceName = value[1] as! String
            self.familyName = familyName
            self.traits = .init(rawValue: value[3] as! UInt32)
            self.weight = value[2] as! CGFloat
        }
    }
}
#else
extension UIFont {
    static func sdsd() {
        
    }
}
#endif

extension NSUIFont {
    /// The face name of the font.
    public var faceName: String? {
        fontDescriptor.faceName
    }
}
