//
//  NSUIColor+HSL.swift
//
// Parts taken from:
// Copyright 2015-present Yannick Loriot.
//
//  Created by Florian Zand on 06.10.22.
//
//

import FZSwiftUtils
import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif os(macOS)
import AppKit
#endif

public extension NSUIColor {
    /**
     Initializes and returns a color object using the specified opacity and HSL component values.

     - Parameters:
        - hue: The hue degree (between `0.0` to `360.0`).
        - saturation: The saturation value (between `0.0` to `1.0`).
        - lightness: The lightness value (between `0.0` to `1.0`).
        - alpha: The alpha value (between `0.0` to `1.0`).
     */
    convenience init(hue: CGFloat, saturation: CGFloat, lightness: CGFloat, alpha: CGFloat = 1) {
        let h = hue.fractionalRemainder(dividingBy: 360.0)
        var s = saturation
        let l = lightness

        let t = s * ((l < 0.5) ? l : (1.0 - l))
        let b = l + t
        s = (l > 0.0) ? (2.0 * t / b) : 0.0

        self.init(hue: h, saturation: s, brightness: b, alpha: alpha)
    }

    /// Creates a color using the HSLA components.
    internal convenience init(_ hslaComponents: HSLAComponents) {
        self.init(hue: hslaComponents.hue, saturation: hslaComponents.saturation, lightness: hslaComponents.lightness, alpha: hslaComponents.alpha)
    }

    // MARK: - Getting the HSL Components

    /**
     Returns the HSLA (hue, saturation, lightness, alpha) components of the color.

     - Note: The hue value is between 0.0 and 360.0 degree.
     */
    final func hslaComponents() -> HSLAComponents {
        var hsba = hsbaComponents()
        let lightness = ((2.0 - hsba.saturation) * hsba.brightness) / 2.0
        switch lightness {
        case 0.0, 1.0:
            hsba.saturation = 0.0
        case 0.0 ..< 0.5:
            hsba.saturation = (hsba.saturation * hsba.brightness) / (lightness * 2.0)
        default:
            hsba.saturation = (hsba.saturation * hsba.brightness) / (2.0 - lightness * 2.0)
        }
        return HSLAComponents(hsba.hue * 360.0, hsba.saturation, lightness, hsba.alpha)
    }
    
    /**
     Returns a new color object with the specified lightness value.

     - Parameter lightness: The lightness value of the new color object, specified as a value from 0.0 to 1.0. Lightness values below 0.0 are interpreted as 0.0, and values above 1.0 are interpreted as 1.0.
     - Returns: The new color object.
     */
    func withLightness(_ lightness: CGFloat) -> NSUIColor {
        #if os(macOS) || os(iOS) || os(tvOS)
        let dynamic = dynamicColors
        if dynamic.light != dynamic.dark {
            return NSUIColor(light: dynamic.light._withLightness(lightness), dark: dynamic.dark._withLightness(lightness))
        }
        #endif
        return _withLightness(lightness)
    }
    
    internal func _withLightness(_ lightness: CGFloat) -> NSUIColor {
        var hslaComponents = hslaComponents()
        hslaComponents.lightness = lightness.clamped(to: 0.0...1.0)
        return NSUIColor(hslaComponents)
    }
}

/// The HSLA (hue, saturation, lightness, alpha) components of a color.
public struct HSLAComponents: Hashable {
    /// The hue component of the color (between `0.0` to `360.0` degree).
    public var hue: CGFloat {
        didSet { hue = hue.fractionalRemainder(dividingBy: 360.0) }
    }
    
    /// Sets the hue component of the color (between `0.0` to `360.0` degree).
    @discardableResult
    public func hue(_ hue: CGFloat) -> Self {
        var components = self
        components.hue = hue
        return components
    }

    /// The saturation component of the color (between `0.0` to `1.0`).
    public var saturation: CGFloat {
        didSet { saturation = saturation.clamped(to: 0.0...1.0) }
    }
    
    /// Sets the saturation component of the color (between `0.0` to `1.0`).
    @discardableResult
    public func saturation(_ saturation: CGFloat) -> Self {
        var components = self
        components.saturation = saturation
        return components
    }

    /// The lightness component of the color (between `0.0` to `1.0`).
    public var lightness: CGFloat {
        didSet { lightness = lightness.clamped(to: 0.0...1.0) }
    }
    
    /// Sets the lightness component of the color (between `0.0` to `1.0`).
    @discardableResult
    public func lightness(_ lightness: CGFloat) -> Self {
        var components = self
        components.lightness = lightness
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
     Creates HSLA components with the specified hue, saturation, lightness and alpha components.
     
     - Parameters:
        - hue: The hue degree (between `0.0` to `360.0`).
        - saturation: The saturation value (between `0.0` to `1.0`).
        - lightness: The lightness value (between `0.0` to `1.0`).
        - alpha: The alpha value (between `0.0` to `1.0`).
     */
    public init(hue: CGFloat, saturation: CGFloat, lightness: CGFloat, alpha: CGFloat = 1.0) {
        self.hue = hue.fractionalRemainder(dividingBy: 360.0)
        self.saturation = saturation.clamped(to: 0.0...1.0)
        self.lightness = lightness.clamped(to: 0.0...1.0)
        self.alpha = alpha.clamped(to: 0.0...1.0)
    }

    init(_ hue: CGFloat, _ saturation: CGFloat, _ lightness: CGFloat, _ alpha: CGFloat) {
        self.hue = hue.fractionalRemainder(dividingBy: 360.0)
        self.saturation = saturation.clamped(to: 0.0...1.0)
        self.lightness = lightness.clamped(to: 0.0...1.0)
        self.alpha = alpha.clamped(to: 0.0...1.0)
    }

    #if os(macOS)
    /// Returns the `NSColor`.
    public func nsColor() -> NSUIColor {
        NSUIColor(self)
    }
    #else
    /// Returns the `UIColor`.
    public func uiColor() -> NSUIColor {
        NSUIColor(self)
    }
    #endif

    /// Returns the SwiftUI `Color`.
    public func toColor() -> Color {
        Color(self)
    }

    /// Returns the `CGColor`.
    public func toCGColor() -> CGColor {
        NSUIColor(self).cgColor
    }
}

public extension Color {
    /// Creates a color using the HSLA components.
    init(_ hslaComponents: HSLAComponents) {
        self.init(NSUIColor(hslaComponents))
    }
}

public extension CGType where Self == CGColor {
    /// Creates a color using the HSLA components.
    init(_ hslaComponents: HSLAComponents) {
        self = NSUIColor(hslaComponents).cgColor
    }
}
