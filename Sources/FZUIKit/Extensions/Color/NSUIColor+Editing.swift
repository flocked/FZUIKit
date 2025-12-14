//
//  NSUIColor+Editing.swift
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
     - Parameter amount: The amount of tint.
     - Returns: The tinted color object.
     */
    func tinted(by amount: CGFloat = 0.2) -> NSUIColor {
        blended(withFraction: amount, of: .white, using: .srgb)
    }

    /**
     Shades the color by the specified amount.
     - Parameter amount: The amount of shade.
     - Returns: The shaded color object.
     */
    func shaded(by amount: CGFloat = 0.2) -> NSUIColor {
        blended(withFraction: amount, of: .black, using: .srgb)
    }

    /**
     Brightens the color by the specified amount.
     - Parameter amount: The amount of brightness.
     - Returns: The brightened color object.
     */
    func lighter(by amount: CGFloat = 0.2) -> NSUIColor {
        #if os(macOS) || os(iOS) || os(tvOS)
        let dynamic = dynamicColors
        guard dynamic.light != dynamic.dark else {
            return NSUIColor(light: dynamic.light._lighter(by: amount), dark: dynamic.dark._lighter(by: amount))
        }
        #endif
        return _lighter(by: amount)
    }
    
    fileprivate func _lighter(by amount: CGFloat) -> NSUIColor {
        var hsla = hsl()
        hsla.lightness += amount
        return NSUIColor(hsla)
    }

    /**
     Darkens the color by the specified amount.
     - Parameter amount: The amount of darken.
     - Returns: The darkened color object.
     */
    func darkened(by amount: CGFloat = 0.2) -> NSUIColor {
        lighter(by: amount * -1.0)
    }

    /**
     Saturates the color by the specified amount.
     - Parameter amount: The amount of saturation.
     - Returns: The saturated color object.
     */
    func saturated(by amount: CGFloat = 0.2) -> NSUIColor {
        #if os(macOS) || os(iOS) || os(tvOS)
        let dynamic = dynamicColors
        guard dynamic.light != dynamic.dark else {
            return NSUIColor(light: dynamic.light._saturated(by: amount), dark: dynamic.dark._saturated(by: amount))
        }
        #endif
        return _saturated(by: amount)
    }
    
    fileprivate func _saturated(by amount: CGFloat) -> NSUIColor {
        var hsla = hsl()
        hsla.saturation += amount
        return NSUIColor(hsla)
    }

    /**
     Desaturates the color by the specified amount.
     - Parameter amount: The amount of desaturation.
     - Returns: The desaturated color object.
     */
    func desaturated(by amount: CGFloat = 0.2) -> NSUIColor {
        saturated(by: amount * -1.0)
    }

    /**
     Creates and returns a color object with the hue rotated along the color wheel by the given amount.

     - Parameter amount: A float representing the number of degrees as ratio (usually between -360.0 degree and 360.0 degree).
     - returns: A DynamicColor object with the hue changed.
     */
    func adjustedHue(by amount: CGFloat) -> NSUIColor {
        #if os(macOS) || os(iOS) || os(tvOS)
        let dynamic = dynamicColors
        guard dynamic.light != dynamic.dark else {
            return NSUIColor(light: dynamic.light._adjustedHue(amount: amount), dark: dynamic.dark._adjustedHue(amount: amount))
        }
        #endif
        return _adjustedHue(amount: amount)
    }
    
    fileprivate func _adjustedHue(amount: CGFloat) -> NSUIColor {
        var hsla = hsl()
        hsla.hue = hsla.hue + amount.clamped(to: 0...360)
        if hsla.hue > 360 {
            hsla.hue = hsla.hue - 360
        }
        return NSUIColor(hsla)
    }

    /**
     Creates and returns the complement of the color object.

     This is identical to adjustedHue(180).

     - returns: The complement DynamicColor.
     */
    func complemented() -> NSUIColor {
        adjustedHue(by: 180.0)
    }

    /**
     A grayscaled representation of the color.
     - Parameter mode: The grayscale mode.
     - Returns: The grayscaled color.
     */
    func grayscaled(mode: GrayscalingMode = .lightness) -> NSUIColor {
        #if os(macOS) || os(iOS) || os(tvOS)
        let dynamic = dynamicColors
        if dynamic.light != dynamic.dark {
            return NSUIColor(light: dynamic.light._grayscaled(mode: mode), dark: dynamic.dark._grayscaled(mode: mode))
        }
        #endif
        return _grayscaled(mode: mode)
    }
    
    fileprivate func _grayscaled(mode: GrayscalingMode) -> NSUIColor {
        let rgba = rgb()
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
        case .default:
            var white: CGFloat = 0.0
            var alpha: CGFloat = 0.0
            #if os(macOS)
            guard let color = usingColorSpace(.deviceGray) else { return grayscaled(mode: .lightness) }
            color.getWhite(&white, alpha: &alpha)
            #else
            getWhite(&white, alpha: &alpha)
            #endif
            return NSUIColor(white: white, alpha: alpha)
        }
        return NSUIColor(.hsl(hue: 0.0, saturation: 0.0, lightness: l, alpha: a))
    }

    /// The mode of grayscaling a color.
    enum GrayscalingMode: String, Hashable {
        /// XYZ luminance
        case luminance
        /// HSL lightness
        case lightness
        /// RGB average
        case average
        /// HSV value
        case value
        case `default`
    }

    /**
     Creates and return a color object where the red, green, and blue values are inverted, while the alpha channel is left alone.

     - returns: An inverse (negative) of the original color.
     */
    func inverted() -> NSUIColor {
        #if os(macOS) || os(iOS) || os(tvOS)
        let dynamic = dynamicColors
        guard dynamic.light != dynamic.dark else {
            return NSUIColor(light: dynamic.light._inverted, dark: dynamic.dark._inverted)
        }
        #endif
        return _inverted
    }
    
    fileprivate var _inverted: NSUIColor {
        var rgba = rgb()
        rgba.red = 1.0 - rgba.red
        rgba.red = 1.0 - rgba.green
        rgba.red = 1.0 - rgba.blue
        return NSUIColor(rgba)
    }
}
