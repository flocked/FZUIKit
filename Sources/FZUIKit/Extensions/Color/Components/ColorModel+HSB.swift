//
//  ColorModel+HSB.swift
//  
//
//  Created by Florian Zand on 14.12.25.
//

import Foundation
import CoreGraphics
import FZSwiftUtils

extension ColorModels {
    /// The color components for a color in the HSB color space.
    public struct HSB: ColorModel {
        /// The hue component of the color.
        public var hue: Double
        /// The saturation component of the color.
        public var saturation: Double
        /// The brightness component of the color.
        public var brightness: Double
        /// The alpha value of the color.
        public var alpha: Double {
            didSet { alpha = alpha.clamped(to: 0...1) }
        }
        
        public var description: String {
            "HSB(hue: \(hue), saturation: \(saturation), brightness: \(brightness), alpha: \(alpha))"
        }
        
        public func blended(withFraction fraction: Double, of other: Self) -> Self {
            let blendedHue = interpolateHue(hue, to: other.hue, fraction: fraction)
            return HSB(hue: blendedHue, saturation: saturation + (other.saturation - saturation) * fraction, brightness: brightness + (other.brightness - brightness) * fraction, alpha: alpha + (other.alpha - alpha) * fraction)
        }
        
        public var components: [Double] {
            get { [hue, saturation, brightness, alpha] }
            set {
                hue = newValue[safe: 0] ?? hue
                saturation = newValue[safe: 1] ?? saturation
                brightness = newValue[safe: 2] ?? brightness
                alpha = newValue[safe: 3] ?? alpha
            }
        }
        
        /// The color in the HSL color space.
        public var hsl: HSL {
            let lightness = brightness * (1 - saturation * 0.5)
            let saturation: Double
            if lightness == 0 || lightness >= brightness {
                saturation = 0
            } else {
                saturation = (brightness - lightness) / min(lightness, brightness - lightness)
            }
            return HSL(hue: wrapUnit(hue), saturation: saturation, lightness: lightness, alpha: alpha)
        }
        
        /// The color in the sRGB color space.
        public var rgb: SRGB {
            if saturation <= 0 { return SRGB(red: brightness, green: brightness, blue: brightness, alpha: alpha) }
            var hue = hue.truncatingRemainder(dividingBy: 1)
            if hue < 0 { hue += 1 }
            let h = hue * 6.0
            let i = Int(floor(h))
            let f = h - Double(i)
            let p = brightness * (1.0 - saturation)
            let q = brightness * (1.0 - saturation * f)
            let t = brightness * (1.0 - saturation * (1.0 - f))
            
            switch (i % 6) {
            case 0:
                return SRGB(red: brightness, green: t, blue: p, alpha: alpha)
            case 1:
                return SRGB(red: q, green: brightness, blue: p, alpha: alpha)
            case 2:
                return SRGB(red: p, green: brightness, blue: t, alpha: alpha)
            case 3:
                return SRGB(red: p, green: q, blue: brightness, alpha: alpha)
            case 4:
                return SRGB(red: t, green: p, blue: brightness, alpha: alpha)
            default:
                return SRGB(red: brightness, green: p, blue: q, alpha: alpha)
            }
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
        public init(hue: Double, saturation: Double, brightness: Double, alpha: Double = 1.0) {
            self.hue = hue
            self.saturation = saturation
            self.brightness = brightness
            self.alpha = alpha
        }
        
        public init(_ components: [Double]) {
            precondition(components.count >= 3, "You need to provide at least 3 components for a color in HSB color space.")
            self.init(hue: components[0], saturation: components[1], brightness: components[2], alpha: components[safe: 3] ?? 0.0)
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

public extension ColorModel where Self == ColorModels.HSB {
    /// Returns the color components for a color in the HSB color space.
    static func hsb(_ components: [Double]) -> Self {
        .init(components)
    }
    
    /// Returns the color components for a color in the HSB color space.
    static func hsb(hue: Double, saturation: Double, brightness: Double, alpha: Double = 1.0) -> Self {
        .init(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
}
