//
//  NSUIColor+Mixing.swift
//
//
//  Created by Florian Zand on 06.10.23.
//

import Foundation

#if canImport(UIKit)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif
import FZSwiftUtils

public extension NSUIColor {
    /**
     Creates a new color object whose component values are a weighted sum of the current color object and the specified color object's.

     - Parameters:
        - fraction: The amount of the color to blend with the receiver's color. The method converts color and a copy of the receiver to RGB, and then sets each component of the returned color to fraction of color’s value plus 1 – fraction of the receiver’s.
        - color: The color to blend with the receiver's color.
        - mode: The color space mode used mixing the colors. The default uses the RBG color space.

     - Returns: The resulting color object or `nil` if the colors can’t be converted.
     */
    func mixed(withFraction fraction: CGFloat, of color: NSUIColor, using mode: ColorBlendMode = .rgb) -> NSUIColor {
        let fraction = fraction.clamped(max: 1.0)

        switch mode {
        case .hsl:
            return mixedHSL(withColor: color, weight: fraction)
        case .hsb:
            return mixedHSB(withColor: color, weight: fraction)
        case .rgb:
            return mixedRGB(withColor: color, weight: fraction)
        }
    }

    enum ColorBlendMode {
        /// The RGB color space.
        case rgb
        /// The HSL color space.
        case hsl
        /// The HSB color space.
        case hsb
    }

    internal func mixedHSL(withColor color: NSUIColor, weight: CGFloat) -> NSUIColor {
        let c1 = hslaComponents()
        let c2 = color.hslaComponents()

        var h = c1.hue + (weight * Self.mixedHue(source: c1.hue, target: c2.hue))
        if h > 360 {
            h = h - 360
        }

        let s = c1.saturation + (weight * (c2.saturation - c1.saturation))
        let l = c1.lightness + (weight * (c2.lightness - c1.lightness))
        let alpha = alphaComponent + (weight * (color.alphaComponent - alphaComponent))

        return NSUIColor(hue: h, saturation: s, lightness: l, alpha: alpha)
    }

    internal func mixedHSB(withColor color: NSUIColor, weight: CGFloat) -> NSUIColor {
        let c1 = hsbaComponents()
        let c2 = color.hsbaComponents()

        let h = c1.hue + (weight * Self.mixedHue(source: c1.hue, target: c2.hue))
        let s = c1.saturation + (weight * (c2.saturation - c1.saturation))
        let b = c1.brightness + (weight * (c2.brightness - c1.brightness))
        let alpha = alphaComponent + (weight * (color.alphaComponent - alphaComponent))

        return NSUIColor(hue: h, saturation: s, brightness: b, alpha: alpha)
    }

    internal func mixedRGB(withColor color: NSUIColor, weight: CGFloat) -> NSUIColor {
        let c1 = rgbaComponents()
        let c2 = color.rgbaComponents()

        let red = c1.red + (weight * (c2.red - c1.red))
        let green = c1.green + (weight * (c2.green - c1.green))
        let blue = c1.blue + (weight * (c2.blue - c1.blue))
        let alpha = alphaComponent + (weight * (color.alphaComponent - alphaComponent))

        return NSUIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    internal static func mixedHue(source: CGFloat, target: CGFloat) -> CGFloat {
        if target > source, target - source > 180.0 {
            return target - source + 360.0
        } else if target < source, source - target > 180.0 {
            return target + 360.0 - source
        }

        return target - source
    }
}
