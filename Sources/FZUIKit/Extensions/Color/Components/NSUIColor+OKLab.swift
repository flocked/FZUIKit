//
//  NSUIColor+OKLab.swift
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

/// A color in the OKLAB color space.
public struct OKLabComponents {
    /// The perceptual lightness component of the color.
    public var lightness: CGFloat

    /// The green–red chromatic component of the color.
    public var greenRed: CGFloat

    /// The blue–yellow chromatic component of the color.
    public var blueYellow: CGFloat
    
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
    
    /// Sets the green–red chromatic component of the color.
    public func greenRed(_ greenRed: CGFloat) -> Self {
        var components = self
        components.greenRed = greenRed
        return components
    }
    
    /// Sets the blue–yellow chromatic component of the color.
    public func blueYellow(_ blueYellow: CGFloat) -> Self {
        var components = self
        components.blueYellow = blueYellow
        return components
    }
    
    /// Sets the alpha value of the color (between `0.0` to `1.0`).
    public func alpha(_ alpha: CGFloat) -> Self {
        var components = self
        components.alpha = alpha
        return components
    }
    
    /// The color as OKLCB.
    public func oklch() -> OKLCHComponents {
        let a = greenRed, b = blueYellow
        let chroma = sqrt(a*a + b*b)
        var hue = atan2(b, a) / (2.0 * CGFloat.pi)
        if hue < 0 { hue += 1 }
        return .init(lightness, chroma, hue, alpha)
    }
    
    /// The components as RGBA.
    public func rgba() -> RGBAComponents {
        let l = lightness, a = greenRed, b = blueYellow

        let Lc = l + 0.3963377774*a + 0.2158037573*b
        let Mc = l - 0.1055613458*a - 0.0638541728*b
        let Sc = l - 0.0894841775*a - 1.2914855480*b

        let L3 = Lc * Lc * Lc
        let M3 = Mc * Mc * Mc
        let S3 = Sc * Sc * Sc

        var R =  4.0767416621*L3 - 3.3077115913*M3 + 0.2309699292*S3
        var G = -1.2684380046*L3 + 2.6097574011*M3 - 0.3413193965*S3
        var B = -0.0041960863*L3 - 0.7034186147*M3 + 1.7076147010*S3
        return RGBAComponents(linearRed: clamp(R, 0, 1), green: clamp(G, 0, 1), blue: clamp(B, 0, 1), alpha: alpha)
    }
    
    /// The components as HSBA.
    public func hsba() -> HSBAComponents {
        rgba().hsba()
    }
    
    /// The components as HSLA.
    public func hsla() -> HSLAComponents {
        rgba().hsla()
    }
    
    @inline(__always) private func clamp(_ x: Double, _ a: Double, _ b: Double) -> Double {
        return min(max(x, a), b)
    }

    /**
     Creates a color in the OKLab color space from the specified lightness, green–red and blue–yellow chromatic component values.

     Creates an OKLab color from its components.

     - Parameters:
        - lightness: The perceptual lightness component of the color.
        - greenRed: The green–red chromatic component of the color.
        - blueYellow: The blue–yellow chromatic component of the color.
        - alpha: The alpha value of the color (between `0.0` to `1.0`).
     */
    public init(lightness: CGFloat, greenRed: CGFloat, blueYellow: CGFloat, alpha: CGFloat = 1.0) {
        self.lightness = lightness
        self.greenRed = greenRed
        self.blueYellow = blueYellow
        self.alpha = alpha
    }
    
    init(_ lightness: CGFloat, _ greenRed: CGFloat, _ blueYellow: CGFloat, _ alpha: CGFloat) {
        self.init(lightness: lightness, greenRed: greenRed, blueYellow: blueYellow, alpha: alpha)
    }
}
