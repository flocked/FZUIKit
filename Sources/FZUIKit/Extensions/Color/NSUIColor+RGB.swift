//
//  NSUIColor+RGB.swift
//
//
//  Created by Florian Zand on 04.12.23.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import SwiftUI
import FZSwiftUtils

extension NSUIColor {
    /// Returns the RGBA (red, green, blue, alpha) components of the color.
    public func rgbaComponents() -> RGBAComponents {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        #if os(macOS)
        if let color = usingColorSpace(.deviceRGB) ?? usingColorSpace(.genericRGB) {
            color.getRed(&r, green: &g, blue: &b, alpha: &a)
        } else {
            fatalError("Could not convert color to RGBA.")
        }
        #else
        if !getRed(&r, green: &g, blue: &b, alpha: &a) {
            if getWhite(&r, alpha: &a) {
                return RGBAComponents(r, r, r, a)
            } else {
                fatalError("Could not convert color to RGBA.")
            }
        }
        #endif
        return RGBAComponents(r, g, b, a)
    }

    #if os(iOS) || os(tvOS) || os(watchOS)
        /// The red component of the color.
        var redComponent: CGFloat {
            rgbaComponents().red
        }

        /// The green component of the color.
        var greenComponent: CGFloat {
            rgbaComponents().green
        }

        /// The blue component of the color.
        var blueComponent: CGFloat {
            rgbaComponents().blue
        }

        /// The alpha component of the color.
        var alphaComponent: CGFloat {
            rgbaComponents().alpha
        }
    #endif

    /// Returns a new color object with the specified red component (between `0.0` and `1.0`).
    @objc open func withRed(_ red: CGFloat) -> NSUIColor {
        #if os(macOS) || os(iOS) || os(tvOS)
        let dynamic = dynamicColors
        if dynamic.light != dynamic.dark {
            return NSUIColor(light: NSUIColor(dynamic.light.rgbaComponents().red(red)), dark: NSUIColor(dynamic.dark.rgbaComponents().red(red)))
        }
        #endif
        return NSUIColor(rgbaComponents().red(red))
    }

    /// Returns a new color object with the specified green component (between `0.0` and `1.0`).
    @objc open func withGreen(_ green: CGFloat) -> NSUIColor {
        #if os(macOS) || os(iOS) || os(tvOS)
        let dynamic = dynamicColors
        if dynamic.light != dynamic.dark {
            return NSUIColor(light: NSUIColor(dynamic.light.rgbaComponents().green(green)), dark: NSUIColor(dynamic.dark.rgbaComponents().green(green)))
        }
        #endif
        return NSUIColor(rgbaComponents().green(green))
    }

    /// Returns a new color object with the specified blue component (between `0.0` and `1.0`).
    @objc open func withBlue(_ blue: CGFloat) -> NSUIColor {
        #if os(macOS) || os(iOS) || os(tvOS)
        let dynamic = dynamicColors
        if dynamic.light != dynamic.dark {
            return NSUIColor(light: NSUIColor(dynamic.light.rgbaComponents().blue(blue)), dark: NSUIColor(dynamic.dark.rgbaComponents().blue(blue)))
        }
        #endif
        return NSUIColor(rgbaComponents().blue(blue))
    }

    /// Returns a new color object with the specified alpha value (between `0.0` and `1.0`).
    @objc open func withAlpha(_ alpha: CGFloat) -> NSUIColor {
        withAlphaComponent(alpha)
    }
}

/// The RGBA (red, green, blue, alpha) components of a color.
public struct RGBAComponents: Codable, Hashable {
    /// The red component of the color (between `0.0` to `1.0`).
    public var red: CGFloat {
        didSet { red = red.clamped(to: 0.0...1.0) }
    }
    
    /// Sets the red component of the color (between `0.0` to `1.0`).
    @discardableResult
    public func red(_ red: CGFloat) -> Self {
        var components = self
        components.red = red
        return components
    }

    /// The green component of the color (between `0.0` to `1.0`).
    public var green: CGFloat {
        didSet { green = green.clamped(to: 0.0...1.0) }
    }
    
    /// Sets the green component of the color (between `0.0` to `1.0`).
    @discardableResult
    public func green(_ green: CGFloat) -> Self {
        var components = self
        components.green = green
        return components
    }

    /// The blue component of the color (between `0.0` to `1.0`).
    public var blue: CGFloat {
        didSet { blue = blue.clamped(to: 0.0...1.0) }
    }
    
    /// Sets the blue component of the color (between `0.0` to `1.0`).
    @discardableResult
    public func blue(_ blue: CGFloat) -> Self {
        var components = self
        components.blue = blue
        return components
    }

    /// The alpha value of the color (between `0.0` to `1.0`).
    public var alpha: CGFloat {
        didSet { alpha = alpha.clamped(to: 0.0...1.0) }
    }
    
    /// Sets the alpha value of the color (between `0.0` to `1.0`).
    @discardableResult
    public func alpha(_ alpha: CGFloat) -> Self {
        var components = self
        components.alpha = alpha
        return components
    }
    
    /**
     Blends the color components with the specified components.

     - Parameters:
        - fraction: The amount of the color to blend (between `0.0` and `1.0`).
        - components: The components to blend.
     */
    public mutating func blend(withFraction fraction: CGFloat, of components: RGBAComponents) {
        let fraction = fraction.clamped(to: 0...1.0)
        red = red + (fraction * (components.red - red))
        green = green + (fraction * (components.green - green))
        blue = blue + (fraction * (components.blue - blue))
        alpha = alpha + (fraction * (components.alpha - alpha))
    }
    
    /**
     Blends the color components with the specified components.

     - Parameters:
        - fraction: The amount of the color to blend (between `0.0` and `1.0`).
        - components: The components to blend.
     
     - Returns: The color components blended with the specified components.
     */
    public func blended(withFraction fraction: CGFloat, of components: RGBAComponents) -> RGBAComponents {
        var rgba = self
        rgba.blend(withFraction: fraction, of: components)
        return RGBAComponents(rgba.red, rgba.green, rgba.blue, rgba.alpha)
    }

    #if os(macOS)
    /// Returns the `NSColor`.
    public func nsColor() -> NSUIColor {
        NSUIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    #else
    /// Returns the `UIColor`.
    public func uiColor() -> NSUIColor {
        NSUIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    #endif

    /// Returns the `CGColor`.
    public func cgColor() -> CGColor {
        CGColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    /// Returns the SwiftUI `Color`.
    public func color() -> Color {
        Color(red: red, green: green, blue: blue, opacity: alpha)
    }

    /// Components with zero alpha.
    static let zero = RGBAComponents(0.0, 0.0, 0.0, 0.0)

    /**
     Creates RGBA components with the specified red, green, blue and alpha components.
     
     - Parameters:
        - red: The red component of the color (between `0.0` to `1.0`).
        - green: The green component of the color (between `0.0` to `1.0`).
        - blue: The blue component of the color (between `0.0` to `1.0`).
        - alpha: The alpha value of the color (between `0.0` to `1.0`).
     */
    public init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        self.red = red.clamped(to: 0.0...1.0)
        self.green = green.clamped(to: 0.0...1.0)
        self.blue = blue.clamped(to: 0.0...1.0)
        self.alpha = alpha.clamped(to: 0.0...1.0)
    }

    init(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) {
        self.red = red.clamped(to: 0.0...1.0)
        self.green = green.clamped(to: 0.0...1.0)
        self.blue = blue.clamped(to: 0.0...1.0)
        self.alpha = alpha.clamped(to: 0.0...1.0)
    }
}

public extension NSUIColor {
    /// Creates a color using the RGBA components.
    convenience init(_ rgbaComponents: RGBAComponents) {
        self.init(red: rgbaComponents.red, green: rgbaComponents.green, blue: rgbaComponents.blue, alpha: rgbaComponents.alpha)
    }
}

public extension Color {
    /// Creates a color using the RGBA components.
    init(_ rgbaComponents: RGBAComponents) {
        self.init(red: rgbaComponents.red, green: rgbaComponents.green, blue: rgbaComponents.blue, opacity: rgbaComponents.alpha)
    }
}

public extension CFType where Self == CGColor {
    /// Creates a color using the RGBA components.
    init(_ rgbaComponents: RGBAComponents) {
        self.init(red: rgbaComponents.red, green: rgbaComponents.green, blue: rgbaComponents.blue, alpha: rgbaComponents.alpha)
    }
}
