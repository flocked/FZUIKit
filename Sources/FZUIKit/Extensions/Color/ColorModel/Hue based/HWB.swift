//
//  ColorModels+HWB.swift
//
//
//  Created by Florian Zand on 24.01.26.
//

import Foundation
import FZSwiftUtils

extension ColorModels {
    /// The color components for a color in the HWB color space.
    public struct HWB: ColorModel {
        var storage: SIMD4<Double>
        
        /// The hue component of the color.
        public var hue: Double {
            get { storage.x }
            set { storage.x = newValue }
        }
        
        /// The whiteness component of the color.
        public var whiteness: Double {
            get { storage.y }
            set { storage.y = newValue }
        }
        
        /// The blackness component of the color.
        public var blackness: Double {
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
            "HWB(hue: \(hue), whiteness: \(whiteness), blackness: \(blackness), alpha: \(alpha))"
        }
        
        public var components: [Double] {
            get { [hue, whiteness, blackness, alpha] }
            set {
                hue = newValue[safe: 0] ?? hue
                whiteness = newValue[safe: 1] ?? whiteness
                blackness = newValue[safe: 2] ?? blackness
                alpha = newValue[safe: 3] ?? alpha
            }
        }
        
        /// The color in the HSB color space.
        public var hsb: HSB {
            let brightness = 1 - blackness
            let saturation: Double
            if brightness == 0 {
                saturation = 0
            } else {
                saturation = 1 - whiteness / brightness
            }
            return .init(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        }
        
        /// The color in the sRGB color space.
        public var rgb: SRGB {
            hsb.rgb
        }
        
        public var animatableData: SIMD8<Double> {
            get {
                let vector = ColorMath.hueToVector(hue)
                return .init(vector.x, vector.y, whiteness, blackness, alpha, 0, 0, 0)
            }
            set {
                hue = ColorMath.hueFromVector(newValue[0], newValue[1], reference: hue)
                whiteness = newValue[2]
                blackness = newValue[3]
                alpha = newValue[4]
            }
        }
        
        /// Creates the color with the specified components.
        public init(hue: Double, whiteness: Double, blackness: Double, alpha: Double = 1.0) {
            storage = .init(hue, whiteness, blackness, alpha)
        }
        
        /// Creates the color with the specified components.
        public init(hueDegrees: Double, whiteness: Double, blackness: Double, alpha: Double = 1.0) {
            storage = .init(hueDegrees/360.0, whiteness, blackness, alpha)
        }
        
        public init(_ components: [Double]) {
            precondition(components.count >= 3, "You need to provide at least 3 components for a color in HWB color space.")
            self.init(hue: components[0], whiteness: components[1], blackness: components[2], alpha: components[safe: 3] ?? 0.0)
        }
    }
}

public extension ColorModel where Self == ColorModels.HWB {
    /// Returns the color components for a color in the HWB color space.
    static func hwb(_ components: [Double]) -> Self {
        .init(components)
    }
    
    /// Returns the color components for a color in the HWB color space.
    static func hwb(hue: Double, whiteness: Double, blackness: Double, alpha: Double = 1.0) -> Self {
        .init(hue: hue, whiteness: whiteness, blackness: blackness, alpha: alpha)
    }
}
