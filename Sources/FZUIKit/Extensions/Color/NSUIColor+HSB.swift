//
//  NSUIColor+HSB.swift
//
//
//  Created by Florian Zand on 06.10.23.
//

#if canImport(UIKit)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import SwiftUI
import FZSwiftUtils

extension NSUIColor {
    /// Returns the HSBA (hue, saturation, brightness, alpha) components of the color.
    public func hsbaComponents() -> HSBAComponents {
        var hsba: (h: CGFloat, s: CGFloat, b: CGFloat, a: CGFloat) = (0,0,0,0)
        #if os(macOS)
        if let color = usingColorSpace(.deviceRGB) ?? usingColorSpace(.genericRGB) {
            color.getHue(&hsba.h, saturation: &hsba.s, brightness: &hsba.b, alpha: &hsba.a)
        } else {
            fatalError("Could not convert color to HSBA.")
        }
        #else
        getHue(&hsba.h, saturation: &hsba.s, brightness: &hsba.b, alpha: &hsba.a)
        #endif
        return HSBAComponents(hsba.h, hsba.s, hsba.b, hsba.a)
    }

    /// Creates a color using the HSBA components.
    public convenience init(_ hsbaComponents: HSBAComponents) {
        self.init(hue: hsbaComponents.hue, saturation: hsbaComponents.saturation, brightness: hsbaComponents.brightness, alpha: hsbaComponents.alpha)
    }

    #if os(iOS) || os(tvOS) || os(watchOS)
    /// The hue component of the color.
    public final var hueComponent: CGFloat {
        hsbaComponents().hue
    }

    /// The saturation component of the color.
    public final var saturationComponent: CGFloat {
        hsbaComponents().saturation
    }

    /// The brightness component of the color.
    public final var brightnessComponent: CGFloat {
        hsbaComponents().brightness
    }
    #endif

    /**
     Returns a new color object with the specified hue value.

     - Parameter hue: The hue value of the new color object, specified as a value from 0.0 to 1.0. Hue values below 0.0 are interpreted as 0.0, and values above 1.0 are interpreted as 1.0.
     - Returns: The new color object.
     */
    @objc open func withHue(_ hue: CGFloat) -> NSUIColor {
        #if os(macOS) || os(iOS) || os(tvOS)
        let dynamic = dynamicColors
        if dynamic.light != dynamic.dark {
            return NSUIColor(light: dynamic.light._withHue(hue), dark: dynamic.dark._withHue(hue))
        }
        #endif
        return _withHue(hue)
    }

    func _withHue(_ hue: CGFloat) -> NSUIColor {
        let hsba = hsbaComponents()
        return NSUIColor(hue: hue, saturation: hsba.saturation, brightness: hsba.brightness, alpha: hsba.alpha)
    }

    /**
     Returns a new color object with the specified saturation value.

     - Parameter saturation: The saturation value of the new color object, specified as a value from 0.0 to 1.0. Saturation values below 0.0 are interpreted as 0.0, and values above 1.0 are interpreted as 1.0.
     - Returns: The new color object.
     */
    @objc open func withSaturation(_ saturation: CGFloat) -> NSUIColor {
        #if os(macOS) || os(iOS) || os(tvOS)
        let dynamic = dynamicColors
        if dynamic.light != dynamic.dark {
            return NSUIColor(light: dynamic.light._withSaturation(saturation), dark: dynamic.dark._withSaturation(saturation))

        }
        #endif
        return _withSaturation(saturation)
    }

    func _withSaturation(_ saturation: CGFloat) -> NSUIColor {
        let hsba = hsbaComponents()
        return NSUIColor(hue: hsba.hue, saturation: hsba.saturation, brightness: saturation, alpha: hsba.alpha)
    }

    /**
     Returns a new color object with the specified brightness value.

     - Parameter brightness: The brightness value of the new color object, specified as a value from 0.0 to 1.0. Brightness values below 0.0 are interpreted as 0.0, and values above 1.0 are interpreted as 1.0.
     - Returns: The new color object.
     */
    @objc open func withBrightness(_ brightness: CGFloat) -> NSUIColor {
        #if os(macOS) || os(iOS) || os(tvOS)
        let dynamic = dynamicColors
        if dynamic.light != dynamic.dark {
            return NSUIColor(light: dynamic.light._withBrightness(brightness), dark: dynamic.dark._withBrightness(brightness))
        }
        #endif
        return _withBrightness(brightness)
    }

    func _withBrightness(_ brightness: CGFloat) -> NSUIColor {
        let hsba = hsbaComponents()
        return NSUIColor(hue: hsba.hue, saturation: hsba.saturation, brightness: brightness, alpha: hsba.alpha)
    }
}

/// The HSBA (hue, saturation, brightness, alpha) components of a color.
public struct HSBAComponents {
    /// The hue component of the color (between `0.0` to `1.0`).
    public var hue: CGFloat {
        didSet { hue = hue.clamped(to: 0.0...1.0) }
    }

    /// Sets the hue component of the color (between `0.0` to `1.0`).
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

    /// The brightness component of the color (between `0.0` to `1.0`).
    public var brightness: CGFloat {
        didSet { brightness = brightness.clamped(to: 0.0...1.0) }
    }

    /// Sets the brightness component of the color (between `0.0` to `1.0`).
    @discardableResult
    public func brightness(_ brightness: CGFloat) -> Self {
        var components = self
        components.brightness = brightness
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
     Creates HSBA components with the specified hue, saturation, brightness and alpha components.

     - Parameters:
        -  hue: The hue component of the color (between `0.0` to `1.0`).
        - saturation: The saturation component of the color (between `0.0` to `1.0`).
        - brightness: The hue component of the color (between `0.0` to `1.0`).
        - alpha: The alpha vlaue of the color (between `0.0` to `1.0`).
     */
    public init(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        self.hue = hue.clamped(to: 0.0...1.0)
        self.saturation = saturation.clamped(to: 0.0...1.0)
        self.brightness = brightness.clamped(to: 0.0...1.0)
        self.alpha = alpha.clamped(to: 0.0...1.0)
    }

    init(_ hue: CGFloat, _ saturation: CGFloat, _ brightness: CGFloat, _ alpha: CGFloat = 1.0) {
        self.hue = hue.clamped(to: 0.0...1.0)
        self.saturation = saturation.clamped(to: 0.0...1.0)
        self.brightness = brightness.clamped(to: 0.0...1.0)
        self.alpha = alpha.clamped(to: 0.0...1.0)
    }

    #if os(macOS)
    /// Returns the `NSColor`.
    public func toNSColor() -> NSUIColor {
        NSUIColor(self)
    }
    #else
    /// Returns the `UIColor`.
    public func toUIColor() -> NSUIColor {
        NSUIColor(self)
    }
    #endif

    /// Returns the SwiftUI `Color`.
    public func toColor() -> Color {
        Color(hue: hue, saturation: saturation, brightness: brightness, opacity: alpha)
    }

    /// Returns the `CGColor`.
    public func toCGColor() -> CGColor {
        NSUIColor(self).cgColor
    }
}

public extension Color {
    /// Creates a color using the HSBA components.
    init(_ hsbaComponents: HSBAComponents) {
        self.init(hue: hsbaComponents.hue, saturation: hsbaComponents.saturation, brightness: hsbaComponents.brightness, opacity: hsbaComponents.alpha)
    }
}

public extension CFType where Self == CGColor {
    /// Creates a color using the HSBA components.
    init(_ hsbaComponents: HSBAComponents) {
        self = NSUIColor(hsbaComponents).cgColor
    }
}
