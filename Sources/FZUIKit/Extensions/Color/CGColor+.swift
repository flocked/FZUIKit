//
//  CGColor+.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import SwiftUI

public extension CGColor {
    /**
     Creates a new color in a different color space that matches the provided color.

     - Parameters:
        - colorSpaceName: The name of the color space.
        - intent: The mechanism to use to match the color when the color is outside the gamut of the new color space.
     - Returns: A new color in the destination color space that matches (or closely approximates) the source color.
     */
    func converted(to colorSpaceName: CGColorSpaceName, intent: CGColorRenderingIntent = .defaultIntent, options: CFDictionary? = nil) -> CGColor? {
        guard let colorSpace = CGColorSpace(name: colorSpaceName) else { return nil }
        return converted(to: colorSpace, intent: intent, options: options)
    }
    
    /**
     Creates a new color in a different color space that matches the provided color.

     - Parameters:
        - colorSpaceName: The name of the color space.
        - intent: The mechanism to use to match the color when the color is outside the gamut of the new color space.
     - Returns: A new color in the destination color space that matches (or closely approximates) the source color.
     */
    func converted(to colorSpace: CGColorSpace, intent: CGColorRenderingIntent = .defaultIntent) -> CGColor? {
        converted(to: colorSpace, intent: intent, options: nil)
    }

    /// Returns the RGBA (red, green, blue, alpha) components of the color.
    func rgbaComponents() -> RGBAComponents? {
        var color = self
        if color.colorSpace?.model != .rgb, #available(iOS 9.0, macOS 10.11, tvOS 9.0, watchOS 2.0, *) {
            color = color.converted(to: CGColorSpaceCreateDeviceRGB(), intent: .defaultIntent, options: nil) ?? color
        }
        guard let components = color.components else { return nil }
        switch components.count {
        case 2:
            return RGBAComponents(components[0], components[0], components[0], components[1])
        case 3:
            return RGBAComponents(components[0], components[1], components[2], 1.0)
        case 4:
            return RGBAComponents(components[0], components[1], components[2], components[3])
        default:
            #if os(macOS) || os(iOS) || os(tvOS)
            let ciColor = CIColor(cgColor: color)
            return RGBAComponents(ciColor.red, ciColor.green, ciColor.blue, ciColor.alpha)
            #else
            return nil
            #endif
        }
    }

    /**
     Creates a new color object whose component values are a weighted sum of the current color object and the specified color object's.

     - Parameters:
        - fraction: The amount of the color to blend with the receiver's color. The method converts color and a copy of the receiver to RGB, and then sets each component of the returned color to fraction of color’s value plus 1 – fraction of the receiver’s.
        - color: The color to blend with the receiver's color.

     - Returns: The resulting color object or `nil` if the color couldn't be created.
     */
    func blended(withFraction fraction: CGFloat, of color: CGColor) -> CGColor? {
        guard var c1 = rgbaComponents(), let c2 = color.rgbaComponents() else { return nil }
        c1.blend(withFraction: fraction, of: c2)
        return CGColor(red: c1.red, green: c1.green, blue: c1.blue, alpha: c1.alpha)
    }

    /// A Boolean value indicating whether the color is visible (alpha value isn't zero).
    var isVisible: Bool {
        alpha != 0.0
    }

    /**
     A Boolean value indicating whether the color is light.

     It is useful when you need to know whether you should display the text in black or white.
     */
    var isLight: Bool {
        guard let components = rgbaComponents() else { return true }
        let brightness = ((components.red * 299.0) + (components.green * 587.0) + (components.blue * 114.0)) / 1000.0

        return brightness >= 0.5
    }

    /**
     Creates a color object with the specified alpha component.

     - Parameter alpha: The opacity value of the new color object, specified as a value from 0.0 to 1.0. Alpha values below 0.0 are interpreted as 0.0, and values above 1.0 are interpreted as 1.0.
     - Returns: The new `CGColor` object.
     */
    func withAlpha(_ alpha: CGFloat) -> CGColor {
        copy(alpha: alpha) ?? self
    }

    /**
     Returns a new color object with the specified red component.

     - Parameter red: The red component value of the new color object, specified as a value from `0.0` to `1.0.` Red values below `0.0` are interpreted as `0.0`, and values above `1.0` are interpreted as `1.0`.
     - Returns: The new color object.
     */
    func withRed(_ red: CGFloat) -> CGColor {
        guard let rgba = rgbaComponents() else { return self }
        return CGColor(red: red.clamped(to: 0...1.0), green: rgba.green, blue: rgba.blue, alpha: rgba.alpha)
    }

    /**
     Returns a new color object with the specified green component.

     - Parameter green: The green component value of the new color object, specified as a value from `0.0` to `1.0.` Green values below `0.0` are interpreted as `0.0`, and values above `1.0` are interpreted as `1.0`.
     - Returns: The new color object.
     */
    func withGreen(_ green: CGFloat) -> CGColor {
        guard let rgba = rgbaComponents() else { return self }
        return CGColor(red: rgba.red, green: green.clamped(to: 0...1.0), blue: rgba.blue, alpha: rgba.alpha)
    }

    /**
     Returns a new color object with the specified blue component.

     - Parameter blue: The blue component value of the new color object, specified as a value from `0.0` to `1.0.` Blue values below `0.0` are interpreted as `0.0`, and values above `1.0` are interpreted as `1.0`.
     - Returns: The new color object.
     */
    func withBlue(_ blue: CGFloat) -> CGColor {
        guard let rgba = rgbaComponents() else { return self }
        return CGColor(red: rgba.red, green: rgba.green, blue: blue.clamped(to: 0...1.0), alpha: rgba.alpha)
    }

    /// The red component of the color.
    var red: CGFloat {
        rgbaComponents()?.red ?? 0.0
    }

    /// The green component of the color.
    var green: CGFloat {
        rgbaComponents()?.green ?? 0.0
    }

    /// The blue component of the color.
    var blue: CGFloat {
        rgbaComponents()?.blue ?? 0.0
    }

    /// Returns a color from a pattern image.
    static func fromImage(_ image: NSUIImage) -> CGColor {
        let drawPattern: CGPatternDrawPatternCallback = { info, context in
            let image = Unmanaged<NSUIImage>.fromOpaque(info!).takeUnretainedValue()
            guard let cgImage = image.cgImage else { return }
            context.draw(cgImage, in: CGRect(origin: .zero, size: image.size))
        }

        var callbacks = CGPatternCallbacks(version: 0, drawPattern: drawPattern, releaseInfo: nil)

        let pattern = CGPattern(info: Unmanaged.passRetained(image).toOpaque(),
                                bounds: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height),
                                matrix: CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: 0, ty: 0),
                                xStep: image.size.width,
                                yStep: image.size.height,
                                tiling: .constantSpacing,
                                isColored: true,
                                callbacks: &callbacks)!

        let space = CGColorSpace(patternBaseSpace: nil)
        let color = CGColor(patternSpace: space!, pattern: pattern, components: [1.0])!
        return color
    }

    #if os(macOS)
    /// Returns a `NSColor` representation of the color.
    var nsColor: NSColor? {
        NSColor(cgColor: self)
    }

    /// Returns a `Color` representation of the color.
    var swiftUI: Color? {
        if let color = self.nsColor {
            return Color(color)
        }
        return nil
    }

    #elseif canImport(UIKit)
    /// Returns a `UIColor` representation of the color.
    var uiColor: UIColor {
        UIColor(cgColor: self)
    }

    /// Returns a `Color` representation of the color.
    var swiftUI: Color {
        Color(uiColor)
    }

    /// The clear color in the Generic gray color space.
    static var clear: CGColor {
        CGColor(gray: 0, alpha: 0)
    }

    /// The black color in the Generic gray color space.
    static var black: CGColor {
        CGColor(gray: 1, alpha: 1)
    }

    /// The white color in the Generic gray color space.
    static var white: CGColor {
        CGColor(gray: 0, alpha: 1)
    }
    #endif

    internal var nsUIColor: NSUIColor? {
        NSUIColor(cgColor: self)
    }
}

extension CGColor: CustomStringConvertible {
    public var description: String {
        CFCopyDescription(self) as String
    }
}
