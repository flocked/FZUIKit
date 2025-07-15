//
//  ContentTransform+Color.swift
//
//
//  Created by Florian Zand on 31.03.23.
//

#if os(macOS)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

/// A transformer that generates a modified output color from an input color.
public struct ColorTransformer: ContentTransform {
    /// The block that transforms a color.
    public let transform: (NSUIColor) -> NSUIColor
    /// The identifier of the transformer.
    public let id: String

    /// Creates a color transformer with the specified identifier and block that transforms a color.
    public init(_ identifier: String, _ transform: @escaping (NSUIColor) -> NSUIColor) {
        self.transform = {
            #if os(macOS) || os(iOS)
                let dynamicColors = $0.dynamicColors
                if dynamicColors.light != dynamicColors.dark {
                    return NSUIColor(light: transform(dynamicColors.light), dark: transform(dynamicColors.dark))
                }
            #endif
            return transform($0)
        }
        id = identifier
    }
    
    private init(id: String, _ transform: @escaping (NSUIColor) -> NSUIColor) {
        self.transform = transform
        self.id = id
    }

    /// Creates a color transformer that generates a version of the color.with modified opacity.
    public static func opacity(_ opacity: CGFloat) -> Self {
        Self("opacity: \(opacity)") { $0.withAlpha(opacity) }
    }
    
    /// Creates a color transformer that generates a version of the color.mixed with fractions of the specificed color.
    public static func mixed(withFraction fraction: CGFloat, of color: NSUIColor, using mode: NSUIColor.ColorBlendMode = .rgb) -> Self {
        Self(id: "mixed(withFraction: \(fraction), of: \(color), using: \(mode.rawValue))") { $0.mixed(withFraction: fraction, of: color, using: mode) }
    }

    /// Creates a color transformer that generates a tinted version of the color.
    public static func tinted(by amount: CGFloat = 0.2) -> Self {
        Self(id: "tinted: \(amount)") { $0.tinted(by: amount) }
    }

    /// Creates a color transformer that generates a shaded version of the color.
    public static func shaded(by amount: CGFloat = 0.2) -> Self {
        Self(id: "shaded: \(amount)") { $0.shaded(by: amount) }
    }

    /// Creates a color transformer that generates a lightned version of the color.
    public static func lighter(by amount: CGFloat = 0.2) -> Self {
        Self(id: "lighter: \(amount)") { $0.lighter(by: amount) }
    }

    /// Creates a color transformer that generates a darkened version of the color.
    public static func darkened(by amount: CGFloat = 0.2) -> Self {
        Self(id: "darkened: \(amount)") { $0.darkened(by: amount) }
    }

    /// Creates a color transformer that generates a saturated version of the color.
    public static func saturated(by amount: CGFloat = 0.2) -> Self {
        Self(id: "saturated: \(amount)") { $0.saturated(by: amount) }
    }

    /// Creates a color transformer that generates a desaturated version of the color.
    public static func desaturated(by amount: CGFloat = 0.2) -> Self {
        Self(id: "desaturated: \(amount)") { $0.desaturated(by: amount) }
    }

    /// Creates a color transformer that returns the specified color.
    public static func color(_ color: NSUIColor) -> Self {
        Self(id: "color: \(String(describing: color))") { _ in color }
    }
    
    /// Creates a color transformer that generates a complemented version of the color.
    public static func complemented() -> Self {
        Self(id: "complemented") { $0.complemented() }
    }

    #if os(macOS)
    /// Creates a color transformer that generates a monochrome version of the color.
    public static let monochrome = Self("monochrome") { _ in .secondaryLabelColor }

    /// A color transformer that returns the preferred system accent color.
    public static let accentColor = Self("accentColor") { _ in .controlAccentColor }

    /// Creates a color transformer that generates a grayscale version of the color.
    public static func grayscaled(mode: NSUIColor.GrayscalingMode = .lightness) -> Self {
        Self("grayscaled: \(mode.rawValue)") { $0.grayscaled(mode: mode) }
    }

    /// A color transformer that returns the color by a system effect.
    public static func systemEffect(_ systemEffect: NSColor.SystemEffect) -> Self {
        Self("systemEffect: \(systemEffect.description)") { $0.withSystemEffect(systemEffect) }
    }
    
    /// A color transformer that generates a highlighted version of the color.
    public static func highlight(_ amount: CGFloat = 0.2) -> Self {
        Self("highlight: \(amount)") { $0.highlight(withLevel: amount) ?? $0 }
    }

    #elseif os(iOS) || os(tvOS)
    /// A color transformer that returns the preferred system accent color.
    public static let preferredTint = Self(id: "preferredTint", UIConfigurationColorTransformer.preferredTint.transform)
    
    /// A color transformer that returns the color with a monochrome tint.
    public static let monochromeTint = Self(id: "monochromeTint", UIConfigurationColorTransformer.monochromeTint.transform)
    
    /// Creates a color transformer that generates a grayscale version of the color.
    public static let grayscale = Self(id: "grayscale", UIConfigurationColorTransformer.grayscale.transform)
    #endif
}
