//
//  ColorModel+SRGB.swift
//  
//
//  Created by Florian Zand on 14.12.25.
//

import Foundation
import CoreGraphics
import FZSwiftUtils
import simd

extension ColorModels {
    /// The color components for a color in the sRGB color space.
    public struct SRGB: ColorModel {
        public var animatableData: SIMD4<Double>
        
        /// The red component of the color.
        public var red: Double {
            get { animatableData.x }
            set { animatableData.x = newValue }
        }
        
        /// The green component of the color.
        public var green: Double {
            get { animatableData.y }
            set { animatableData.y = newValue }
        }
        
        /// The blue component of the color.
        public var blue: Double {
            get { animatableData.z }
            set { animatableData.z = newValue }
        }
        
        /// The alpha value of the color.
        public var alpha: Double {
            get { animatableData.w }
            set { animatableData.w = newValue.clamped(to: 0...1) }
        }
                
        /// The linear red component of the color.
        public var linearRed: Double {
            get { Self.toLinear(red) }
            set { red = Self.toNonlinear(newValue) }
        }
        
        /// The linear green component of the color.
        public var linearGreen: Double {
            get { Self.toLinear(green) }
            set { green = Self.toNonlinear(newValue) }
        }
        
        /// The linear blue component of the color.
        public var linearBlue: Double {
            get { Self.toLinear(blue) }
            set { blue = Self.toNonlinear(newValue) }
        }
        
        /// The relative luminance of the color.
        public var relativeLuminance: Double {
            let res = animatableData * Self.toRelativeLuminance
            return res[0] + res[1] + res[2]
        }
        
        private static let toRelativeLuminance = SIMD4(0.2126729, 0.7151522, 0.0721750, 0.0)

        /**
         Returns the contrast ratio between the two colors.
         
         Th contrast ratio is calculated according to the Web Content Accessibility Guidelines [(WCAG) 2.2](https://www.w3.org/TR/WCAG22/#dfn-contrast-ratio).
         */
         public func contrastRatio(to other: Self) -> CGFloat {
             let luminance1 = relativeLuminance
             let luminance2 = other.relativeLuminance
             return (max(luminance1, luminance2) + 0.05) / (min(luminance1, luminance2) + 0.05)
         }
        
        /// A Boolean value indicating whether the color is light.
        public var isLight: Bool {
             relativeLuminance >= 0.5
        }
        
        public var components: [Double] {
            get { [red, green, blue, alpha] }
            set {
                red = newValue[safe: 0] ?? red
                green = newValue[safe: 1] ?? green
                blue = newValue[safe: 2] ?? blue
                alpha = newValue[safe: 3] ?? alpha
            }
        }
        
        public var description: String {
            "SRGB(red: \(red), green: \(green), blue: \(blue), alpha: \(alpha))"
        }
        
        private static let toLMS: simd_double3x3 = .init(
            SIMD3(0.4122214708, 0.5363325363, 0.0514459929),
            SIMD3(0.2119034982, 0.6806995451, 0.1073969566),
            SIMD3(0.0883024619, 0.2817188376, 0.6299787005))

        private static let toOKLAB: simd_double3x3 = .init(
            SIMD3( 0.2104542553,  0.7936177850, -0.0040720468),
            SIMD3( 1.9779984951, -2.4285922050,  0.4505937099),
            SIMD3( 0.0259040371,  0.7827717662, -0.8086757660))
        
        public var oklab: OKLAB {
            let rgb = SIMD3(linearRed, linearGreen, linearBlue)
            var lms = Self.toLMS * rgb
            lms = SIMD3(cbrt(lms.x), cbrt(lms.y), cbrt(lms.z))
            let oklab = Self.toOKLAB * lms
            return OKLAB(lightness: oklab.x, greenRed: oklab.y, blueYellow: oklab.z, alpha: alpha)
        }
        
        /// The color in the HSB color space.
        public var hsb: HSB {
            let hsb = Self.toHSX(animatableData, isHSL: false)
            return .init(hue: hsb.hue, saturation: hsb.saturation, brightness: hsb.brightness, alpha: hsb.alpha)
        }
        
        /// The color in the HSL color space.
        public var hsl: HSL {
            let hsl = Self.toHSX(animatableData, isHSL: true)
            return .init(hue: hsl.hue, saturation: hsl.saturation, lightness: hsl.brightness, alpha: hsl.alpha)
        }
        
        /// The color in the generic CMYK color space.
        public var cmyk: CMYK {
            let clamped = clamped
            let black = 1.0 - max(clamped.red, max(clamped.green, clamped.blue))
            if black >= 1.0 - 1e-6 {
                return CMYK(cyan: 0.0, magenta: 0.0, yellow: 0.0, black: black, alpha: alpha)
            }
            let inv = 1.0 - black
            let cyan = (1.0 - clamped.red - black) / inv
            let magenta = (1.0 - clamped.green - black) / inv
            let yellow = (1.0 - clamped.blue - black) / inv
            return .init(cyan: cyan, magenta: magenta, yellow: yellow, black: black, alpha: alpha)
        }
        
        /// The color in the sRGB color space.
        public var rgb: SRGB { self }
        
        /// The color in the XYZ color space.
        public var xyz: XYZ {
            let linearRGB = SIMD3(linearRed, linearGreen, linearBlue)
            let xyz = Self.toXYZ * linearRGB
            return .init(x: xyz.x, y: xyz.y, z: xyz.z, alpha: alpha)
        }
        
        private static let toXYZ: simd_double3x3 = .init(
            SIMD3<Double>(0.4124564, 0.3575761, 0.1804375),
            SIMD3<Double>(0.2126729, 0.7151522, 0.0721750),
            SIMD3<Double>(0.0193339, 0.1191920, 0.9503041))
        
        /// The color in the grayscale color space.
        public var gray: Grayscale {
            gray(mode: .perceptual)
        }
        
        /// The color in the grayscale color space using the specified grayscaling mode.
        public func gray(mode: GrayscalingMode) -> Grayscale {
            switch mode {
            case .luminance:
                let luminance = SIMD3(linearRed, linearGreen, linearBlue).dot(Self.toXYZ[2])
                return Grayscale(white: luminance, alpha: alpha)
            case .lightness:
                return Grayscale(white: hsl.lightness, alpha: alpha)
            case .average:
                return Grayscale(white: (red + green + blue) / 3.0, alpha: alpha)
            case .value:
                return Grayscale(white: hsb.brightness, alpha: alpha)
            case .perceptual:
                return Grayscale(white: Self.toNonlinear(relativeLuminance), alpha: alpha)
            }
        }
        
        /// The color inverted.
        public var inverted: SRGB {
            Self(red: 1.0 - red, green: 1.0 - green, blue: 1.0 - blue, alpha: alpha)
        }
        
        public var cgColor: CGColor {
            CGColor(colorSpace: .extendedSRGB, components:  components.map({CGFloat($0)}))!
        }
        
        /// Returns an Integer representing the color in hex format (e.g. `0x112233`)
        public var hex: Int {
            if alpha == 1.0 {
                return Int(UInt32(lround(red * 255)) << 16 | UInt32(lround(green * 255)) << 8 | UInt32(lround(blue * 255)))
            } else {
                return Int(UInt32(lround(red * 255)) << 24 | UInt32(lround(green * 255)) << 16 | UInt32(lround(blue * 255)) << 8 | UInt32(lround(alpha * 255)))
            }
        }

        /// Returns a hex string representing the color (e.g. `#112233`)
        public var hexString: String {
            if alpha == 1.0 {
                return String(format: "#%06X", UInt32(lround(red * 255)) << 16 | UInt32(lround(green * 255)) << 8 | UInt32(lround(blue * 255)))
            } else {
                return String(format: "#%08X", UInt32(lround(red * 255)) << 24 | UInt32(lround(green * 255)) << 16 | UInt32(lround(blue * 255)) << 8 | UInt32(lround(alpha * 255)))
            }
        }
        
        /// Creates the color with the specified components.
        public init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
            animatableData = .init(red, green, blue, alpha)
        }
        
        /// Creates the color with the specified linear components.
        public init(linearRed red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
            self.init(red: Self.toNonlinear(red), green: Self.toNonlinear(green), blue: Self.toNonlinear(blue), alpha: alpha)
        }
        
        public init(_ components: [Double]) {
            precondition(components.count >= 3, "You need to provide at least 3 components for a color in SRGB color space.")
            self.init(red: components[0], green: components[1], blue: components[2], alpha: components[safe: 3] ?? 1.0)
        }
        
        /// Creates the color from a hex string (e.g. `#1D2E3F`) and an optional alpha value.
        public init?(hex: String, alpha: CGFloat = 1.0) {
            let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().removingPrefix("#").removingPrefix("0x")
            guard let hexValue = UInt64(hex, radix: 16) else { return nil }
            switch hex.count {
            case 3: self.init(red: CGFloat((hexValue & 0xF00) >> 8) / 15.0, green: CGFloat((hexValue & 0x0F0) >> 4) / 15.0, blue: CGFloat(hexValue & 0x00F) / 15.0)
            case 4: self.init(red: CGFloat((hexValue & 0xF000) >> 12) / 15.0, green: CGFloat((hexValue & 0x0F00) >> 8) / 15.0, blue: CGFloat((hexValue & 0x00F0) >> 4) / 15.0, alpha: CGFloat(hexValue & 0x000F) / 15.0)
            case 6: self.init(red: CGFloat((hexValue & 0xFF0000) >> 16) / 255.0, green: CGFloat((hexValue & 0x00FF00) >> 8) / 255.0, blue: CGFloat(hexValue & 0x0000FF) / 255.0)
            case 8: self.init(red: CGFloat((hexValue & 0xFF000000) >> 24) / 255.0, green: CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0, blue: CGFloat((hexValue & 0x0000FF00) >> 8) / 255.0, alpha: CGFloat(hexValue & 0x000000FF) / 255.0)
            default: return nil
            }
        }
        
        /// Creates the color from a hex string (e.g. `#1D2E3F`) and an optional alpha value.
        public init(hex: Int, alpha: CGFloat = 1.0) {
            self.init(red: CGFloat((hex & 0xFF0000) >> 16) / 255.0, green: CGFloat((hex & 0x00FF00) >> 8) / 255.0, blue: CGFloat(hex & 0x0000FF) / 255.0, alpha: alpha)
        }
    }
}

extension ColorModels.SRGB {
    fileprivate static let invGamma = 1.0 / 2.4
    
    @inline(__always)
    static func toLinear(_ c: Double) -> Double {
        let absC = abs(c)
        let res = absC <= 0.04045
        ? absC / 12.92
        : pow((absC + 0.055) / 1.055, 2.4)
        return c < 0 ? -res : res
    }
    
    @inline(__always)
    static func toNonlinear(_ c: Double) -> Double {
        let absC = abs(c)
        let res = absC <= 0.0031308
        ? 12.92 * absC
        : 1.055 * pow(absC, invGamma) - 0.055
        return c < 0 ? -res : res
    }
    
    static func toHSX(_ storage: SIMD4<Double>, isHSL: Bool = true) -> (hue: Double, saturation: Double, brightness: Double, alpha: Double) {
        let (hue, delta, maxV, minV) = hueChromaMaxMin(red: storage.x, green: storage.y, blue: storage.z)
        if isHSL {
            let lightness = (maxV + minV) / 2
            let saturation = lightness > 0 && lightness < 1 ? delta / (1 - abs(2 * lightness - 1)) : 0
            return (hue, saturation, lightness, storage.w)
        }
        return (hue, maxV != 0 ? delta / maxV : 0, maxV, storage.w)
    }
    
    fileprivate static func hueChromaMaxMin(red: Double, green: Double, blue: Double) -> (hue: Double, delta: Double, maxV: Double, minV: Double) {
        let maxV = max(red, green, blue)
        let minV = min(red, green, blue)
        let delta = maxV - minV
        var hue: Double = 0
        if delta > 0 {
            hue = (maxV == red ? (green - blue) / delta
                   : maxV == green ? (blue - red) / delta + 2
                   : (red - green) / delta + 4) / 6
            if hue < 0 { hue += 1 }
        }
        return (hue, delta, maxV, minV)
    }
}

public extension ColorModel where Self == ColorModels.SRGB {
    /// Returns the color components for a color in the sRGB color space.
    static func rgb(_ components: [Double]) -> Self {
        .init(components)
    }
    
    /// Returns the color components for a color in the sRGB color space.
    static func rgb(red: Double, green: Double, blue: Double, alpha: Double = 1.0) -> Self {
        .init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /// Returns the color components for a color in the sRGB color space.
    static func rgb(linearRed red: Double, green: Double, blue: Double, alpha: Double = 1.0) -> Self {
        .init(linearRed: red, green: green, blue: blue, alpha: alpha)
    }
}
