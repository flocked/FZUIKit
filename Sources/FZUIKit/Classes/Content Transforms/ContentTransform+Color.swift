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

/**
 A transformer that generates a modified output color from an input color.
 */
public struct ColorTransformer: ContentTransform {
    /// The transform closure of the color transformer.
    public let transform: (NSUIColor) -> NSUIColor
    /// The identifier of the transformer.
    public let id: String

    /// Creates a color transformer with the specified identifier and closure.
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

    /// Creates a color transformer that generates a version of the color.with modified opacity.
    public static func opacity(_ opacity: CGFloat) -> Self {
        Self("opacity: \(opacity)") { $0.withAlphaComponent(opacity.clamped(to: 0.0...1.0)) }
    }

    /// Creates a color transformer that generates a version of the color.that is tinted by the amount.
    public static func tinted(by amount: CGFloat = 0.2) -> Self {
        Self("tinted: \(amount)") { $0.tinted(by: amount) }
    }

    /// Creates a color transformer that generates a version of the color.that is shaded by the amount.
    public static func shaded(by amount: CGFloat = 0.2) -> Self {
        Self("shaded: \(amount)") { $0.shaded(by: amount) }
    }

    /// Creates a color transformer that generates a version of the color.that is lightened by the amount.
    public static func lighter(by amount: CGFloat = 0.2) -> Self {
        Self("lighter: \(amount)") { $0.lighter(by: amount) }
    }

    /// Creates a color transformer that generates a version of the color.that is darkened by the amount.
    public static func darkened(by amount: CGFloat = 0.2) -> Self {
        Self("darkened: \(amount)") { $0.darkened(by: amount) }
    }

    /// Creates a color transformer that generates a version of the color.that is saturated by the amount.
    public static func saturated(by amount: CGFloat = 0.2) -> Self {
        Self("lighter: \(amount)") { $0.saturated(by: amount) }
    }

    /// Creates a color transformer that generates a version of the color.that is desaturated by the amount.
    public static func desaturated(by amount: CGFloat = 0.2) -> Self {
        Self("darkened: \(amount)") { $0.desaturated(by: amount) }
    }

    public static func color(_ color: NSUIColor) -> Self {
        Self("color: \(String(describing: color))") { _ in color }
    }

    #if os(macOS)
        /// Creates a color transformer that generates a monochrome version of the color.
        public static let monochrome: Self = .init("monochrome") { _ in .secondaryLabelColor }

        /// A color transformer that returns the preferred system accent color.
        public static let preferredTint: Self = .init("preferredTint") { _ in
            .controlAccentColor
        }

        /// Creates a color transformer that generates a grayscale version of the color.
        public static func grayscaled(mode: NSUIColor.GrayscalingMode = .lightness) -> Self {
            Self("grayscaled: \(mode.rawValue)") { $0.grayscaled(mode: mode) }
        }

        /// A color transformer that returns a color by system effect.
        public static func systemEffect(_ systemEffect: NSColor.SystemEffect) -> Self {
            Self("systemEffect: \(systemEffect.rawValue)") { $0.withSystemEffect(systemEffect) }
        }

    #elseif os(iOS) || os(tvOS)
        public static var preferredTint: Self {
            Self("preferredTint", UIConfigurationColorTransformer.preferredTint.transform)
        }

        public static var monochromeTint: Self {
            Self("monochromeTint", UIConfigurationColorTransformer.monochromeTint.transform)
        }

        public static var grayscale: Self {
            Self("grayscale", UIConfigurationColorTransformer.grayscale.transform)
        }
    #endif
}
