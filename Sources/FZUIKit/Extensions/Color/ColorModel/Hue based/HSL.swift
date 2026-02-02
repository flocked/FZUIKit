//
//  ColorModel+HSL.swift
//  
//
//  Created by Florian Zand on 14.12.25.
//

import Foundation
import FZSwiftUtils

extension ColorModels {
    /// The color components for a color in the HSL color space.
    public struct HSL: ColorModel {
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
        
        /// The lightness component of the color.
        public var lightness: Double {
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
            "HSL(hue: \(hue), saturation: \(saturation), lightness: \(lightness), alpha: \(alpha))"
        }
        
        public var components: [Double] {
            get { [hue, saturation, lightness, alpha] }
            set {
                hue = newValue[safe: 0] ?? hue
                saturation = newValue[safe: 1] ?? saturation
                lightness = newValue[safe: 2] ?? lightness
                alpha = newValue[safe: 3] ?? alpha
            }
        }
        
        /// The color in the sRGB color space.
        public var rgb: SRGB {
            hsb.rgb
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
            return .init(hue: ColorMath.wrapUnit(hue), saturation: s_hsv, brightness: v, alpha: alpha)
        }
        
        public var animatableData: SIMD8<Double> {
            get {
                let vector = ColorMath.hueToVector(hue)
                return .init(vector.x, vector.y, saturation, lightness, alpha, 0, 0, 0)
            }
            set {
                hue = ColorMath.hueFromVector(newValue[0], newValue[1], reference: hue)
                saturation = newValue[2]
                lightness = newValue[3]
                alpha = newValue[4]
            }
        }
        
        /// Creates the color with the specified components.
        public init(hue: Double, saturation: Double, lightness: Double, alpha: Double = 1.0) {
            storage = .init(hue, saturation, lightness, alpha)
        }
        
        /// Creates the color with the specified components.
        public init(hueDegrees: Double, saturation: Double, lightness: Double, alpha: Double = 1.0) {
            storage = .init(hueDegrees/360.0, saturation, lightness, alpha)
        }
        
        public init(_ components: [Double]) {
            precondition(components.count >= 3, "You need to provide at least 3 components for a color in HSL color space.")
            self.init(hue: components[0], saturation: components[1], lightness: components[2], alpha: components[safe: 3] ?? 0.0)
        }
    }
}

public extension ColorModel where Self == ColorModels.HSL {
    /// Returns the color components for a color in the HSL color space.
    static func hsl(_ components: [Double]) -> Self {
        .init(components)
    }
    
    /// Returns the color components for a color in the HSL color space.
    static func hsl(hue: Double, saturation: Double, lightness: Double, alpha: Double = 1.0) -> Self {
        .init(hue: hue, saturation: saturation, lightness: lightness, alpha: alpha)
    }
}
