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
        #if os(macOS) || os(iOS) || os(tvOS)
        let dynamic = dynamicColors
        if dynamic.light == dynamic.dark {
            return dynamic.light._tinted(by: amount)
        } else {
            return NSUIColor(light: dynamic.light._tinted(by: amount), dark: dynamic.dark._tinted(by: amount))
        }
        #else
        return _tinted(by: amount)
        #endif
    }
    
    private func _tinted(by amount: CGFloat = 0.2) -> NSUIColor {
        #if os(macOS)
        return blended(withFraction: amount, of: .white) ?? self
        #else
        return blended(withFraction: amount, of: .white)
        #endif
    }

    /**
     Shades the color by the specified amount.
     - Parameter amount: The amount of shade.
     - Returns: The shaded color object.
     */
    func shaded(by amount: CGFloat = 0.2) -> NSUIColor {
        #if os(macOS) || os(iOS) || os(tvOS)
        let dynamic = dynamicColors
        if dynamic.light == dynamic.dark {
            return dynamic.light._shaded(by: amount)
        } else {
            return NSUIColor(light: dynamic.light._shaded(by: amount), dark: dynamic.dark._shaded(by: amount))
        }
        #else
        return _shaded(by: amount)
        #endif
    }
    
    private func _shaded(by amount: CGFloat = 0.2) -> NSUIColor {
        #if os(macOS)
        return blended(withFraction: amount, of: .black) ?? self
        #else
        return blended(withFraction: amount, of: .black)
        #endif
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
            return dynamic.light._lighter(by: amount)
        }
        return NSUIColor(light: dynamic.light._lighter(by: amount), dark: dynamic.dark._lighter(by: amount))
        #else
        return _lighter(by: amount)
        #endif
    }
    
    private func _lighter(by amount: CGFloat = 0.2) -> NSUIColor {
        let hsla = hslaComponents()
        return NSUIColor(hsla.lightness(hsla.lightness + amount))
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
            return dynamic.light._saturated(by: amount)
        }
        return NSUIColor(light: dynamic.light._saturated(by: amount), dark: dynamic.dark._saturated(by: amount))
        #else
        return _saturated(by: amount)
        #endif
    }
    
    private func _saturated(by amount: CGFloat = 0.2) -> NSUIColor {
        let hsla = hslaComponents()
        return NSUIColor(hsla.saturation(hsla.saturation + amount))
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
    final func adjustedHue(by amount: CGFloat) -> NSUIColor {
        #if os(macOS) || os(iOS) || os(tvOS)
        let dynamic = dynamicColors
        guard dynamic.light != dynamic.dark else {
            return dynamic.light._adjustedHue(amount: amount)
        }
        return NSUIColor(light: dynamic.light._adjustedHue(amount: amount), dark: dynamic.dark._adjustedHue(amount: amount))
        #else
        return _adjustedHue(amount: amount)
        #endif
    }
    
    private func _adjustedHue(amount: CGFloat) -> NSUIColor {
        var hsla = hslaComponents()
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
    final func complemented() -> NSUIColor {
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
        if dynamic.light == dynamic.dark {
            return dynamic.light._grayscaled(mode: mode)
        } else {
            return NSUIColor(light: dynamic.light._grayscaled(mode: mode), dark: dynamic.dark._grayscaled(mode: mode))
        }
        #else
        return _grayscaled(mode: mode)
        #endif
    }
    
    private func _grayscaled(mode: GrayscalingMode = .lightness) -> NSUIColor {
        let rgba = rgbaComponents()
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
        return NSUIColor(hue: 0.0, saturation: 0.0, lightness: l, alpha: a)
    }

    /// The mode of grayscaling a color.
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
        #if os(macOS) || os(iOS) || os(tvOS)
        let dynamic = dynamicColors
        guard dynamic.light != dynamic.dark else {
            return dynamic.light._inverted
        }
        return NSUIColor(light: dynamic.light._inverted, dark: dynamic.dark._inverted)
        #else
        return _inverted
        #endif
    }
    
    private var _inverted: NSUIColor {
        var rgba = rgbaComponents()
        rgba.red = 1.0 - rgba.red
        rgba.red = 1.0 - rgba.green
        rgba.red = 1.0 - rgba.blue
        return NSUIColor(rgba)
    }
}
