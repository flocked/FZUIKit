//
//  ColorModel+OKLAB.swift
//  
//
//  Created by Florian Zand on 14.12.25.
//

import Foundation
import CoreGraphics

extension ColorModels {
    /// The color components for a color in the OKLAB color space.
    public struct OKLAB: ColorModel {
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
            "OKLAB(lightness: \(lightness), greenRed: \(greenRed), blueYellow: \(blueYellow), alpha: \(alpha))"
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
        
        /// The color in the OKLCH color space.
        public var oklch: OKLCH {
            let a = greenRed, b = blueYellow
            let chroma = sqrt(a*a + b*b)
            var hue = atan2(b, a) / (2.0 * Double.pi)
            if hue < 0 { hue += 1 }
            return OKLCH(lightness: lightness, chroma: chroma, hue: hue, alpha: alpha)
        }
        
        /// The color in the sRGB color space.
        public var rgb: SRGB {
            let Lc = lightness + 0.3963377774*greenRed + 0.2158037573*greenRed
            let Mc = lightness - 0.1055613458*greenRed - 0.0638541728*greenRed
            let Sc = lightness - 0.0894841775*greenRed - 1.2914855480*greenRed
            let L3 = Lc * Lc * Lc
            let M3 = Mc * Mc * Mc
            let S3 = Sc * Sc * Sc
            let red =  4.0767416621*L3 - 3.3077115913*M3 + 0.2309699292*S3
            let green = -1.2684380046*L3 + 2.6097574011*M3 - 0.3413193965*S3
            let blue = -0.0041960863*L3 - 0.7034186147*M3 + 1.7076147010*S3
            return SRGB(linearRed: red, green: green, blue: blue, alpha: alpha)
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
        
        /// The color in the LCH color space.
        public var lch: LCH {
            rgb.lch
        }
        
        /// The color inverted.
        public var inverted: Self {
            rgb.inverted.oklab
        }
        
        /// Creates the color with the specified components.
        public init(lightness: Double, greenRed: Double, blueYellow: Double, alpha: Double = 1.0) {
            self.lightness = lightness
            self.greenRed = greenRed
            self.blueYellow = blueYellow
            self.alpha = alpha
        }
        
        public init(_ components: [Double]) {
            precondition(components.count >= 3, "You need to provide at least 3 components for a color in OKLAB color space.")
            self.init(lightness: components[0], greenRed: components[1], blueYellow: components[2], alpha: components[safe: 3] ?? 0.0)
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

public extension ColorModel where Self == ColorModels.OKLAB {
    /// Returns the color components for a color in the OKLAB color space.
    static func oklab(_ components: [Double]) -> Self {
        .init(components)
    }
    
    /// Returns the color components for a color in the OKLAB color space.
    static func oklab(lightness: Double, greenRed: Double, blueYellow: Double, alpha: Double = 1.0) -> Self {
        .init(lightness: lightness, greenRed: greenRed, blueYellow: blueYellow, alpha: alpha)
    }
}
