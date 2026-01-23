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
import SwiftUI

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
        guard !dynamic.isDynamic else {
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
        guard !dynamic.isDynamic else {
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
        guard !dynamic.isDynamic else {
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
        guard !dynamic.isDynamic else {
            return NSUIColor(light: dynamic.light._grayscaled(mode: mode), dark: dynamic.dark._grayscaled(mode: mode))
        }
        #endif
        return _grayscaled(mode: mode)
    }
    
    fileprivate func _grayscaled(mode: GrayscalingMode) -> NSUIColor {
        NSUIColor(rgb().gray(mode: .init(rawValue: mode.rawValue)!))

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
    }

    /**
     Creates and return a color object where the red, green, and blue values are inverted, while the alpha channel is left alone.

     - returns: An inverse (negative) of the original color.
     */
    func inverted() -> NSUIColor {
        #if os(macOS) || os(iOS) || os(tvOS)
        let dynamic = dynamicColors
        guard !dynamic.isDynamic else {
            return NSUIColor(light: NSUIColor(dynamic.light.rgb().inverted), dark: NSUIColor(dynamic.dark.rgb().inverted))
        }
        #endif
        return NSUIColor(rgb().inverted)
    }
}

public extension CGColor {
    /**
     Tints the color by the specified amount.
     - Parameter amount: The amount of tint.
     - Returns: The tinted color object.
     */
    func tinted(by amount: CGFloat = 0.2) -> CGColor {
        blended(withFraction: amount, of: .white, using: .srgb)
    }

    /**
     Shades the color by the specified amount.
     - Parameter amount: The amount of shade.
     - Returns: The shaded color object.
     */
    func shaded(by amount: CGFloat = 0.2) -> CGColor {
        blended(withFraction: amount, of: .black, using: .srgb)
    }
    
    /**
     Brightens the color by the specified amount.
     - Parameter amount: The amount of brightness.
     - Returns: The brightened color object.
     */
    func lighter(by amount: CGFloat = 0.2) -> CGColor {
        var hsla = hsl()
        hsla.lightness += amount
        return CGColor(hsla)
    }
    
    /**
     Darkens the color by the specified amount.
     - Parameter amount: The amount of darken.
     - Returns: The darkened color object.
     */
    func darkened(by amount: CGFloat = 0.2) -> CGColor {
        lighter(by: amount * -1.0)
    }
    
    /**
     Saturates the color by the specified amount.
     - Parameter amount: The amount of saturation.
     - Returns: The saturated color object.
     */
    func saturated(by amount: CGFloat = 0.2) -> CGColor {
        var hsla = hsl()
        hsla.saturation += amount
        return CGColor(hsla)
    }

    /**
     Desaturates the color by the specified amount.
     - Parameter amount: The amount of desaturation.
     - Returns: The desaturated color object.
     */
    func desaturated(by amount: CGFloat = 0.2) -> CGColor {
        saturated(by: amount * -1.0)
    }
    
    /**
     Creates and returns a color object with the hue rotated along the color wheel by the given amount.

     - Parameter amount: A float representing the number of degrees as ratio (usually between -360.0 degree and 360.0 degree).
     - returns: A DynamicColor object with the hue changed.
     */
    func adjustedHue(by amount: CGFloat) -> CGColor {
        var hsla = hsl()
        hsla.hue = hsla.hue + amount.clamped(to: 0...360)
        if hsla.hue > 360 {
            hsla.hue = hsla.hue - 360
        }
        return CGColor(hsla)
    }

    /**
     Creates and returns the complement of the color object.

     This is identical to adjustedHue(180).

     - returns: The complement DynamicColor.
     */
    func complemented() -> CGColor {
        adjustedHue(by: 180.0)
    }

    /**
     A grayscaled representation of the color.
     - Parameter mode: The grayscale mode.
     - Returns: The grayscaled color.
     */
    func grayscaled(mode: GrayscalingMode = .lightness) -> CGColor {
        CGColor(rgb().gray(mode: .init(rawValue: mode.rawValue)!))

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
    }

    /**
     Creates and return a color object where the red, green, and blue values are inverted, while the alpha channel is left alone.

     - returns: An inverse (negative) of the original color.
     */
    func inverted() -> CGColor {
        CGColor(rgb().inverted)
    }
}

public extension Color {
    /**
     Tints the color by the specified amount.
     - Parameter amount: The amount of tint.
     - Returns: The tinted color object.
     */
    func tinted(by amount: CGFloat = 0.2) -> Color {
        blended(withFraction: amount, of: .white, using: .srgb)
    }

    /**
     Shades the color by the specified amount.
     - Parameter amount: The amount of shade.
     - Returns: The shaded color object.
     */
    func shaded(by amount: CGFloat = 0.2) -> Color {
        blended(withFraction: amount, of: .black, using: .srgb)
    }

    /**
     Brightens the color by the specified amount.
     - Parameter amount: The amount of brightness.
     - Returns: The brightened color object.
     */
    func lighter(by amount: CGFloat = 0.2) -> Color {
        Color(nsUIColor.lighter(by: amount))

    }

    /**
     Darkens the color by the specified amount.
     - Parameter amount: The amount of darken.
     - Returns: The darkened color object.
     */
    func darkened(by amount: CGFloat = 0.2) -> Color {
        Color(nsUIColor.darkened(by: amount))
    }

    /**
     Saturates the color by the specified amount.
     - Parameter amount: The amount of saturation.
     - Returns: The saturated color object.
     */
    func saturated(by amount: CGFloat = 0.2) -> Color {
        Color(nsUIColor.saturated(by: amount))
    }

    /**
     Desaturates the color by the specified amount.
     - Parameter amount: The amount of desaturation.
     - Returns: The desaturated color object.
     */
    func desaturated(by amount: CGFloat = 0.2) -> Color {
        Color(nsUIColor.desaturated(by: amount))
    }

    /**
     Creates and returns a color object with the hue rotated along the color wheel by the given amount.

     - Parameter amount: A float representing the number of degrees as ratio (usually between -360.0 degree and 360.0 degree).
     - returns: A DynamicColor object with the hue changed.
     */
    func adjustedHue(by amount: CGFloat) -> Color {
        Color(nsUIColor.adjustedHue(by: amount))
    }
    
    /**
     Creates and returns the complement of the color object.

     This is identical to adjustedHue(180).

     - returns: The complement DynamicColor.
     */
    func complemented() -> Color {
        Color(nsUIColor.complemented())
    }

    /**
     A grayscaled representation of the color.
     - Parameter mode: The grayscale mode.
     - Returns: The grayscaled color.
     */
    func grayscaled(mode: GrayscalingMode = .lightness) -> Color {
        Color(nsUIColor.grayscaled(mode: .init(rawValue: mode.rawValue)!))

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
    }

    /**
     Creates and return a color object where the red, green, and blue values are inverted, while the alpha channel is left alone.

     - returns: An inverse (negative) of the original color.
     */
    func inverted() -> Color {
        Color(nsUIColor.inverted())
    }
}
