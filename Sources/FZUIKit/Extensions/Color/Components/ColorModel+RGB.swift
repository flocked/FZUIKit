//
//  ColorModel+RGB.swift
//  
//
//  Created by Florian Zand on 14.12.25.
//

import Foundation
import CoreGraphics
import FZSwiftUtils

extension ColorComponents {
    /// The color components for a color in the sRGB color space.
    public struct SRGB: _ColorModel {
        /// The red component of the color.
        public var red: Double
        /// The green component of the color.
        public var green: Double
        /// The blue component of the color.
        public var blue: Double
        /// The alpha value of the color.
        public var alpha: Double {
            didSet { alpha = alpha.clamped(to: 0...1) }
        }
        
        /// The linear red component of the color.
        public var linearRed: Double {
            get { Self.srgbToLinear(red) }
            set { red = Self.linearToSRGB(newValue) }
        }
        
        /// The linear green component of the color.
        public var linearGreen: Double {
            get { Self.srgbToLinear(green) }
            set { green = Self.linearToSRGB(newValue) }
        }
        
        /// The linear blue component of the color.
        public var linearBlue: Double {
            get { Self.srgbToLinear(blue) }
            set { blue = Self.linearToSRGB(newValue) }
        }
        
        public var components: [Double] {
            [red, green, blue, alpha]
        }
        
        public var description: String {
            "SRGB(red: \(red), green: \(green), blue: \(blue), alpha: \(alpha))"
        }
        
        /// The color in the OKLAB color space.
        public var oklab: OKLAB {
            let lR = linearRed
            let lG = linearGreen
            let lB = linearBlue
            let Lc = cbrt(0.4122214708*lR + 0.5363325363*lG + 0.0514459929*lB)
            let Mc = cbrt(0.2119034982*lR + 0.6806995451*lG + 0.1073969566*lB)
            let Sc = cbrt(0.0883024619*lR + 0.2817188376*lG + 0.6299787005*lB)
            let outL = 0.2104542553*Lc + 0.7936177850*Mc - 0.0040720468*Sc
            let outA = 1.9779984951*Lc - 2.4285922050*Mc + 0.4505937099*Sc
            let outB = 0.0259040371*Lc + 0.7827717662*Mc - 0.8086757660*Sc
            return OKLAB(lightness: outL, greenRed: outA, blueYellow: outB, alpha: alpha)
        }
        
        /// The color in the OKLCH color space.
        public var oklch: OKLCH {
            oklab.oklch
        }
        
        /// The color in the HSL color space.
        public var hsl: HSL {
            hsb.hsl
        }
        
        /// The color in the HSB color space.
        public var hsb: HSB {
            let maxV = max(red, max(green, blue))
            let minV = min(red, min(green, blue))
            let delta = maxV - minV
            
            var hue = 0.0
            let saturation = (maxV == 0) ? 0 : delta / maxV
            let brightness = maxV
            
            if delta != 0 {
                if maxV == red { hue = ((green - blue) / delta).truncatingRemainder(dividingBy: 6) }
                else if maxV == green { hue = (blue - red) / delta + 2 }
                else { hue = (red - green) / delta + 4 }
                hue /= 6
                if hue < 0 { hue += 1 }
            }
            return HSB(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        }
        
        /// The color in the CMYK color space.
        public var cmyk: CMYK {
            let black = 1.0 - max(red, max(green, blue))
            if black >= 1.0 - 1e-6 {
                return CMYK(cyan: 0.0, magenta: 0.0, yellow: 0.0, black: black, alpha: alpha)
            }
            let cyan = (1.0 - red - black) / (1.0 - black)
            let magenta = (1.0 - green - black) / (1.0 - black)
            let yellow = (1.0 - blue - black) / (1.0 - black)
            return CMYK(cyan: cyan, magenta: magenta, yellow: yellow, black: black, alpha: alpha)
        }
        
        /// The color in the XYZ color space.
        public var xyz: XYZ {
            let r = linearRed
            let g = linearGreen
            let b = linearBlue
            let x = 0.4124564*r + 0.3575761*g + 0.1804375*b
            let y = 0.2126729*r + 0.7151522*g + 0.0721750*b
            let z = 0.0193339*r + 0.1191920*g + 0.9503041*b
            return XYZ(x: x, y: y, z: z, alpha: alpha)
        }
        
        /// The color in the CIE Lab color space.
        public var lab: LAB {
            xyz.lab
        }
        
        /// The color in the grayscale color space.
        public var gray: Gray {
            Gray(white: 0.2126 * red + 0.7152 * green + 0.0722 * blue, alpha: alpha)
        }
        
        /// Creates the color with the specified components.
        public init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
            self.red = red
            self.green = green
            self.blue = blue
            self.alpha = alpha
        }
        
        /// Creates the color with the specified linear components.
        public init(linearRed red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
            self.red = Self.linearToSRGB(red)
            self.green = Self.linearToSRGB(green)
            self.blue = Self.linearToSRGB(blue)
            self.alpha = alpha
        }
        
        public init(_ components: [Double]) {
            precondition(components.count >= 3, "You need to provide at least 3 components for a color in SRGB color space.")
            self.init(red: components[0], green: components[1], blue: components[2], alpha: components[safe: 3] ?? 0.0)
        }
        
        public static let colorSpace = CGColorSpace(name: .extendedSRGB)!
        
        @inline(__always)
        private static func srgbToLinear(_ c: Double) -> Double {
            c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
        }
        
        @inline(__always)
        private static func linearToSRGB(_ c: Double) -> Double {
            c <= 0.0031308 ? 12.92 * c : 1.055 * pow(c, 1.0 / 2.4) - 0.055
        }
    }
}

public extension ColorModel where Self == ColorComponents.SRGB {
    /// Returns the color components for a color in the SRGB color space.
    static func rgb(_ components: [Double]) -> Self {
        .init(components)
    }
    
    /// Returns the color components for a color in the SRGB color space.
    static func rgb(red: Double, green: Double, blue: Double, alpha: Double) -> Self {
        .init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
