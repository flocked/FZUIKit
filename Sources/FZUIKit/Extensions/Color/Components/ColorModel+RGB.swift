//
//  ColorModel+RGB.swift
//  
//
//  Created by Florian Zand on 14.12.25.
//

import Foundation
import CoreGraphics
import FZSwiftUtils

extension ColorModels {
    /// The color components for a color in the sRGB color space.
    public struct SRGB: ColorModel {
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
        
        /**
         The relative luminance of the color.
         
         Setting this values scales the linear RGB components proportionally to achieve the new luminance, while preserving the relative color ratios. Alpha is unaffected.
        */
        public var luminance: Double {
            get { 0.2126 * linearRed + 0.7152 * linearGreen + 0.0722 * linearBlue }
            set {
                let luminance = luminance
                guard luminance != 0 else {
                    linearRed = newValue
                    linearGreen = newValue
                    linearBlue = newValue
                    return
                }
                let scale = newValue / luminance
                linearRed *= scale
                linearGreen *= scale
                linearBlue *= scale
            }
        }
        
        /// A Boolean value indicating whether the color is light.
        public var isLight: Bool {
             luminance >= 0.5
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
        
        /// The color inverted.
        public var inverted: SRGB {
            Self(red: 1.0 - red, green: 1.0 - green, blue: 1.0 - blue, alpha: alpha)
        }
        
        ///  The mode used to convert a color to grayscale.
        public enum GrayscalingMode: String, Hashable {
            /// Linear-light luminance / Physically accurate brightness.
            case luminance
            /// HSL lightness / Perceptual lightness.
            case lightness
            /// Average of RGB channels.
            case average
            /// HSV/HSB value / Maximum channel value.
            case value
        }
        
        public func gray(mode: GrayscalingMode) -> Gray {
            switch mode {
            case .luminance:
                return Gray(white: xyz.y, alpha: alpha)
            case .lightness:
                return Gray(white: hsl.lightness, alpha: alpha)
            case .average:
                return Gray(white: (red + green + blue) / 3.0, alpha: alpha)
            case .value:
                return Gray(white: hsb.brightness, alpha: alpha)
            }
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
        
        /// Initializes a color from a hex string (e.g. `#1D2E3F`) and an optional alpha value.
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
        
        /// Initializes a color from a hex string (e.g. `#1D2E3F`) and an optional alpha value.
        public init(hex: Int, alpha: CGFloat = 1.0) {
            self.init(red: CGFloat((hex & 0xFF0000) >> 16) / 255.0, green: CGFloat((hex & 0x00FF00) >> 8) / 255.0, blue: CGFloat(hex & 0x0000FF) / 255.0, alpha: alpha)
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
                
        public var cgColor: CGColor {
            CGColor(colorSpace: CGColorSpace(name: .extendedSRGB)!, components:  components.map({CGFloat($0)}))!
        }
        
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

public extension ColorModel where Self == ColorModels.SRGB {
    /// Returns the color components for a color in the SRGB color space.
    static func rgb(_ components: [Double]) -> Self {
        .init(components)
    }
    
    /// Returns the color components for a color in the SRGB color space.
    static func rgb(red: Double, green: Double, blue: Double, alpha: Double) -> Self {
        .init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
