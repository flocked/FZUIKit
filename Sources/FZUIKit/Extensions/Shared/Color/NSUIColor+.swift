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
    /// Returns the RGBA (red, green, blue, alpha) components.
    final func rgbaComponents() -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
      var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0

      #if os(iOS) || os(tvOS) || os(watchOS)
        getRed(&r, green: &g, blue: &b, alpha: &a)

        return (r, g, b, a)
      #elseif os(OSX)
        guard let rgbaColor = self.usingColorSpace(.deviceRGB) else {
          fatalError("Could not convert color to RGBA.")
        }

        rgbaColor.getRed(&r, green: &g, blue: &b, alpha: &a)

        return (r, g, b, a)
      #endif
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

    /// A random color.
    static func random() -> NSUIColor {
        return NSUIColor(hue: CGFloat.random(in: 0.0 ... 1.0), saturation: 0.6, lightness: 0.5)
        /*
         return NSUIColor(red: CGFloat.random(in: 0.0...1.0), green: CGFloat.random(in: 0.0...1.0), blue: CGFloat.random(in: 0.0...1.0), alpha: 1.0)
          */
    }

    /// A random pastel color.
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
    
    /**
     A Boolean value that indicates whether the color is light or dark.

     It is useful when you need to know whether you should display the text in black or white.
     */
    func isLight() -> Bool {
      let components = rgbaComponents()
      let brightness = ((components.red * 299.0) + (components.green * 587.0) + (components.blue * 114.0)) / 1000.0

      return brightness >= 0.5
    }
    
    #if os(macOS) || os(iOS) || os(tvOS)
    /**
     Generates the resolved color for the specified view,.
     
     - Parameters view: The view for the resolved color.
     - Returns: A resolved color for the view.
     */
    func resolvedColor(for view: NSUIView) -> NSUIColor {
        #if os(macOS)
        self.resolvedColor(for: view.effectiveAppearance)
        #elseif canImport(UIKit)
        self.resolvedColor(with: view.traitCollection)
        #endif
    }
    
    /// A Boolean value that indicates whether the color contains a different light and dark color variant.
    var isDynamic: Bool {
        let dyamic = self.dynamicColors
        return dyamic.light != dyamic.dark
    }
    
    /**
     Creates a gradient color object that uses the specified colors and frame as gradient.
     
     - Parameters:
        - gradientColors: The colors of the gradient.
        - frame: The frame of the gradient.
     
     - Returns: A gradient color.
     */
    convenience init(gradientColors: [NSUIColor], frame: CGRect) {
        let backgroundGradientLayer = CAGradientLayer()
        backgroundGradientLayer.frame = frame
        backgroundGradientLayer.colors = gradientColors.map({$0.cgColor})
        let backgroundColorImage = backgroundGradientLayer.renderedImage
        self.init(patternImage: backgroundColorImage)
    }
    #endif
    
    /// A Boolean value that indicates whether the color is visible (`alphaComponent` isn't zero).
    var isVisible: Bool {
        self.alphaComponent != 0.0
    }
}
