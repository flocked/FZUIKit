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
        #if os(macOS) || os(iOS) || os(tvOS)
        let dynamic = dynamicColors
        if dynamic.isDynamic {
            return NSUIColor(light: dynamic.light.cgColor.tinted(by: amount).nsUIColor!, dark: dynamic.dark.cgColor.tinted(by: amount).nsUIColor!)
        }
        #endif
        return cgColor.tinted(by: amount).nsUIColor!
    }
    
    /**
     Shades the color by the specified amount.
     - Parameter amount: The amount of shade.
     - Returns: The shaded color object.
     */
    func shaded(by amount: CGFloat = 0.2) -> NSUIColor {
        #if os(macOS) || os(iOS) || os(tvOS)
        let dynamic = dynamicColors
        if dynamic.isDynamic {
            return NSUIColor(light: dynamic.light.cgColor.shaded(by: amount).nsUIColor!, dark: dynamic.dark.cgColor.shaded(by: amount).nsUIColor!)
        }
        #endif
        return cgColor.shaded(by: amount).nsUIColor!
    }
    
    /**
     Brightens the color by the specified amount.
     - Parameter amount: The amount of brightness.
     - Returns: The brightened color object.
     */
    func lighter(by amount: CGFloat = 0.2) -> NSUIColor {
        #if os(macOS) || os(iOS) || os(tvOS)
        let dynamic = dynamicColors
        if dynamic.isDynamic {
            return NSUIColor(light: dynamic.light.cgColor.lighter(by: amount).nsUIColor!, dark: dynamic.dark.cgColor.lighter(by: amount).nsUIColor!)
        }
        #endif
        return cgColor.lighter(by: amount).nsUIColor!
    }
    
    /**
     Darkens the color by the specified amount.
     - Parameter amount: The amount of darken.
     - Returns: The darkened color object.
     */
    func darkened(by amount: CGFloat = 0.2) -> NSUIColor {
        #if os(macOS) || os(iOS) || os(tvOS)
        let dynamic = dynamicColors
        if dynamic.isDynamic {
            return NSUIColor(light: dynamic.light.cgColor.darkened(by: amount).nsUIColor!, dark: dynamic.dark.cgColor.darkened(by: amount).nsUIColor!)
        }
        #endif
        return cgColor.darkened(by: amount).nsUIColor!
    }
    
    /**
     Saturates the color by the specified amount.
     - Parameter amount: The amount of saturation.
     - Returns: The saturated color object.
     */
    func saturated(by amount: CGFloat = 0.2) -> NSUIColor {
        #if os(macOS) || os(iOS) || os(tvOS)
        let dynamic = dynamicColors
        if dynamic.isDynamic {
            return NSUIColor(light: dynamic.light.cgColor.saturated(by: amount).nsUIColor!, dark: dynamic.dark.cgColor.saturated(by: amount).nsUIColor!)
        }
        #endif
        return cgColor.saturated(by: amount).nsUIColor!
    }
    
    /**
     Desaturates the color by the specified amount.
     - Parameter amount: The amount of desaturation.
     - Returns: The desaturated color object.
     */
    func desaturated(by amount: CGFloat = 0.2) -> NSUIColor {
        #if os(macOS) || os(iOS) || os(tvOS)
        let dynamic = dynamicColors
        if dynamic.isDynamic {
            return NSUIColor(light: dynamic.light.cgColor.desaturated(by: amount).nsUIColor!, dark: dynamic.dark.cgColor.desaturated(by: amount).nsUIColor!)
        }
        #endif
        return cgColor.desaturated(by: amount).nsUIColor!
    }
    
    /**
     Creates and returns a color object with the hue rotated along the color wheel by the given amount.
     
     - Parameter amount: A float representing the number of degrees as ratio (usually between -1.0 degree and 360.0 degree).
     - returns: A DynamicColor object with the hue changed.
     */
    func adjustedHue(by amount: CGFloat) -> NSUIColor {
        #if os(macOS) || os(iOS) || os(tvOS)
        let dynamic = dynamicColors
        if dynamic.isDynamic {
            return NSUIColor(light: dynamic.light.cgColor.adjustedHue(by: amount).nsUIColor!, dark: dynamic.dark.cgColor.adjustedHue(by: amount).nsUIColor!)
        }
        #endif
        return cgColor.adjustedHue(by: amount).nsUIColor!
    }
    
    /**
     Creates and returns the complement of the color object.
     
     This is identical to adjustedHue(180).
     
     - returns: The complement DynamicColor.
     */
    func complemented() -> NSUIColor {
        cgColor.complemented().nsUIColor!
    }
    
    /**
     A grayscaled representation of the color.
     - Parameter mode: The grayscale mode.
     - Returns: The grayscaled color.
     */
    func grayscaled(mode: ColorModels.GrayscalingMode = .lightness) -> NSUIColor {
        cgColor.grayscaled(mode: mode).nsUIColor!
    }
    
    /**
     Creates and return a color object where the red, green, and blue values are inverted, while the alpha channel is left alone.
     
     - returns: An inverse (negative) of the original color.
     */
    func inverted() -> NSUIColor {
        cgColor.inverted().nsUIColor!
    }
}

public extension CGColor {
    /**
     Tints the color by the specified amount.
     - Parameter amount: The amount of tint.
     - Returns: The tinted color object.
     */
    func tinted(by amount: CGFloat = 0.2) -> CGColor {
        var oklch = oklch()
        oklch.lightness.interpolate(to: 1.0, fraction: amount)
        oklch.chroma.interpolate(to: 0.0, fraction: amount)
        return oklch.cgColor
    }
    
    /**
     Shades the color by the specified amount.
     - Parameter amount: The amount of shade.
     - Returns: The shaded color object.
     */
    func shaded(by amount: CGFloat = 0.2) -> CGColor {
        var oklch = oklch()
        oklch.lightness.interpolate(to: 0.0, fraction: amount)
        oklch.chroma.interpolate(to: 0.0, fraction: amount)
        return oklch.cgColor
    }
    
    /**
     Brightens the color by the specified amount.
     - Parameter amount: The amount of brightness.
     - Returns: The brightened color object.
     */
    func lighter(by amount: CGFloat = 0.2) -> CGColor {
        var oklch = oklch()
        oklch.lightness.interpolate(to: 1.0, fraction: amount)
        return oklch.cgColor
    }
    
    /**
     Darkens the color by the specified amount.
     - Parameter amount: The amount of darken.
     - Returns: The darkened color object.
     */
    func darkened(by amount: CGFloat = 0.2) -> CGColor {
        var oklch = oklch()
        oklch.lightness.interpolate(to: 0.0, fraction: amount)
        return oklch.cgColor
    }
    
    /**
     Saturates the color by the specified amount.
     - Parameter amount: The amount of saturation.
     - Returns: The saturated color object.
     */
    func saturated(by amount: CGFloat = 0.2) -> CGColor {
        var hsl = hsl()
        hsl.saturation += amount
        return hsl.cgColor
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
        var hsl = hsl()
        hsl.hue = (hsl.hue + amount).truncatingRemainder(dividingBy: 1.0)
        if hsl.hue < 0 { hsl.hue += 1 }
        return hsl.cgColor
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
    func grayscaled(mode: ColorModels.GrayscalingMode = .lightness) -> CGColor {
        rgb().gray(mode: mode).cgColor
        
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
        mix(with: .white, by: amount, in: .srgb)
    }
    
    /**
     Shades the color by the specified amount.
     - Parameter amount: The amount of shade.
     - Returns: The shaded color object.
     */
    func shaded(by amount: CGFloat = 0.2) -> Color {
        mix(with: .black, by: amount, in: .srgb)
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
    func grayscaled(mode: ColorModels.GrayscalingMode = .lightness) -> Color {
        Color(nsUIColor.grayscaled(mode: mode))
        
    }
    
    /**
     Creates and return a color object where the red, green, and blue values are inverted, while the alpha channel is left alone.
     
     - returns: An inverse (negative) of the original color.
     */
    func inverted() -> Color {
        Color(nsUIColor.inverted())
    }
}
