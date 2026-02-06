//
//  ColorModel+NSUIColor.swift
//
//
//  Created by Florian Zand on 02.02.26.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif
import SwiftUI

/// `NSColor`, `UIColor`, `CGColor` and SwiftUI `Color`.
public protocol PlatformColor {
    /// The color components in the extened sRGB color space.
    func rgb() -> ColorModels.SRGB
    /// The color components in the Display P3 color space.
    func displayP3() -> ColorModels.DisplayP3
}

extension CGColor: PlatformColor {
    public func rgb() -> ColorModels.SRGB {
        let components = (components(for: [.extendedSRGB, .deviceRGB]) ?? [0, 0, 0, 0]).map(Double.init)
        return .init(components)
    }
    
    public func displayP3() -> ColorModels.DisplayP3 {
        let components = (components(for: [.extendedDisplayP3, .displayP3, .extendedSRGB, .deviceRGB]) ?? [0,0,0.0]).map(Double.init)
        return .init(components)
    }
    
    fileprivate func components(for colorspaces: [CGColorSpaceName]) -> [CGFloat]? {
        colorspaces.lazy.compactMap({ self.components(for: $0) }).first
    }
}

extension NSUIColor: PlatformColor {
    public func rgb() -> ColorModels.SRGB { cgColor.rgb() }
    public func displayP3() -> ColorModels.DisplayP3 { cgColor.displayP3() }
}

extension Color: PlatformColor {
    public func rgb() -> ColorModels.SRGB { nsUIColor.rgb() }
    public func displayP3() -> ColorModels.DisplayP3 { nsUIColor.displayP3() }
}

extension PlatformColor {
    /// The color components in the HSB color space.
    public func hsb() -> ColorModels.HSB { rgb().hsb }
    /// The color components in the HSL color space.
    public func hsl() -> ColorModels.HSL { rgb().hsl }
    /// The color components in the XYZ color space.
    public func xyz() -> ColorModels.XYZ { rgb().xyz }
    /// The color components in the OKLAB color space.
    public func oklab() -> ColorModels.OKLAB { rgb().oklab }
    /// The color components in the OKLCH color space.
    public func oklch() -> ColorModels.OKLCH { rgb().oklch }
    /// The color components in the CIE LAB color space.
    public func lab() -> ColorModels.LAB { rgb().lab }
    /// The color components in the LCH color space.
    public func lch() -> ColorModels.LCH { rgb().lch }
    /// The color components in the generic CMYK color space.
    public func cmyk() -> ColorModels.CMYK { rgb().cmyk }
    /// The color components in the CIE LUV color space.
    public func luv() -> ColorModels.LUV { rgb().luv }
    /// The color components in the HWB color space.
    public func hwb() -> ColorModels.HWB { rgb().hwb }
    /// The color components in the OKHSB color space.
    public func okhsb() -> ColorModels.OKHSB { rgb().okhsb }
    /// The color components in the OKHSL color space.
    public func okhsl() -> ColorModels.OKHSL { rgb().okhsl }
    /// The color components in the HPLUV color space.
    public func hpluv() -> ColorModels.HPLUV { rgb().hpluv }
    /// The color components in the LCHUV color space.
    public func lchuv() -> ColorModels.LCHUV { rgb().lchuv }
    /// The color components in the HSLUV color space.
    public func hsluv() -> ColorModels.HSLUV { rgb().hsluv }
    /// The color components in the JZAZBZ color space.
    public func jzazbz() -> ColorModels.JZAZBZ { xyz().jzazbz }
    /// The color components in the JZCZHZ color space.
    public func jzczhz() -> ColorModels.JZCZHZ { xyz().jzazbz.jzczhz }
    /// The color components in the grayscale color space using the specified grayscaling mode.
    public func gray(mode: ColorModels.GrayscalingMode = .perceptual) -> ColorModels.Grayscale {
        rgb().gray(mode: mode)
    }
    /// Returns an Integer representing the color in hex format (e.g. `0x112233`)
    public var hex: Int { rgb().hex }
    /// Returns a hex string representing the color (e.g. `#112233`)
    public var hexString: String { rgb().hexString }
    /// The relative luminance of the color.
    public var relativeLuminance: Double { rgb().relativeLuminance }
    /**
     Returns the contrast ratio between the two colors.
     
     Th contrast ratio is calculated according to the Web Content Accessibility Guidelines [(WCAG) 2.2](https://www.w3.org/TR/WCAG22/#dfn-contrast-ratio).
     */
    public func contrastRatio(to other: Self) -> CGFloat {
        rgb().contrastRatio(to: other.rgb())
    }
}

extension PlatformColor where Self == CGColor {
    /// Creates the color with the specified color components.
    public init(_ colorModel: any ColorModel) {
        self = colorModel.cgColor
    }
}

extension CGColor {
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
        case .srgb: rgb().mixed(with: other.rgb(), by: fraction).cgColor
        case .xyz: xyz().mixed(with: other.xyz(), by: fraction).cgColor
        case .oklab: oklab().mixed(with: other.oklab(), by: fraction).cgColor
        case .oklch: oklch().mixed(with: other.oklch(), by: fraction).cgColor
        case .hsl: hsl().mixed(with: other.hsl(), by: fraction).cgColor
        case .hsb: hsb().mixed(with: other.hsb(), by: fraction).cgColor
        case .cmyk: cmyk().mixed(with: other.cmyk(), by: fraction).cgColor
        case .lab: lab().mixed(with: other.lab(), by: fraction).cgColor
        case .gray: gray().mixed(with: other.gray(), by: fraction).cgColor
        case .lch: lch().mixed(with: other.lch(), by: fraction).cgColor
        case .luv: luv().mixed(with: other.luv(), by: fraction).cgColor
        case .displayP3: displayP3().mixed(with: other.displayP3(), by: fraction).cgColor
        case .hwb: hwb().mixed(with: other.hwb(), by: fraction).cgColor
        case .okhsb: okhsb().mixed(with: other.okhsb(), by: fraction).cgColor
        case .okhsl: okhsl().mixed(with: other.okhsl(), by: fraction).cgColor
        case .hpluv: hpluv().mixed(with: other.hpluv(), by: fraction).cgColor
        case .lchuv: lchuv().mixed(with: other.lchuv(), by: fraction).cgColor
        case .hsluv: hsluv().mixed(with: other.hsluv(), by: fraction).cgColor
        case .jzazbz: jzazbz().mixed(with: other.jzazbz(), by: fraction).cgColor
        case .jzczhz: jzczhz().mixed(with: other.jzczhz(), by: fraction).cgColor
        }
    }
}

extension NSUIColor {
    /// Creates the color with the specified color components.
    public convenience init(_ colorModel: any ColorModel) {
        #if os(macOS)
        self.init(cgColor: colorModel.cgColor)!
        #else
        self.init(cgColor: colorModel.cgColor)
        #endif
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
            return NSUIColor(light: dynamic.light.cgColor.mixed(with: otherDynamic.light.cgColor, by: fraction, in: colorSpace).nsUIColor!, dark: dynamic.dark.cgColor.mixed(with: otherDynamic.dark.cgColor, by: fraction, in: colorSpace).nsUIColor!)
        }
        #endif
        return cgColor.mixed(with: other.cgColor, by: fraction, in: colorSpace).nsUIColor!
    }
}

extension Color {
    /// Creates the color with the specified color components.
    public init(_ colorModel: any ColorModel) {
        self.init(cgColor: colorModel.cgColor)
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
