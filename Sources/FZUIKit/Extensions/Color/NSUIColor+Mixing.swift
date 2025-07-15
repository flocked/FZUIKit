//
//  NSUIColor+Mixing.swift
//
//
//  Created by Florian Zand on 06.10.23.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif
import FZSwiftUtils

public extension NSUIColor {
    /**
     Creates a new color mixing the color with the specified other color.

     - Parameters:
        - fraction: The amount of the color to blend.
        - color: The color to blend.
        - colorSpace: The color space mode to be used for mixing the two colors.

     - Returns: The mixed color.
     */
    func mixed(withFraction fraction: CGFloat, of color: NSUIColor, using colorSpace: MixingColorSpace = .rgb) -> NSUIColor {
        let fraction = fraction.clamped(to: 0.0...1.0)
        #if os(macOS) || os(iOS) || os(tvOS)
        let dynamic = dynamicColors
        if dynamic.light != dynamic.dark {
            switch colorSpace {
            case .hsl: return NSUIColor(light: dynamic.light.mixedHSL(withColor: color, weight: fraction), dark: dynamic.dark.mixedHSL(withColor: color, weight: fraction))
            case .hsb: return NSUIColor(light: dynamic.light.mixedHSB(withColor: color, weight: fraction), dark: dynamic.dark.mixedHSB(withColor: color, weight: fraction))
            case .rgb: return NSUIColor(light: dynamic.light.mixedRGB(withColor: color, weight: fraction), dark: dynamic.dark.mixedRGB(withColor: color, weight: fraction))
            }
        }
        #endif
        switch colorSpace {
        case .hsl: return mixedHSL(withColor: color, weight: fraction)
        case .hsb: return mixedHSB(withColor: color, weight: fraction)
        case .rgb: return mixedRGB(withColor: color, weight: fraction)
        }
    }

    /// The color for mixing two colors.
    enum MixingColorSpace: String, Hashable {
        /// RGB color space.
        case rgb
        /// HSL color space.
        case hsl
        /// HSB color space.
        case hsb
    }

    fileprivate func mixedHSL(withColor color: NSUIColor, weight: CGFloat) -> NSUIColor {
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

    fileprivate func mixedHSB(withColor color: NSUIColor, weight: CGFloat) -> NSUIColor {
        let c1 = hsbaComponents()
        let c2 = color.hsbaComponents()

        let h = c1.hue + (weight * Self.mixedHue(source: c1.hue, target: c2.hue))
        let s = c1.saturation + (weight * (c2.saturation - c1.saturation))
        let b = c1.brightness + (weight * (c2.brightness - c1.brightness))
        let alpha = alphaComponent + (weight * (color.alphaComponent - alphaComponent))

        return NSUIColor(hue: h, saturation: s, brightness: b, alpha: alpha)
    }

    fileprivate func mixedRGB(withColor color: NSUIColor, weight: CGFloat) -> NSUIColor {
        NSUIColor(rgbaComponents().blended(withFraction: weight, of: color.rgbaComponents()))
    }

    fileprivate static func mixedHue(source: CGFloat, target: CGFloat) -> CGFloat {
        if target > source, target - source > 180.0 {
            return target - source + 360.0
        } else if target < source, source - target > 180.0 {
            return target + 360.0 - source
        }
        return target - source
    }
}
