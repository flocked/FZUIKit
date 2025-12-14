//
//  NSUIColor+OKLCH.swift
//  
//
//  Created by Florian Zand on 12.12.25.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import SwiftUI
import FZSwiftUtils

/// A color in the OKLCH color space.
public struct OKLCHComponents: Hashable, Codable {
    /// The perceptual lightness component of the color.
    public var lightness: CGFloat

    /// The chroma (colorfulness) component of the color.
    public var chroma: CGFloat

    /// The hue angle of the color (in degrees).
    public var hue: CGFloat
    
    /// The alpha value of the color (between `0.0` to `1.0`).
    public var alpha: CGFloat {
        didSet { alpha = alpha.clamped(to: 0.0...1.0) }
    }
    
    /// Sets the perceptual lightness component of the color.
    public func lightness(_ lightness: CGFloat) -> Self {
        var components = self
        components.lightness = lightness
        return components
    }
    
    /// Sets the chroma (colorfulness) component of the color.
    public func chroma(_ chroma: CGFloat) -> Self {
        var components = self
        components.chroma = chroma
        return components
    }
    
    /// Sets the hue angle of the color (in degrees).
    public func hue(_ hue: CGFloat) -> Self {
        var components = self
        components.hue = hue
        return components
    }
    
    /// Sets the alpha value of the color (between `0.0` to `1.0`).
    public func alpha(_ alpha: CGFloat) -> Self {
        var components = self
        components.alpha = alpha
        return components
    }
    
    /// The color as OKLAB.
    public func oklab() -> OKLabComponents {
        let hRad = hue * 2.0 * CGFloat.pi
        let greenRed = chroma * cos(hRad)
        let blueYellow = chroma * sin(hRad)
        return .init(lightness, greenRed, blueYellow, alpha)
    }
    
    /// The color as RGBA.
    public func rgba() -> RGBAComponents {
        oklab().rgba()
    }
    
    /// The color as HSLA.
    public func hsla() -> HSLAComponents {
        oklab().rgba().hsla()
    }
    
    /// The color as HSBA.
    public func hsba() -> HSBAComponents {
        oklab().rgba().hsba()
    }

    /**
     Creates a color in the OKLCH color space from the specified lightness, chroma and hue component values.

     - Parameters:
        - lightness: The perceptual lightness component of the color.
        - chroma: The chroma (colorfulness) component of the color.
        - hue: The hue angle of the color (in degrees).
        - alpha: The alpha value of the color (between `0.0` to `1.0`).
     */
    public init(lightness: CGFloat, chroma: CGFloat, hue: CGFloat, alpha: CGFloat = 1.0) {
        self.lightness = lightness
        self.chroma = chroma
        self.hue = hue
        self.alpha = alpha
    }
    
    init(_ lightness: CGFloat, _ chroma: CGFloat, _ hue: CGFloat, _ alpha: CGFloat) {
        self.init(lightness: lightness, chroma: chroma, hue: hue, alpha: alpha)
    }
}
