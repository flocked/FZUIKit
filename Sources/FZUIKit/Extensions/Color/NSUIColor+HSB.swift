//
//  NSUIColor+HSB.swift
//
//
//  Created by Florian Zand on 06.10.23.
//

#if canImport(UIKit)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif
import SwiftUI

extension NSUIColor {
    /// Returns the HSBA (hue, saturation, brightness, alpha) components of the color.
    public func hsbaComponents() -> HSBAComponents {
        var h: CGFloat = 0.0
        var s: CGFloat = 0.0
        var b: CGFloat = 0.0

        #if os(iOS) || os(tvOS) || os(watchOS)
            getHue(&h, saturation: &s, brightness: &b, alpha: nil)

            return HSBAComponents(h, s, b, alphaComponent)
        #elseif os(OSX)
            if isEqual(NSUIColor.black) {
                return HSBAComponents(0.0, 0.0, 0.0, 1.0)
            } else if isEqual(NSUIColor.white) {
                return HSBAComponents(0.0, 0.0, 1.0, 1.0)
            }

            guard let color = withSupportedColorSpace() else {
                fatalError("Could not convert color to RGBA.")
            }

            color.getHue(&h, saturation: &s, brightness: &b, alpha: nil)

            return HSBAComponents(h, s, b, alphaComponent)
        #endif
    }

    /// Creates a color using the HSBA components.
    convenience init(_ hsbaComponents: HSBAComponents) {
        self.init(hue: hsbaComponents.hue, saturation: hsbaComponents.saturation, brightness: hsbaComponents.brightness, alpha: hsbaComponents.alpha)
    }

    #if os(iOS) || os(tvOS) || os(watchOS)
        /// The hue component of the color.
        public final var hueComponent: CGFloat {
            hsbaComponents().hue
        }

        /// The saturation component of the color.
        public final var saturationComponent: CGFloat {
            hsbaComponents().saturation
        }

        /// The brightness component of the color.
        public final var brightnessComponent: CGFloat {
            hsbaComponents().brightness
        }
    #endif

    /**
     Returns a new color object with the specified hue value.

     - Parameter hue: The hue value of the new color object, specified as a value from 0.0 to 1.0. Hue values below 0.0 are interpreted as 0.0, and values above 1.0 are interpreted as 1.0.
     - Returns: The new color object.
     */
    func withHue(_ hue: CGFloat) -> NSUIColor {
        let hsba = hsbaComponents()
        return NSUIColor(hue: hue, saturation: hsba.saturation, brightness: hsba.brightness, alpha: hsba.alpha)
    }

    /**
     Returns a new color object with the specified saturation value.

     - Parameter saturation: The saturation value of the new color object, specified as a value from 0.0 to 1.0. Saturation values below 0.0 are interpreted as 0.0, and values above 1.0 are interpreted as 1.0.
     - Returns: The new color object.
     */
    func withSaturation(_ saturation: CGFloat) -> NSUIColor {
        let hsba = hsbaComponents()
        return NSUIColor(hue: hsba.hue, saturation: hsba.saturation, brightness: saturation, alpha: hsba.alpha)
    }

    /**
     Returns a new color object with the specified brightness value.

     - Parameter brightness: The brightness value of the new color object, specified as a value from 0.0 to 1.0. Brightness values below 0.0 are interpreted as 0.0, and values above 1.0 are interpreted as 1.0.
     - Returns: The new color object.
     */
    func withBrightness(_ brightness: CGFloat) -> NSUIColor {
        let hsba = hsbaComponents()
        return NSUIColor(hue: hsba.hue, saturation: hsba.saturation, brightness: brightness, alpha: hsba.alpha)
    }
}

/// The HSBA (hue, saturation, brightness, alpha) components of a color.
public struct HSBAComponents {
    /// The hue component of the color.
    public var hue: CGFloat {
        didSet { hue = hue.clamped(to: 0.0...1.0) }
    }

    /// The saturation component of the color.
    public var saturation: CGFloat {
        didSet { saturation = saturation.clamped(to: 0.0...1.0) }
    }

    /// The brightness component of the color.
    public var brightness: CGFloat {
        didSet { brightness = brightness.clamped(to: 0.0...1.0) }
    }

    /// The alpha value of the color.
    public var alpha: CGFloat {
        didSet { alpha = alpha.clamped(to: 0.0...1.0) }
    }

    /// Creates HSBA components with the specified hue, saturation, brightness and alpha components.
    public init(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        self.hue = hue.clamped(to: 0.0...1.0)
        self.saturation = saturation.clamped(to: 0.0...1.0)
        self.brightness = brightness.clamped(to: 0.0...1.0)
        self.alpha = alpha.clamped(to: 0.0...1.0)
    }

    init(_ hue: CGFloat, _ saturation: CGFloat, _ brightness: CGFloat, _ alpha: CGFloat) {
        self.hue = hue.clamped(to: 0.0...1.0)
        self.saturation = saturation.clamped(to: 0.0...1.0)
        self.brightness = brightness.clamped(to: 0.0...1.0)
        self.alpha = alpha.clamped(to: 0.0...1.0)
    }

    #if os(macOS)
        /// Returns the `NSColor`.
        public func toNSColor() -> NSUIColor {
            NSUIColor(self)
        }
    #else
        /// Returns the `UIColor`.
        public func toUIColor() -> NSUIColor {
            NSUIColor(self)
        }
    #endif

    /// Returns the SwiftUI `Color`.
    public func toColor() -> Color {
        Color(hue: hue, saturation: saturation, brightness: brightness, opacity: alpha)
    }

    /// Returns the `CGColor`.
    public func toCGColor() -> CGColor {
        NSUIColor(self).cgColor
    }
}

public extension Color {
    /// Creates a color using the HSBA components.
    init(_ hsbaComponents: HSBAComponents) {
        self.init(hue: hsbaComponents.hue, saturation: hsbaComponents.saturation, brightness: hsbaComponents.brightness, opacity: hsbaComponents.alpha)
    }
}
