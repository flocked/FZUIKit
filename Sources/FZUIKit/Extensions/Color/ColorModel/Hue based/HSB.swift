//
//  ColorModel+HSB.swift
//  
//
//  Created by Florian Zand on 14.12.25.
//

import Foundation
import FZSwiftUtils

extension ColorModels {
    /// The color components for a color in the HSB / HSV color space.
    public struct HSB: ColorModel {
        var storage: SIMD4<Double>
        
        /// The hue component of the color.
        public var hue: Double {
            get { storage.x }
            set { storage.x = newValue }
        }
        
        /// The saturation component of the color.
        public var saturation: Double {
            get { storage.y }
            set { storage.y = newValue }
        }
        
        /// The brightness component of the color.
        public var brightness: Double {
            get { storage.z }
            set { storage.z = newValue }
        }
        
        /// The alpha value of the color.
        public var alpha: Double {
            get { storage.w }
            set { storage.w = newValue.clamped(to: 0...1) }
        }
        
        /// The hue component of the color in degrees.
        public var hueDegrees: Double {
            get { hue * 360 }
            set { hue = newValue / 360 }
        }
        
        public var description: String {
            "HSB(hue: \(hue), saturation: \(saturation), brightness: \(brightness), alpha: \(alpha))"
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
            if lightness == 0 || lightness == brightness {
                saturation = 0
            } else {
                saturation = (brightness - lightness) / min(lightness, brightness - lightness)
            }
            return HSL(hue: ColorMath.wrapUnit(hue), saturation: saturation, lightness: lightness, alpha: alpha)
        }
        
        /// The color in the sRGB color space.
        public var rgb: SRGB {
            if saturation <= 0 { return SRGB(red: brightness, green: brightness, blue: brightness, alpha: alpha) }
            let hue = ColorMath.wrapUnit(hue)
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
        
        /// The color in the HWB color space.
        public var hwb: HWB {
            .init(hue: hue, whiteness: brightness * (1 - saturation), blackness: 1 - brightness, alpha: alpha)
        }
        
        public var animatableData: SIMD8<Double> {
            get {
                let vector = ColorMath.hueToVector(hue)
                return .init(vector.x, vector.y, saturation, brightness, alpha, 0, 0, 0)
            }
            set {
                hue = ColorMath.hueFromVector(newValue[0], newValue[1], reference: hue)
                saturation = newValue[2]
                brightness = newValue[3]
                alpha = newValue[4]
            }
        }
        
        /// Creates the color with the specified components.
        public init(hue: Double, saturation: Double, brightness: Double, alpha: Double = 1.0) {
            storage = .init(hue, saturation, brightness, alpha)
        }
        
        /// Creates the color with the specified components.
        public init(hueDegrees: Double, saturation: Double, brightness: Double, alpha: Double = 1.0) {
            storage = .init(hueDegrees/360.0, saturation, brightness, alpha)
        }
        
        public init(_ components: [Double]) {
            precondition(components.count >= 3, "You need to provide at least 3 components for a color in HSB color space.")
            self.init(hue: components[0], saturation: components[1], brightness: components[2], alpha: components[safe: 3] ?? 0.0)
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
