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

extension NSUIColor {
    /// Returns the RGBA (red, green, blue, alpha) components of the color.
    public func rgbaComponents() -> RGBAComponents {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0

        #if os(iOS) || os(tvOS) || os(watchOS)
            getRed(&r, green: &g, blue: &b, alpha: &a)

            return RGBAComponents(r, g, b, a)
        #elseif os(OSX)
            guard let rgbaColor = usingColorSpace(.deviceRGB) else {
                fatalError("Could not convert color to RGBA.")
            }

            rgbaColor.getRed(&r, green: &g, blue: &b, alpha: &a)

            return RGBAComponents(r, g, b, a)
        #endif
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

    /**
     Returns a new color object with the specified red component.

     - Parameter red: The red component value of the new color object, specified as a value from `0.0` to `1.0.` Red values below `0.0` are interpreted as `0.0`, and values above `1.0` are interpreted as `1.0`.
     - Returns: The new color object.
     */
    @objc open func withRed(_ red: CGFloat) -> NSUIColor {
        let dynamic = dynamicColors
        if dynamic.light == dynamic.dark {
            return NSUIColor(rgbaComponents().red(red))
        } else {
           return NSUIColor(light: NSUIColor(dynamic.light.rgbaComponents().red(red)), dark: NSUIColor(dynamic.dark.rgbaComponents().red(red)))
        }
    }

    /**
     Returns a new color object with the specified green component.

     - Parameter green: The green component value of the new color object, specified as a value from `0.0` to `1.0.` Green values below `0.0` are interpreted as `0.0`, and values above `1.0` are interpreted as `1.0`.
     - Returns: The new color object.
     */
    @objc open func withGreen(_ green: CGFloat) -> NSUIColor {
        let dynamic = dynamicColors
        if dynamic.light == dynamic.dark {
            return NSUIColor(rgbaComponents().green(green))
        } else {
           return NSUIColor(light: NSUIColor(dynamic.light.rgbaComponents().green(green)), dark: NSUIColor(dynamic.dark.rgbaComponents().green(green)))
        }
    }

    /**
     Returns a new color object with the specified blue component.

     - Parameter blue: The blue component value of the new color object, specified as a value from `0.0` to `1.0.` Blue values below `0.0` are interpreted as `0.0`, and values above `1.0` are interpreted as `1.0`.
     - Returns: The new color object.
     */
    @objc open func withBlue(_ blue: CGFloat) -> NSUIColor {
        let dynamic = dynamicColors
        if dynamic.light == dynamic.dark {
            return NSUIColor(rgbaComponents().blue(blue))
        } else {
           return NSUIColor(light: NSUIColor(dynamic.light.rgbaComponents().blue(blue)), dark: NSUIColor(dynamic.dark.rgbaComponents().blue(blue)))
        }
    }

    /**
     Returns a new color object with the specified alpha component.

     - Parameter alpha: The alpha component value of the new color object, specified as a value from `0.0` to `1.0.` Alpha values below `0.0` are interpreted as `0.0`, and values above `1.0` are interpreted as `1.0`.
     - Returns: The new color object.
     */
    @objc open func withAlpha(_ alpha: CGFloat) -> NSUIColor {
        let dynamic = dynamicColors
        if dynamic.light == dynamic.dark {
            #if os(macOS)
            return withAlphaComponent(alpha.clamped(to: 0...1.0))
            #else
            return NSUIColor(rgbaComponents().alpha(alpha))
            #endif
        } else {
           return NSUIColor(light: NSUIColor(dynamic.light.rgbaComponents().alpha(alpha)), dark: NSUIColor(dynamic.dark.rgbaComponents().alpha(alpha)))
        }
    }
}

/// The RGBA (red, green, blue, alpha) components of a color.
public struct RGBAComponents: Codable, Hashable {
    /// The red component of the color.
    public var red: CGFloat {
        didSet { red = red.clamped(to: 0.0...1.0) }
    }
    
    /// Sets the red component of the color.
    @discardableResult
    public func red(_ red: CGFloat) -> Self {
        var components = self
        components.red = red
        return components
    }

    /// The green component of the color.
    public var green: CGFloat {
        didSet { green = green.clamped(to: 0.0...1.0) }
    }
    
    /// Sets the green component of the color.
    @discardableResult
    public func green(_ green: CGFloat) -> Self {
        var components = self
        components.green = green
        return components
    }

    /// The blue component of the color.
    public var blue: CGFloat {
        didSet { blue = blue.clamped(to: 0.0...1.0) }
    }
    
    /// Sets the blue component of the color.
    @discardableResult
    public func blue(_ blue: CGFloat) -> Self {
        var components = self
        components.blue = blue
        return components
    }

    /// The alpha value of the color.
    public var alpha: CGFloat {
        didSet { alpha = alpha.clamped(to: 0.0...1.0) }
    }
    
    /// Sets the alpha value of the color.
    @discardableResult
    public func alpha(_ alpha: CGFloat) -> Self {
        var components = self
        components.alpha = alpha
        return components
    }
    
    /**
     Blends the color components with the specified components.

     - Parameters:
        - fraction: The amount of the color to blend between `0.0` and `1.0`.
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
        - fraction: The amount of the color to blend between `0.0` and `1.0`.
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

    /// Creates RGBA components with the specified red, green, blue and alpha components.
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
