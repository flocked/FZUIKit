//
//  NSUIColor+.swift
//
//
//  Created by Florian Zand on 20.09.22.
//

import FZSwiftUtils

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public extension NSUIColor {
    /// Returns the RGBA components of the color.
    func rgbaComponents() -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        var color: NSUIColor? = self
        #if os(macOS)
        color = self.withSupportedColorSpace() ?? self
        #endif
        color?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue, alpha)
    }

    /// Returns the HSBA components of the color.
    func hsbaComponents() -> (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        var h: CGFloat = 0.0
        var s: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0

        var color: NSUIColor? = self
        #if os(macOS)
        color = withSupportedColorSpace()
        #endif
        color?.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return (hue: h, saturation: s, brightness: b, alpha: a)
    }

    /// Returns the HSLA components of the color.
    func hslaComponents() -> (hue: CGFloat, saturation: CGFloat, lightness: CGFloat, alpha: CGFloat) {
        let hsl = HSL(color: self)
        let rgba = rgbaComponents()
        return (hue: hsl.h, saturation: hsl.s, lightness: hsl.l, alpha: rgba.alpha)
    }

    /**
     Returns a new color object with the specified red component.
     
     - Parameters red: The red component value of the new color object, specified as a value from 0.0 to 1.0. Red values below 0.0 are interpreted as 0.0, and values above 1.0 are interpreted as 1.0.
     - Returns: The new color object.
     */
    func withRed(_ red: CGFloat) -> NSUIColor {
        let rgba = rgbaComponents()
        return NSUIColor(red: red, green: rgba.green, blue: rgba.blue, alpha: rgba.alpha)
    }

    /**
     Returns a new color object with the specified green component.
     
     - Parameters green: The green component value of the new color object, specified as a value from 0.0 to 1.0. Green values below 0.0 are interpreted as 0.0, and values above 1.0 are interpreted as 1.0.
     - Returns: The new color object.
     */
    func withGreen(_ green: CGFloat) -> NSUIColor {
        let rgba = rgbaComponents()
        return NSUIColor(red: rgba.red, green: green, blue: rgba.blue, alpha: rgba.alpha)
    }

    /**
     Returns a new color object with the specified blue component.
     
     - Parameters blue: The blue component value of the new color object, specified as a value from 0.0 to 1.0. Blue values below 0.0 are interpreted as 0.0, and values above 1.0 are interpreted as 1.0.
     - Returns: The new color object.
     */
    func withBlue(_ blue: CGFloat) -> NSUIColor {
        let rgba = rgbaComponents()
        return NSUIColor(red: rgba.red, green: rgba.green, blue: blue, alpha: rgba.alpha)
    }

    /**
     Returns a new color object with the specified alpha component.
     
     - Parameters alpha: The alpha component value of the new color object, specified as a value from 0.0 to 1.0. Alpha values below 0.0 are interpreted as 0.0, and values above 1.0 are interpreted as 1.0.
     - Returns: The new color object.
     */
    func withAlpha(_ alpha: CGFloat) -> NSUIColor {
        let rgba = rgbaComponents()
        return NSUIColor(red: rgba.red, green: rgba.green, blue: rgba.blue, alpha: alpha)
    }

    /**
     Returns a new color object with the specified hue value.
     
     - Parameters hue: The hue value of the new color object, specified as a value from 0.0 to 1.0. Hue values below 0.0 are interpreted as 0.0, and values above 1.0 are interpreted as 1.0.
     - Returns: The new color object.
     */
    func withHue(_ hue: CGFloat) -> NSUIColor {
        let hsba = hsbaComponents()
        return NSUIColor(hue: hue, saturation: hsba.saturation, brightness: hsba.brightness, alpha: hsba.alpha)
    }

    /**
     Returns a new color object with the specified saturation value.
     
     - Parameters saturation: The saturation value of the new color object, specified as a value from 0.0 to 1.0. Saturation values below 0.0 are interpreted as 0.0, and values above 1.0 are interpreted as 1.0.
     - Returns: The new color object.
     */
    func withSaturation(_ saturation: CGFloat) -> NSUIColor {
        let hsba = hsbaComponents()
        return NSUIColor(hue: hsba.hue, saturation: hsba.saturation, brightness: saturation, alpha: hsba.alpha)
    }

    /**
     Returns a new color object with the specified brightness value.
     
     - Parameters brightness: The brightness value of the new color object, specified as a value from 0.0 to 1.0. Brightness values below 0.0 are interpreted as 0.0, and values above 1.0 are interpreted as 1.0.
     - Returns: The new color object.
     */
    func withBrightness(_ brightness: CGFloat) -> NSUIColor {
        let hsba = hsbaComponents()
        return NSUIColor(hue: hsba.hue, saturation: hsba.saturation, brightness: brightness, alpha: hsba.alpha)
    }

    /// Creates a random color.
    static func random() -> NSUIColor {
        return NSUIColor(hue: CGFloat.random(in: 0.0 ... 1.0), saturation: 0.6, lightness: 0.5)
        /*
         return NSUIColor(red: CGFloat.random(in: 0.0...1.0), green: CGFloat.random(in: 0.0...1.0), blue: CGFloat.random(in: 0.0...1.0), alpha: 1.0)
          */
    }

    /// Creates a random pastel color.
    static func randomPastel() -> NSUIColor {
        return NSUIColor(hue: CGFloat.random(in: 0.0 ... 1.0), saturation: 0.8, lightness: 0.8)
    }

    /**
     Returns a new color object in the specified `CGColorSpace`.
     - Parameters colorSpace: The color space of the color.
     - Returns: A `CGColor` object in the `CGColorSpace`.
     */
    func usingCGColorSpace(_ colorSpace: CGColorSpace) -> NSUIColor? {
        guard let cgColor = cgColor.converted(to: colorSpace, intent: .defaultIntent, options: nil) else { return nil }
        return NSUIColor(cgColor: cgColor)
    }

    #if os(macOS)
    /// A boolean value that indicates whether the color is a pattern color.
    var isPatternColor: Bool {
        return (Swift.type(of: self) == NSClassFromString("NSPatternColor"))
    }

    /// A `CGColor` representaton of a pattern color.
    var patternImageCGColor: CGColor? {
        guard isPatternColor else { return nil }
        return CGColor.fromImage(patternImage)
    }
    #endif
}
