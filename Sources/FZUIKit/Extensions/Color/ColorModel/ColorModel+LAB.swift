//
//  ColorModel+LAB.swift
//  
//
//  Created by Florian Zand on 14.12.25.
//

import Foundation
import CoreGraphics

extension ColorModels {
    /// The color components for a color in the CIE Lab color space.
    public struct LAB: ColorModel {
        /// The lightness component of the color.
        public var lightness: Double
        /// The green-red component of the color.
        public var greenRed: Double
        /// The blue-yellow component of the color.
        public var blueYellow: Double
        /// The alpha value of the color.
        public var alpha: Double {
            didSet { alpha = alpha.clamped(to: 0...1) }
        }
        
        public var description: String {
            "LAB(lightness: \(lightness), greenRed: \(greenRed), blueYellow: \(blueYellow), alpha: \(alpha))"
        }
        
        public var components: [Double] {
            get { [lightness, greenRed, blueYellow, alpha] }
            set {
                lightness = newValue[safe: 0] ?? lightness
                greenRed = newValue[safe: 1] ?? greenRed
                blueYellow = newValue[safe: 2] ?? blueYellow
                alpha = newValue[safe: 3] ?? alpha
            }
        }
        
        /// The color in the sRGB color space.
        public var rgb: SRGB {
            xyz.rgb
        }
        
        /// The color in the OKLAB color space.
        public var oklab: OKLAB {
            rgb.oklab
        }
        
        /// The color in the OKLCH color space.
        public var oklch: OKLCH {
            rgb.oklch
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
            let fy = (lightness + 16.0) / 116.0
            let fx = fy + greenRed / 500.0
            let fz = fy - blueYellow / 200.0
            return XYZ(x: fInv(fx) * D65.Xn, y: fInv(fy) * D65.Yn, z: fInv(fz) * D65.Zn, alpha: alpha)
        }
        
        /// The color in the grayscale color space.
        public var gray: Gray {
            rgb.gray
        }
        
        /// The color in the LCH color space.
        public var lch: LCH {
            let chroma = sqrt(greenRed * greenRed + blueYellow * blueYellow)
            var hue = atan2(blueYellow, greenRed) / (2.0 * Double.pi)
            if hue < 0 { hue += 1 }
            return LCH(lightness: lightness, chroma: chroma, hue: hue, alpha: alpha)
        }
        
        /// Creates the color with the specified components.
        public init(lightness: Double, greenRed: Double, blueYellow: Double, alpha: Double = 1.0) {
            self.lightness = lightness
            self.greenRed = greenRed
            self.blueYellow = blueYellow
            self.alpha = alpha
        }
        
        public init(_ components: [Double]) {
            precondition(components.count >= 3, "You need to provide at least 3 components for a color in CIE LAB color space.")
            self.init(lightness: components[0], greenRed: components[1], blueYellow: components[2], alpha: components[safe: 3] ?? 0.0)
        }
        
        @inline(__always)
        private func fInv(_ t: Double) -> Double {
            let t3 = t * t * t
            return t3 > 0.008856 ? t3 : (t - 16.0/116.0) / 7.787
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

public extension ColorModel where Self == ColorModels.LAB {
    /// Returns the color components for a color in the CIE Lab color space.
    static func lab(_ components: [Double]) -> Self {
        .init(components)
    }
    
    /// Returns the color components for a color in the CIE Lab color space.
    static func lab(lightness: Double, greenRed: Double, blueYellow: Double, alpha: Double = 1.0) -> Self {
        .init(lightness: lightness, greenRed: greenRed, blueYellow: blueYellow, alpha: alpha)
    }
}
