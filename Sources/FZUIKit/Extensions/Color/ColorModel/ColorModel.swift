//
//  ColorModel.swift
//
//
//  Created by Florian Zand on 13.12.25.
//

import Foundation
import FZSwiftUtils
import SwiftUI

#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// A representation of a color in a specific color space.
public protocol ColorModel: CustomStringConvertible, Hashable, Codable, ApproximateEquatable, Sendable, ExpressibleByArrayLiteral, Animatable {
    /// Creates the color with the specified color components.
    init(_ components: [Double])
    /// The components of the color.
    var components: [Double] { get set }
    /// The alpha value of the color.
    var alpha: Double { get set }
    /// The color in the sRGB color space.
    var rgb: ColorModels.SRGB { get }
    /// The color in the XYZ color space.
    var xyz: ColorModels.XYZ { get }
    /// `CGColor` representation of the color.
    var cgColor: CGColor { get }
}

public extension ColorModel {
    init(arrayLiteral elements: Double...) {
        self.init(elements)
    }
    
    /// Creates a new color by blending the color with the specified other color.
    func mixed(with other: Self, by fraction: Double) -> Self {
        var color = self
        color.animatableData.interpolate(towards: other.animatableData, amount: fraction)
        return color
    }
    
    /// Blends the color with the specified other color.
    mutating func mix(with other: Self, by fraction: Double) {
        animatableData.interpolate(towards: other.animatableData, amount: fraction)
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
    
    /**
     Returns the color in a standard-range by clamping each color component to the range `0...1`.

     This operation **does not perform tone mapping or gamut mapping**. Any component values outside the displayable range are simply clipped.

     Use this property when you need a color that is guaranteed to be valid for display, serialization, or conversion to other non-extended color spaces.

     If you need to preserve relative luminance or appearance when converting from extended-range colors (for example HDR → SDR), use a tone-mapping operation instead.
     */
    var clamped: Self {
        .init(components.clamped(to: 0.0...1.0))
    }
    
    var cgColor: CGColor {
        rgb.cgColor
    }
    
    /// SwiftUI `Color` representation of the color.
    var swiftUI: Color {
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
}

extension ColorModel {
    /// The color in the sRGB color space.
    public var rgb: ColorModels.SRGB { xyz.rgb }
    /// The color in the XYZ color space.
    public var xyz: ColorModels.XYZ { rgb.xyz }
    
    /// The color in the HSB color space.
    public var hsb: ColorModels.HSB { rgb.hsb }
    /// The color in the HSL color space.
    public var hsl: ColorModels.HSL { rgb.hsl }
    /// The color in the HWB color space.
    public var hwb: ColorModels.HWB { hsb.hwb }
    
    /// The color in the OKLAB color space.
    public var oklab: ColorModels.OKLAB { rgb.oklab }
    /// The color in the OKLCH color space.
    public var oklch: ColorModels.OKLCH { oklab.oklch }
    /// The color in the OKHSB color space.
    public var okhsb: ColorModels.OKHSB { oklab.okhsb }
    /// The color in the OKHSL color space.
    public var okhsl: ColorModels.OKHSL { oklab.okhsl }
    
    /// The color in the LUV color space.
    public var luv: ColorModels.LUV { xyz.luv }
    /// The color in the LCHUV color space.
    public var lchuv: ColorModels.LCHUV { luv.lchuv }
    /// The color in the HSLUV color space.
    public var hsluv: ColorModels.HSLUV { lchuv.hsluv }
    /// The color in the HPLUV color space.
    public var hpluv: ColorModels.HPLUV { lchuv.hpluv }
    
    /// The color in the LAB color space.
    public var lab: ColorModels.LAB { xyz.lab }
    /// The color in the LCH color space.
    public var lch: ColorModels.LCH { lab.lch }
    
    /// The color in the JZAZBZ color space.
    public var jzazbz: ColorModels.JZAZBZ { xyz.jzazbz }
    /// The color in the JZCZHZ color space.
    public var jzczhz: ColorModels.JZCZHZ { jzazbz.jzczhz }
    
    /// The color in the generic CMYK color space.
    public var cmyk: ColorModels.CMYK { rgb.cmyk }
    /// The color in the Display P3 color space.
    public var displayP3: ColorModels.DisplayP3 { xyz.displayP3 }
    
    /// The color in the grayscale color space.
    public var gray: ColorModels.Grayscale { rgb.gray }
    /// The color in the grayscale color space using the specified grayscaling mode.
    public func gray(mode: ColorModels.GrayscalingMode) -> ColorModels.Grayscale {
        switch mode {
        case .luminance: return .init(white: xyz.y, alpha: alpha)
        case .lightness: return .init(white: hsl.lightness, alpha: alpha)
        case .value: return .init(white: hsb.brightness, alpha: alpha)
        case .perceptual: return rgb.gray(mode: .perceptual)
        case .average:
            let rgb = rgb
            return .init(white: (rgb.red + rgb.green + rgb.blue) / 3.0, alpha: alpha)
        }
    }
    
    /// The relative luminance of the color.
    public var relativeLuminance: Double { rgb.relativeLuminance }
    
    /**
     Returns the contrast ratio between the two colors.
     
     Th contrast ratio is calculated according to the Web Content Accessibility Guidelines [(WCAG) 2.2](https://www.w3.org/TR/WCAG22/#dfn-contrast-ratio).
     */
    public func contrastRatio(to other: Self) -> CGFloat {
        rgb.contrastRatio(to: other.rgb)
    }
    
    /// Returns an Integer representing the color in hex format (e.g. `0x112233`)
    public var hex: Int { rgb.hex }
    
    /// Returns a hex string representing the color (e.g. `#112233`)
    public var hexString: String { rgb.hexString }
}

/// Representations of a color in a specific color space.
public enum ColorModels { }

extension NSUIColor {
    /// Creates the color with the specified color components.
    public convenience init(_ colorModel: any ColorModel) {
        #if os(macOS)
        self.init(cgColor: colorModel.cgColor)!
        #else
        self.init(cgColor: colorModel.cgColor)
        #endif
    }
    
    /// The color components in the extended sRGB color space.
    public func rgb() -> ColorModels.SRGB {
        cgColor.rgb()
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
    
    /// The color components in the LCH color space.
    public func lch() -> ColorModels.LCH {
        rgb().lch
    }
    
    /// The color components in the generic CMYK color space.
    public func cmyk() -> ColorModels.CMYK {
        rgb().cmyk
    }
    
    /// The color components in the CIE LUV color space.
    public func luv() -> ColorModels.LUV {
        rgb().luv
    }
    
    /// The color components in the Display P3 color space.
    public func displayP3() -> ColorModels.DisplayP3 {
        cgColor.displayP3()
    }
    
    /// The color components in the HWB color space.
    public func hwb() -> ColorModels.HWB {
        rgb().hwb
    }
    
    /// The color components in the OKHSB color space.
    public func okhsb() -> ColorModels.OKHSB {
        rgb().okhsb
    }
    
    /// The color components in the OKHSL color space.
    public func okhsl() -> ColorModels.OKHSL {
        rgb().okhsl
    }
    
    /// The color components in the HPLUV color space.
    public func hpluv() -> ColorModels.HPLUV {
        rgb().hpluv
    }
    
    /// The color components in the LCHUV color space.
    public func lchuv() -> ColorModels.LCHUV {
        rgb().lchuv
    }
    
    /// The color components in the HSLUV color space.
    public func hsluv() -> ColorModels.HSLUV {
        rgb().hsluv
    }
    
    /// The color components in the JZAZBZ color space.
    public func jzazbz() -> ColorModels.JZAZBZ {
        xyz().jzazbz
    }
    
    /// The color components in the JZCZHZ color space.
    public func jzczhz() -> ColorModels.JZCZHZ {
        xyz().jzazbz.jzczhz
    }
    
    /// The color components in the grayscale color space using the specified grayscaling mode.
    public func gray(mode: ColorModels.GrayscalingMode = .perceptual) -> ColorModels.Grayscale {
        rgb().gray(mode: mode)
    }
    
    /**
     Creates a new color whose component values are a weighted sum of the current color and the specified color.
     
     - Parameters:
        - other: The color to blend with the current color.
        - fraction: The amount of the color to blend with the current color.
        - colorSpace: The color space in which to blend the colors.
     
     - Returns: The resulting color.
     */
    public func mixed(with other: NSUIColor, by fraction: Double, in colorSpace: ColorModels.ColorSpace = .srgb) -> NSUIColor {
        #if os(macOS) || os(iOS) || os(tvOS)
        let dynamic = dynamicColors
        let otherDynamic = other.dynamicColors
        if dynamic.isDynamic || otherDynamic.isDynamic {
            return NSUIColor(light: dynamic.light._mixed(with: otherDynamic.light, by: fraction, in: colorSpace), dark: dynamic.dark._mixed(with: otherDynamic.dark, by: fraction, in: colorSpace))
        }
        #endif
        return _mixed(with: other, by: fraction, in: colorSpace)
    }
    
    fileprivate func _mixed(with other: NSUIColor, by fraction: Double, in colorSpace: ColorModels.ColorSpace = .srgb) -> NSUIColor {
        cgColor.mixed(with: other.cgColor, by: fraction, in: colorSpace).nsUIColor!
    }
}

extension CFType where Self == CGColor {
    /// Creates the color with the specified color components.
    public init(_ colorModel: any ColorModel) {
        self = colorModel.cgColor
    }
}

extension CGColor {
    /// The color components in the extened sRGB color space.
    public func rgb() -> ColorModels.SRGB {
        let space = CGColorSpace(name: .extendedSRGB) ?? .deviceRGB
        let components = ((colorSpace == space ? self : converted(to: space))?.components ?? [0,0,0.0]).map(Double.init)
        return .init(components)
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
    
    /// The color components in the generic CMYK color space.
    public func cmyk() -> ColorModels.CMYK {
        rgb().cmyk
    }
    
    /// The color components in the CIE LCH color space.
    public func lch() -> ColorModels.LCH {
        rgb().lch
    }
    
    /// The color components in the CIE LUV color space.
    public func luv() -> ColorModels.LUV {
        rgb().luv
    }
    
    /// The color components in the Display P3 color space.
    public func displayP3() -> ColorModels.DisplayP3 {
        let space = CGColorSpace(name: .extendedDisplayP3) ?? CGColorSpace(name: .displayP3)!
        let components = ((colorSpace == space ? self : converted(to: space))?.components ?? [0,0,0.0]).map(Double.init)
        return .init(components)
    }
    
    /// The color components in the HWB color space.
    public func hwb() -> ColorModels.HWB {
        rgb().hwb
    }
    
    /// The color components in the OKHSB color space.
    public func okhsb() -> ColorModels.OKHSB {
        rgb().okhsb
    }
    
    /// The color components in the OKHSL color space.
    public func okhsl() -> ColorModels.OKHSL {
        rgb().okhsl
    }
    
    /// The color components in the HPLUV color space.
    public func hpluv() -> ColorModels.HPLUV {
        rgb().hpluv
    }
    
    /// The color components in the LCHUV color space.
    public func lchuv() -> ColorModels.LCHUV {
        rgb().lchuv
    }
    
    /// The color components in the HSLUV color space.
    public func hsluv() -> ColorModels.HSLUV {
        rgb().hsluv
    }
    
    /// The color components in the JZAZBZ color space.
    public func jzazbz() -> ColorModels.JZAZBZ {
        xyz().jzazbz
    }
    
    /// The color components in the JZCZHZ color space.
    public func jzczhz() -> ColorModels.JZCZHZ {
        xyz().jzazbz.jzczhz
    }
    
    /// The color components in the grayscale color space using the specified grayscaling mode.
    public func gray(mode: ColorModels.GrayscalingMode = .perceptual) -> ColorModels.Grayscale {
        rgb().gray(mode: mode)
    }
    
    /**
     Creates a new color whose component values are a weighted sum of the current color and the specified color.

     - Parameters:
        - fraction: The amount of the color to blend with the current color.
        - other: The color to blend with the current color.
        - colorSpace: The color space in which to blend the colors.

     - Returns: The resulting color.
     */
    public func mixed(with other: CGColor, by fraction: Double, in colorSpace: ColorModels.ColorSpace = .srgb) -> CGColor {
        switch colorSpace {
        case .srgb: .init(rgb().mixed(with: other.rgb(), by: fraction))
        case .xyz: .init(xyz().mixed(with: other.xyz(), by: fraction))
        case .oklab: .init(oklab().mixed(with: other.oklab(), by: fraction))
        case .oklch: .init(oklch().mixed(with: other.oklch(), by: fraction))
        case .hsl: .init(hsl().mixed(with: other.hsl(), by: fraction))
        case .hsb: .init(hsb().mixed(with: other.hsb(), by: fraction))
        case .cmyk: .init(cmyk().mixed(with: other.cmyk(), by: fraction))
        case .lab: .init(lab().mixed(with: other.lab(), by: fraction))
        case .gray: .init(gray().mixed(with: other.gray(), by: fraction))
        case .lch: .init(lch().mixed(with: other.lch(), by: fraction))
        case .luv: .init(luv().mixed(with: other.luv(), by: fraction))
        case .displayP3: .init(displayP3().mixed(with: other.displayP3(), by: fraction))
        case .hwb: .init(hwb().mixed(with: other.hwb(), by: fraction))
        case .okhsb: .init(okhsb().mixed(with: other.okhsb(), by: fraction))
        case .okhsl: .init(okhsl().mixed(with: other.okhsl(), by: fraction))
        case .hpluv: .init(hpluv().mixed(with: other.hpluv(), by: fraction))
        case .lchuv: .init(lchuv().mixed(with: other.lchuv(), by: fraction))
        case .hsluv: .init(hsluv().mixed(with: other.hsluv(), by: fraction))
        case .jzazbz: .init(jzazbz().mixed(with: other.jzazbz(), by: fraction))
        case .jzczhz: .init(jzczhz().mixed(with: other.jzczhz(), by: fraction))
        }
    }
}

extension Color {
    /// Creates the color with the specified color components.
    public init(_ colorModel: any ColorModel) {
        self.init(cgColor: colorModel.cgColor)
    }
    
    /// The color components in the extended sRGB color space.
    public func rgb() -> ColorModels.SRGB {
        nsUIColor.rgb()
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
    
    /// The color components in the LCH color space.
    public func lch() -> ColorModels.LCH {
        rgb().lch
    }
    
    /// The color components in the generic CMYK color space.
    public func cmyk() -> ColorModels.CMYK {
        rgb().cmyk
    }
    
    /// The color components in the CIE LUV color space.
    public func luv() -> ColorModels.LUV {
        rgb().luv
    }
    
    /// The color components in the Display P3 color space.
    public func displayP3() -> ColorModels.DisplayP3 {
        nsUIColor.displayP3()
    }
    
    /// The color components in the HWB color space.
    public func hwb() -> ColorModels.HWB {
        rgb().hwb
    }
    
    /// The color components in the OKHSB color space.
    public func okhsb() -> ColorModels.OKHSB {
        rgb().okhsb
    }
    
    /// The color components in the OKHSL color space.
    public func okhsl() -> ColorModels.OKHSL {
        rgb().okhsl
    }
    
    /// The color components in the HPLUV color space.
    public func hpluv() -> ColorModels.HPLUV {
        rgb().hpluv
    }
    
    /// The color components in the LCHUV color space.
    public func lchuv() -> ColorModels.LCHUV {
        rgb().lchuv
    }
    
    /// The color components in the HSLUV color space.
    public func hsluv() -> ColorModels.HSLUV {
        rgb().hsluv
    }
    
    /// The color components in the JZAZBZ color space.
    public func jzazbz() -> ColorModels.JZAZBZ {
        xyz().jzazbz
    }
    
    /// The color components in the JZCZHZ color space.
    public func jzczhz() -> ColorModels.JZCZHZ {
        xyz().jzazbz.jzczhz
    }
    
    /// The color components in the grayscale color space using the specified grayscaling mode.
    public func gray(mode: ColorModels.GrayscalingMode = .perceptual) -> ColorModels.Grayscale {
        rgb().gray(mode: mode)
    }
    
    /**
     Creates a new color whose component values are a weighted sum of the current color and the specified color.
     
     - Parameters:
        - other: The color to blend with the current color.
        - fraction: The amount of the color to blend with the current color.
        - colorSpace: The color space in which to blend the colors.
     
     - Returns: The resulting color.
     */
    @_disfavoredOverload
    public func mix(with other: Color, by fraction: Double, in colorSpace: ColorModels.ColorSpace = .srgb) -> Color {
        nsUIColor.mixed(with: other.nsUIColor, by: fraction, in: colorSpace).swiftUI
    }
}
