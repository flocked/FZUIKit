//
//  ColorModel.swift
//
//
//  Created by Florian Zand on 13.12.25.
//

import Foundation
import FZSwiftUtils
import Accelerate
import SwiftUI

#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// A representation of the components of a color in a specific color space.
public protocol ColorModel: CustomStringConvertible, Equatable, Hashable, Codable, ApproximateEquatable, Sendable {
    /// Creates the color with the specified color components.
    init(_ components: [Double])
    /// The components of the color.
    var components: [Double] { get set }
    /// `CGColor` representation of the color.
    var cgColor: CGColor { get }
    /// Creates a new color by blending the color with the specified other color.
    func blended(withFraction fraction: Double, of other: Self) -> Self
    /// Blends the color with the specified other color.
    mutating func blend(withFraction fraction: Double, of color: Self)
}

public extension ColorModel {
    /// Creates a new color by blending the color with the specified other color.
    func blended(withFraction fraction: Double, of color: Self) -> Self {
        Self(vDSP.linearInterpolate(components, color.components, using: fraction))
    }
    
    /// Blends the color with the specified other color.
    mutating func blend(withFraction fraction: Double, of color: Self) {
        self = blended(withFraction: fraction, of: color)
    }
    
    /**
     A Boolean value indicating whether the color is approximately equal to the specified other color.

     - Parameters:
       - other: The color to compare against.
       - epsilon: The maximum allowed difference between each component.
     - Returns: `true` if all components of the colors are less than the specified `epsilon`, otherwise, `false`.
     */
    func isApproximatelyEqual(to other: Self, epsilon: Double = 0.00001) -> Bool {
        components.isApproximatelyEqual(to: other.components, epsilon: epsilon)
    }
    
    /// A Boolean value indicating whether the color is visible (`alpha` isn't `0`).
    var isVisible: Bool {
        components.last ?? 0.0 > 0.0
    }
    
    /// The color component at the specified index.
    subscript(index: Int) -> Double {
        get { components[index] }
        set { components[index] = newValue }
    }
    
    /// The color component at the specified index.
    subscript(safe index: Int) -> Double? {
        get { components[safe: index] }
        set { components[safe: index] = newValue }
    }
    
    /// SwiftUI `Color` representation of the color.
    var color: Color {
        Color(self)
    }
    
    #if os(macOS)
    /// `NSColor` representation of the color.
    var nsColor: NSColor {
        NSColor(self)
    }
    #else
    /// `UIColor` representation of the color.
    var uiColor: UIColor {
        UIColor(self)
    }
    #endif
    
    /// Initializes a color from a hex string (e.g. `#1D2E3F`) and an optional alpha value.
    init?(hex: String, alpha: CGFloat = 1.0) {
        guard let components = ColorModels.SRGB(hex: hex, alpha: alpha)?.components else { return nil }
        self.init(components)
    }
    
    /// Initializes a color from a hex string (e.g. `#1D2E3F`) and an optional alpha value.
    init(hex: Int, alpha: CGFloat = 1.0) {
        self.init(ColorModels.SRGB(hex: hex, alpha: alpha).components)
    }
}

/// The color components of a color in a speciic color space.
public struct ColorModels { }

extension NSUIColor {
    /// Creates the color with the specified color components.
    public convenience init(_ colorComponents: some ColorModel) {
        #if os(macOS)
        self.init(cgColor: colorComponents.cgColor)!
        #else
        self.init(cgColor: colorComponents.cgColor)
        #endif
    }
    
    /// The color components in the sRGB color space.
    public func rgb() -> ColorModels.SRGB {
        var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) = (0,0,0,0)
        #if os(macOS)
        if let color = safeColorSpace?.colorSpaceModel == .rgb ? self : usingColorSpace(.extendedSRGB) {
            color.getRed(&rgba.red, green: &rgba.green, blue: &rgba.blue, alpha: &rgba.alpha)
            return .init(red: rgba.red, green: rgba.green, blue: rgba.blue, alpha: rgba.alpha)
        }
        #else
        if getRed(&rgba.red, green: &rgba.green, blue: &rgba.blue, alpha: &rgba.alpha) {
            return .init(red: rgba.red, green: rgba.green, blue: rgba.blue, alpha: rgba.alpha)
        }
        #endif
        return cgColor.rgb()
    }
    
    /// The color components in the HSB color space.
    public func hsb() -> ColorModels.HSB {
        var hsb: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) = (0,0,0,0)
        #if os(macOS)
        if let color = safeColorSpace?.colorSpaceModel == .rgb ? self : usingColorSpace(.extendedSRGB) {
            color.getHue(&hsb.hue, saturation: &hsb.saturation, brightness: &hsb.brightness, alpha: &hsb.alpha)
            return .init(hue: hsb.hue, saturation: hsb.saturation, brightness: hsb.brightness, alpha: hsb.alpha)
        }
        #else
        if getHue(&hsb.hue, saturation: &hsb.saturation, brightness: &hsb.brightness, alpha: &hsb.alpha) {
            return .init(hue: hsb.hue, saturation: hsb.saturation, brightness: hsb.brightness, alpha: hsb.alpha)
        }
        #endif
        return cgColor.hsb()
    }
    
    /// The color components in the HSL color space.
    public func hsl() -> ColorModels.HSL {
        rgb().hsl
    }
    
    /// The color components in the XYZ color space.
    public func xyz() -> ColorModels.XYZ {
        rgb().xyz
    }
    
    /// The color components in the OKLAB color space.
    public func oklab() -> ColorModels.OKLAB {
        rgb().oklab
    }
    
    /// The color components in the OKLCH color space.
    public func oklch() -> ColorModels.OKLCH {
        rgb().oklch
    }
    
    /// The color components in the CIE LAB color space.
    public func lab() -> ColorModels.LAB {
        rgb().lab
    }
    
    /// The color components in the gray color space.
    public func gray() -> ColorModels.Gray {
        rgb().gray
    }
    
    /// The color components in the CMYK color space.
    public func cmyk() -> ColorModels.CMYK {
        rgb().cmyk
    }
    
    /**
     Creates a new color whose component values are a weighted sum of the current color and the specified color.

     - Parameters:
        - fraction: The amount of the color to blend with the current color.
        - color: The color to blend with the current color.
        - colorSpace: The color space in which to blend the colors.

     - Returns: The resulting color.
     */
    @_disfavoredOverload
    public func blended(withFraction fraction: Double, of other: NSUIColor, using colorSpace: ColorModels.ColorSpace = .srgb) -> NSUIColor {
        #if os(macOS) || os(iOS) || os(tvOS)
        let dynamic = dynamicColors
        let otherDynamic = dynamicColors
        if dynamic.isDynamic || otherDynamic.isDynamic {
            return NSUIColor(light: dynamic.light._blended(withFraction: fraction, of: otherDynamic.light, using: colorSpace), dark: dynamic.dark._blended(withFraction: fraction, of: otherDynamic.dark, using: colorSpace))
        }
        #endif
        return _blended(withFraction: fraction, of: other, using: colorSpace)
    }
    
    fileprivate func _blended(withFraction fraction: Double, of other: NSUIColor, using colorSpace: ColorModels.ColorSpace = .srgb) -> NSUIColor {
        switch colorSpace {
        case .srgb: .init(rgb().blended(withFraction: fraction, of: other.rgb()))
        case .xyz: .init(xyz().blended(withFraction: fraction, of: other.xyz()))
        case .oklab: .init(oklab().blended(withFraction: fraction, of: other.oklab()))
        case .oklch: .init(oklch().blended(withFraction: fraction, of: other.oklch()))
        case .hsl: .init(hsl().blended(withFraction: fraction, of: other.hsl()))
        case .hsb: .init(hsb().blended(withFraction: fraction, of: other.hsb()))
        case .cmyk: .init(cmyk().blended(withFraction: fraction, of: other.cmyk()))
        case .lab: .init(lab().blended(withFraction: fraction, of: other.lab()))
        case .gray: .init(gray().blended(withFraction: fraction, of: other.gray()))
        default: .init(rgb().blended(withFraction: fraction, of: other.rgb()))
        }
    }
}

extension CGColor {
    /// The color components in the sRGB color space.
    public func rgb() -> ColorModels.SRGB {
        let components = (colorSpace?.model == .rgb ? self : converted(to: .extendedSRGB))?.components ?? [0, 0, 0, 0]
        return .init(components.map({Double($0)}))
    }
    
    /// The color components in the HSB color space.
    public func hsb() -> ColorModels.HSB {
        rgb().hsb
    }
    
    /// The color components in the HSL color space.
    public func hsl() -> ColorModels.HSL {
        rgb().hsl
    }
    
    /// The color components in the XYZ color space.
    public func xyz() -> ColorModels.XYZ {
        rgb().xyz
    }
    
    /// The color components in the OKLAB color space.
    public func oklab() -> ColorModels.OKLAB {
        rgb().oklab
    }
    
    /// The color components in the OKLCH color space.
    public func oklch() -> ColorModels.OKLCH {
        rgb().oklch
    }
    
    /// The color components in the CIE LAB color space.
    public func lab() -> ColorModels.LAB {
        rgb().lab
    }
    
    /// The color components in the gray color space.
    public func gray() -> ColorModels.Gray {
        rgb().gray
    }
    
    /// The color components in the CMYK color space.
    public func cmyk() -> ColorModels.CMYK {
        rgb().cmyk
    }
    
    /**
     Creates a new color whose component values are a weighted sum of the current color and the specified color.

     - Parameters:
        - fraction: The amount of the color to blend with the current color.
        - color: The color to blend with the current color.
        - colorSpace: The color space in which to blend the colors.

     - Returns: The resulting color.
     */
    @_disfavoredOverload
    public func blended(withFraction fraction: Double, of other: CGColor, using colorSpace: ColorModels.ColorSpace = .srgb) -> CGColor {
        switch colorSpace {
        case .srgb: .init(rgb().blended(withFraction: fraction, of: other.rgb()))
        case .xyz: .init(xyz().blended(withFraction: fraction, of: other.xyz()))
        case .oklab: .init(oklab().blended(withFraction: fraction, of: other.oklab()))
        case .oklch: .init(oklch().blended(withFraction: fraction, of: other.oklch()))
        case .hsl: .init(hsl().blended(withFraction: fraction, of: other.hsl()))
        case .hsb: .init(hsb().blended(withFraction: fraction, of: other.hsb()))
        case .cmyk: .init(cmyk().blended(withFraction: fraction, of: other.cmyk()))
        case .lab: .init(lab().blended(withFraction: fraction, of: other.lab()))
        case .gray: .init(gray().blended(withFraction: fraction, of: other.gray()))
        default: .init(rgb().blended(withFraction: fraction, of: other.rgb()))
        }
    }
}

extension CFType where Self == CGColor {
    /// Creates the color with the specified color components.
    public init(_ colorComponents: some ColorModel) {
        self = colorComponents.cgColor
    }
}

extension Color {
    /// Creates the color with the specified color components.
    public init(_ colorComponents: some ColorModel) {
        #if os(macOS)
        self.init(nsColor: colorComponents.nsColor)
        #else
        self.init(uiColor: colorComponents.uiColor)
        #endif
    }
    
    /// The color components in the sRGB color space.
    public func rgb() -> ColorModels.SRGB {
        nsUIColor.rgb()
    }
    
    /// The color components in the HSB color space.
    public func hsb() -> ColorModels.HSB {
        nsUIColor.hsb()
    }
    
    /// The color components in the HSL color space.
    public func hsl() -> ColorModels.HSL {
        rgb().hsl
    }
    
    /// The color components in the XYZ color space.
    public func xyz() -> ColorModels.XYZ {
        rgb().xyz
    }
    
    /// The color components in the OKLAB color space.
    public func oklab() -> ColorModels.OKLAB {
        rgb().oklab
    }
    
    /// The color components in the OKLCH color space.
    public func oklch() -> ColorModels.OKLCH {
        rgb().oklch
    }
    
    /// The color components in the CIE LAB color space.
    public func lab() -> ColorModels.LAB {
        rgb().lab
    }
    
    /// The color components in the gray color space.
    public func gray() -> ColorModels.Gray {
        rgb().gray
    }
    
    /// The color components in the CMYK color space.
    public func cmyk() -> ColorModels.CMYK {
        rgb().cmyk
    }
    
    /**
     Creates a new color whose component values are a weighted sum of the current color and the specified color.

     - Parameters:
        - fraction: The amount of the color to blend with the current color.
        - color: The color to blend with the current color.
        - colorSpace: The color space in which to blend the colors.

     - Returns: The resulting color.
     */
    public func blended(withFraction fraction: Double, of other: Color, using colorSpace: ColorModels.ColorSpace = .srgb) -> Color {
        #if os(macOS) || os(iOS) || os(tvOS)
        let dynamic = dynamicColors
        let otherDynamic = dynamicColors
        if dynamic.isDynamic || otherDynamic.isDynamic {
            return Color(light: dynamic.light._blended(withFraction: fraction, of: otherDynamic.light, using: colorSpace), dark: dynamic.dark._blended(withFraction: fraction, of: otherDynamic.dark, using: colorSpace))
        }
        #endif
        return _blended(withFraction: fraction, of: other, using: colorSpace)
    }
    
    fileprivate func _blended(withFraction fraction: Double, of other: Color, using colorSpace: ColorModels.ColorSpace = .srgb) -> Color {
        switch colorSpace {
        case .srgb: .init(rgb().blended(withFraction: fraction, of: other.rgb()))
        case .xyz: .init(xyz().blended(withFraction: fraction, of: other.xyz()))
        case .oklab: .init(oklab().blended(withFraction: fraction, of: other.oklab()))
        case .oklch: .init(oklch().blended(withFraction: fraction, of: other.oklch()))
        case .hsl: .init(hsl().blended(withFraction: fraction, of: other.hsl()))
        case .hsb: .init(hsb().blended(withFraction: fraction, of: other.hsb()))
        case .cmyk: .init(cmyk().blended(withFraction: fraction, of: other.cmyk()))
        case .lab: .init(lab().blended(withFraction: fraction, of: other.lab()))
        case .gray: .init(gray().blended(withFraction: fraction, of: other.gray()))
        default: .init(rgb().blended(withFraction: fraction, of: other.rgb()))
        }
    }
}

extension ColorModels {
    /// Standard illuminant D65 reference values for the CIE 1931 color space.
    enum D65 {
        /// X component of the D65 white point.
        public static let Xn = 0.95047
        /// Y component of the D65 white point.
        public static let Yn = 1.00000
        /// Z component of the D65 white point.
        public static let Zn = 1.08883
    }
}

extension ColorModel {
    func interpolateHue(_ from: Double, to: Double, fraction: Double) -> Double {
        var h1 = from.truncatingRemainder(dividingBy: 1.0)
        var h2 = to.truncatingRemainder(dividingBy: 1.0)
        if h1 < 0 { h1 += 1 }
        if h2 < 0 { h2 += 1 }
        var delta = h2 - h1
        if delta > 0.5 {
            delta -= 1.0
        } else if delta < -0.5 {
            delta += 1.0
        }
        return h1 + delta * fraction
    }
}
