//
//  ColorModel+OKLCH.swift
//  
//
//  Created by Florian Zand on 14.12.25.
//

import Foundation
import CoreGraphics

extension ColorModels {
    /// The color components for a color in the OKLCH color space.
    public struct OKLCH: ColorModel {
        /// The lightness component of the color.
        public var lightness: Double
        /// The chroma component of the color.
        public var chroma: Double
        /// The hue component of the color.
        public var hue: Double
        /// The alpha value of the color.
        public var alpha: Double {
            didSet { alpha = alpha.clamped(to: 0...1) }
        }
        
        public func mixed(with other: Self, by fraction: Double) -> Self {
            OKLCH(lightness: lightness + (other.lightness - lightness) * fraction, chroma: chroma + (other.chroma - chroma) * fraction, hue: interpolateHue(hue, to: other.hue, fraction: fraction), alpha: alpha + (other.alpha - alpha) * fraction)
        }
        
        public var description: String {
            "OKLCH(lightness: \(lightness), chroma: \(chroma), hue: \(hue), alpha: \(alpha))"
        }
        
        public var components: [Double] {
            get { [lightness, chroma, hue, alpha] }
            set {
                lightness = newValue[safe: 0] ?? lightness
                chroma = newValue[safe: 1] ?? chroma
                hue = newValue[safe: 2] ?? hue
                alpha = newValue[safe: 3] ?? alpha
            }
        }
        
        /// The color in the OKLAB color space.
        public var oklab: OKLAB {
            let hRad = hue * 2.0 * Double.pi
            let greenRed = chroma * cos(hRad)
            let blueYellow = chroma * sin(hRad)
            return OKLAB(lightness: lightness, greenRed: greenRed, blueYellow: blueYellow, alpha: alpha)
        }
        
        /// The color in the sRGB color space.
        public var rgb: SRGB {
            oklab.rgb
        }
        
        /// The color in the HSB color space.
        public var hsb: HSB {
            rgb.hsb
        }
        
        /// The color in the HSL color space.
        public var hsl: HSL {
            rgb.hsl
        }
        
        /// The color in the CMYK color space.
        public var cmyk: CMYK {
            rgb.cmyk
        }
        
        /// The color in the the XYZ color space.
        public var xyz: XYZ {
            rgb.xyz
        }
        
        /// The color in the the CIE Lab color space.
        public var lab: LAB {
            rgb.lab
        }
        
        /// The color in the grayscale color space.
        public var gray: Gray {
            rgb.gray
        }
        
        /// Creates the color with the specified components.
        public init(lightness: Double, chroma: Double, hue: Double, alpha: Double = 1.0) {
            self.lightness = lightness
            self.chroma = chroma
            self.hue = hue
            self.alpha = alpha
        }
        
        public init(_ components: [Double]) {
            precondition(components.count >= 3, "You need to provide at least 3 components for a color in OKLCH color space.")
            self.init(lightness: components[0], chroma: components[1], hue: components[2], alpha: components[safe: 3] ?? 0.0)
        }
        
        public var cgColor: CGColor {
            rgb.cgColor
        }
        
        /// Returns an Integer representing the color in hex format (e.g. `0x112233`)
        public var hex: Int {
            rgb.hex
        }
        
        /// Returns a hex string representing the color (e.g. `#112233`)
        public var hexString: String {
            rgb.hexString
        }
    }
}

public extension ColorModel where Self == ColorModels.OKLCH {
    /// Returns the color components for a color in the OKLCH color space.
    static func oklch(_ components: [Double]) -> Self {
        .init(components)
    }
    
    /// Returns the color components for a color in the OKLCH color space.
    static func oklch(lightness: Double, chroma: Double, hue: Double, alpha: Double = 1.0) -> Self {
        .init(lightness: lightness, chroma: chroma, hue: hue, alpha: alpha)
    }
}
