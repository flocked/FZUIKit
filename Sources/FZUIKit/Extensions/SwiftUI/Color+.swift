//
//  Color+.swift
//
//
//  Created by Florian Zand on 06.10.22.
//

import SwiftUI

#if os(macOS)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

public extension NSUIColor {
    /// A `SwiftUI representation of the color.
    var swiftUI: Color {
        Color(self)
    }
}

#if os(macOS) || os(iOS) || os(tvOS)
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, *)
    extension Color {
        /**
         Creates a color object that uses the specified block to generate its color data dynamically.

         - Parameters:
            - light: The light color.
            - dark: The dark color.
         */
        public init(light lightModeColor: @escaping @autoclosure () -> Color,
             dark darkModeColor: @escaping @autoclosure () -> Color)
        {
            self.init(NSUIColor(
                light: NSUIColor(lightModeColor()),
                dark: NSUIColor(darkModeColor())
            ))
        }

    /// A random color.
    public static func random() -> Color {
        Color(NSUIColor.random())
    }

    /// A random pastel color.
    public static func randomPastel() -> Color {
        Color(NSUIColor.randomPastel())
    }

    /**
     Creates a new color from the current mixed with with the specified color and amount.

     - Parameters:
        - color: The color to mix.
        - amount: The amount of the color to mix with the current color.

     - Returns: The new mixed color.
     */
    public func mixed(with color: Color, by amount: CGFloat = 0.5) -> Color {
        let amount = amount.clamped(to: 0.0...1.0)
        let nsUIColor = NSUIColor(self)
        #if os(macOS)
            return Color(nsUIColor.blended(withFraction: amount, of: NSUIColor(color)) ?? nsUIColor)
        #elseif canImport(UIKit)
            return Color(nsUIColor.blended(withFraction: amount, of: NSUIColor(color)))
        #endif
    }
    
    /**
     Tints the color by the specified amount.
     
     - Parameter amount: The amount of tint.
     - Returns: The tinted color object.
     */
    public func tinted(by amount: CGFloat = 0.2) -> Color {
        return mixed(with: .white, by: amount)
    }
    
    /**
     Shades the color by the specified amount.
     - Parameter amount: The amount of shade.
     - Returns: The shaded color object.
     */
    public func shaded(by amount: CGFloat = 0.2) -> Color {
        return mixed(with: .black, by: amount)
    }

    /**
     Brightens the color by the specified amount.

     - Parameter amount: The amount of brightness.
     - Returns: The brightened color.
     */
    public func lighter(by amount: CGFloat = 0.2) -> Color {
        let amount = amount.clamped(to: 0.0...1.0)
        return brightness(1.0 + amount)
    }

    /**
     Darkens the color by the specified amount.

     - Parameter amount: The amount of darken.
     - Returns: The darkened color.
     */
    public func darkened(by amount: CGFloat = 0.2) -> Color {
        let amount = amount.clamped(to: 0.0...1.0)
        return brightness(1.0 - amount)
    }

    func brightness(_ amount: CGFloat) -> Color {
        var amount = amount
        if amount > 1.0 {
            amount = amount - 1.0
            return mixed(with: .white, by: amount)
        } else if amount < 1.0 {
            amount = amount.clamped(to: 0.0...1.0)
            amount = 1.0 - amount
            return mixed(with: .black, by: amount)
        }
        return self
    }
    
    
    /**
     Saturates the color by the specified amount.
     - Parameter amount: The amount of saturation.
     - Returns: The saturated color object.
     */
    public func saturated(by amount: CGFloat = 0.2) -> Color {
        var hsla = nsUIColor.hslaComponents()
        hsla.saturation = (hsla.saturation + amount).clamped(to: 0.0...1.0)
        return Color(NSUIColor(hue: hsla.hue, saturation: hsla.saturation, lightness: hsla.lightness, alpha: hsla.alpha))
    }
    
    /**
     Desaturates the color by the specified amount.
     - Parameter amount: The amount of desaturation.
     - Returns: The desaturated color object.
     */
    public func desaturated(by amount: CGFloat = 0.2) -> Color {
        saturated(by: amount * -1.0)
    }
    
    #if os(macOS)
    /// A `NSColor` representation of the color.
    public var nsColor: NSColor {
        NSColor(self)
    }
    #else
    /// A `UIColor` representation of the color.
    public var uiColor: UIColor {
        UIColor(self)
    }
    #endif
    
    var nsUIColor: NSUIColor {
        NSUIColor(self)
    }
    
    /// The mode of grayscaling a color.
    public enum GrayscalingMode: String, Hashable {
        /// XYZ luminance
        case luminance = "Luminance"
        /// HSL lightness
        case lightness = "Lightness"
        /// RGB average
        case average = "Average"
        /// HSV value
        case value = "Value"
    }
    
    /**
     A grayscaled representation of the color.
     - Parameter mode: The grayscale mode.
     - Returns: The grayscaled color.
     */
    public func grayscaled(mode: GrayscalingMode = .lightness) -> Color {
        let rgba = nsUIColor.rgbaComponents()
        let (r, g, b, a) = (rgba.red, rgba.green, rgba.blue, rgba.alpha)

        let l: CGFloat
        switch mode {
        case .luminance:
            l = (0.299 * r) + (0.587 * g) + (0.114 * b)
        case .lightness:
            l = 0.5 * (max(r, g, b) + min(r, g, b))
        case .average:
            l = (1.0 / 3.0) * (r + g + b)
        case .value:
            l = max(r, g, b)
        }
        return Color(NSUIColor(hue: 0.0, saturation: 0.0, lightness: l, alpha: a))
    }
    
    /**
     Creates and return a color object where the red, green, and blue values are inverted, while the alpha channel is left alone.

     - returns: An inverse (negative) of the original color.
     */
    public func inverted() -> Color {
        let rgba = nsUIColor.rgbaComponents()

        let invertedRed = 1.0 - rgba.red
        let invertedGreen = 1.0 - rgba.green
        let invertedBlue = 1.0 - rgba.blue

        return Color(NSUIColor(red: invertedRed, green: invertedGreen, blue: invertedBlue, alpha: rgba.alpha))
    }
        
        /**
         A Boolean value that indicates whether the color is light or dark.

         It is useful when you need to know whether you should display the text in black or white.
         */
        var isLight: Bool {
            let components = nsUIColor.rgbaComponents()
            let brightness = ((components.red * 299.0) + (components.green * 587.0) + (components.blue * 114.0)) / 1000.0

            return brightness >= 0.5
        }
}
#endif
