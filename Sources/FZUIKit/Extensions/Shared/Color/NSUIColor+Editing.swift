//
//  NSUIColor+Brightness.swift
//
//
//  Created by Florian Zand on 06.10.22.
//

import FZSwiftUtils

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public extension NSUIColor {
    /**
     Tints the color by the specified amount.
     - Parameters amount: The amount of tint.
     - Returns: The tinted color object.
     */
    func tinted(by amount: CGFloat = 0.2) -> NSUIColor {
        #if os(macOS)
        return blended(withFraction: amount, of: .white) ?? self
        #else
        return blended(withFraction: amount, of: .white)
        #endif
    }

    /**
     Shades the color by the specified amount.
     - Parameters amount: The amount of shade.
     - Returns: The shaded color object.
     */
    func shaded(by amount: CGFloat = 0.2) -> NSUIColor {
        #if os(macOS)
        return blended(withFraction: amount, of: .black) ?? self
        #else
        return blended(withFraction: amount, of: .black)
        #endif
    }

    /**
     Brightens the color by the specified amount.
     - Parameters amount: The amount of brightness.
     - Returns: The brightened color object.
     */
    func lighter(by amount: CGFloat = 0.2) -> NSUIColor {
        return HSL(color: self).lighter(amount: amount).toColor()
    }

    /**
     Darkens the color by the specified amount.
     - Parameters amount: The amount of darken.
     - Returns: The darkened color object.
     */
    func darkened(by amount: CGFloat = 0.2) -> NSUIColor {
        return HSL(color: self).darkened(amount: amount).toColor()
    }

    /**
     Saturates the color by the specified amount.
     - Parameters amount: The amount of saturation.
     - Returns: The saturated color object.
     */
    func saturated(by amount: CGFloat = 0.2) -> NSUIColor {
        return HSL(color: self).saturated(amount: amount).toColor()
    }

    /**
     Desaturates the color by the specified amount.
     - Parameters amount: The amount of desaturation.
     - Returns: The desaturated color object.
     */
    func desaturated(by amount: CGFloat = 0.2) -> NSUIColor {
        return HSL(color: self).desaturated(amount: amount).toColor()
    }
    
    /**
     Creates and returns a color object with the hue rotated along the color wheel by the given amount.

     - parameter amount: A float representing the number of degrees as ratio (usually between -360.0 degree and 360.0 degree).
     - returns: A DynamicColor object with the hue changed.
     */
    final func adjustedHue(amount: CGFloat) -> NSUIColor {
      return HSL(color: self).adjustedHue(amount: amount).toColor()
    }

    /**
     Creates and returns the complement of the color object.

     This is identical to adjustedHue(180).

     - returns: The complement DynamicColor.
     - seealso: adjustedHueColor:
     */
    final func complemented() -> NSUIColor {
      return adjustedHue(amount: 180.0)
    }


    /**
     A grayscaled representation of the color.
     - Parameters mode: The grayscale mode.
     - Returns: The grayscaled color.
     */
    func grayscaled(mode: GrayscalingMode = .lightness) -> NSUIColor {
        let (r, g, b, a) = rgbaComponents()

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

        return HSL(hue: 0.0, saturation: 0.0, lightness: l, alpha: a).toColor()
    }

    enum GrayscalingMode: String, Hashable {
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
     Creates and return a color object where the red, green, and blue values are inverted, while the alpha channel is left alone.

     - returns: An inverse (negative) of the original color.
     */
    final func inverted() -> NSUIColor {
      let rgba = rgbaComponents()

      let invertedRed   = 1.0 - rgba.red
      let invertedGreen = 1.0 - rgba.green
      let invertedBlue  = 1.0 - rgba.blue

      return NSUIColor(red: invertedRed, green: invertedGreen, blue: invertedBlue, alpha: rgba.alpha)
    }
}
