//
//  ColorModel+HSL.swift
//  
//
//  Created by Florian Zand on 14.12.25.
//

import Foundation
import CoreGraphics
import FZSwiftUtils

extension ColorComponents {
    /// The color components for a color in the HSL color space.
    public struct HSL: _ColorModel {
        /// The hue component of the color.
        public var hue: Double
        /// The saturation component of the color.
        public var saturation: Double
        /// The lightness component of the color.
        public var lightness: Double
        /// The alpha value of the color.
        public var alpha: Double {
            didSet { alpha = alpha.clamped(to: 0...1) }
        }
        
        public var description: String {
            "HSL(hue: \(hue), saturation: \(saturation), lightness: \(lightness), alpha: \(alpha))"
        }
        
        public var components: [Double] { [hue, saturation, lightness, alpha] }
        
        public func blended(withFraction fraction: Double, of other: HSL) -> HSL {
            let blendedHue = interpolateHue(hue, to: other.hue, fraction: fraction)
            return HSL(hue: blendedHue, saturation: saturation + (other.saturation - saturation) * fraction, lightness: lightness + (other.lightness - lightness) * fraction, alpha: alpha + (other.alpha - alpha) * fraction)
        }
        
        /// The color in the sRGB color space.
        public var rgb: SRGB {
            hsb.rgb
        }
        
        /// The color in the OKLAB color space.
        public var oklab: OKLAB {
            rgb.oklab
        }
        
        /// The color in the OKLCH color space.
        public var oklch: OKLCH {
            rgb.oklch
        }
        
        /// The color in the CMYK color space.
        public var cmyk: CMYK {
            rgb.cmyk
        }
        
        /// The color in the the CIE Lab color space.
        public var lab: LAB {
            rgb.lab
        }
        
        /// The color in the HSB color space.
        public var hsb: HSB {
            let l = lightness
            let s_hsl = saturation
            let v = l + s_hsl * min(l, max(0, 1 - l))
            let s_hsv: Double
            if v == 0 {
                s_hsv = 0
            } else {
                s_hsv = 2 * (1 - l / v)
            }
            return HSB(hue: wrapUnit(hue), saturation: s_hsv, brightness: v, alpha: alpha)
        }
        
        /// The color in the the XYZ color space.
        public var xyz: XYZ {
            rgb.xyz
        }
        
        /// The color in the grayscale color space.
        public var gray: Gray {
            rgb.gray
        }
        
        /// Creates the color with the specified components.
        public init(hue: Double, saturation: Double, lightness: Double, alpha: Double = 1.0) {
            self.hue = hue
            self.saturation = saturation
            self.lightness = lightness
            self.alpha = alpha
        }
        
        public init(_ components: [Double]) {
            precondition(components.count >= 3, "You need to provide at least 3 components for a color in HSL color space.")
            self.init(hue: components[0], saturation: components[1], lightness: components[2], alpha: components[safe: 3] ?? 0.0)
        }
        
        @inline(__always)
        private func wrapUnit(_ x: Double) -> Double {
            let r = x.truncatingRemainder(dividingBy: 1)
            return r < 0 ? r + 1 : r
        }
        
        var _components: [Double] { rgb.components }
        public static let colorSpace = SRGB.colorSpace
    }
}

public extension ColorModel where Self == ColorComponents.HSL {
    /// Returns the color components for a color in the HSL color space.
    static func hsl(_ components: [Double]) -> Self {
        .init(components)
    }
    
    /// Returns the color components for a color in the HSL color space.
    static func hsl(hue: Double, saturation: Double, lightness: Double, alpha: Double = 1.0) -> Self {
        .init(hue: hue, saturation: saturation, lightness: lightness, alpha: alpha)
    }
}
