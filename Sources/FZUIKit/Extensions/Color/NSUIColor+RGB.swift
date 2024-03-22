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

public extension NSUIColor {
    /// Returns the RGBA (red, green, blue, alpha) components of the color.
    func rgbaComponents() -> RGBAComponents {
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

     - Parameter red: The red component value of the new color object, specified as a value from 0.0 to 1.0. Red values below 0.0 are interpreted as 0.0, and values above 1.0 are interpreted as 1.0.
     - Returns: The new color object.
     */
    func withRed(_ red: CGFloat) -> NSUIColor {
        let rgba = rgbaComponents()
        return NSUIColor(red: red, green: rgba.green, blue: rgba.blue, alpha: rgba.alpha)
    }

    /**
     Returns a new color object with the specified green component.

     - Parameter green: The green component value of the new color object, specified as a value from 0.0 to 1.0. Green values below 0.0 are interpreted as 0.0, and values above 1.0 are interpreted as 1.0.
     - Returns: The new color object.
     */
    func withGreen(_ green: CGFloat) -> NSUIColor {
        let rgba = rgbaComponents()
        return NSUIColor(red: rgba.red, green: green, blue: rgba.blue, alpha: rgba.alpha)
    }

    /**
     Returns a new color object with the specified blue component.

     - Parameter blue: The blue component value of the new color object, specified as a value from 0.0 to 1.0. Blue values below 0.0 are interpreted as 0.0, and values above 1.0 are interpreted as 1.0.
     - Returns: The new color object.
     */
    func withBlue(_ blue: CGFloat) -> NSUIColor {
        let rgba = rgbaComponents()
        return NSUIColor(red: rgba.red, green: rgba.green, blue: blue, alpha: rgba.alpha)
    }

    /**
     Returns a new color object with the specified alpha component.

     - Parameter alpha: The alpha component value of the new color object, specified as a value from 0.0 to 1.0. Alpha values below 0.0 are interpreted as 0.0, and values above 1.0 are interpreted as 1.0.
     - Returns: The new color object.
     */
    func withAlpha(_ alpha: CGFloat) -> NSUIColor {
        let rgba = rgbaComponents()
        return NSUIColor(red: rgba.red, green: rgba.green, blue: rgba.blue, alpha: alpha)
    }
}

/// The RGBA (red, green, blue, alpha) components of a color.
public struct RGBAComponents: Codable, Hashable {
    /// The red component of the color.
    public var red: CGFloat {
        didSet { red = red.clamped(to: 0.0...1.0) }
    }

    /// The green component of the color.
    public var green: CGFloat {
        didSet { green = green.clamped(to: 0.0...1.0) }
    }

    /// The blue component of the color.
    public var blue: CGFloat {
        didSet { blue = blue.clamped(to: 0.0...1.0) }
    }

    /// The alpha value of the color.
    public var alpha: CGFloat {
        didSet { alpha = alpha.clamped(to: 0.0...1.0) }
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
