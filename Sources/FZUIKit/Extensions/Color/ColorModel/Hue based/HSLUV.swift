//
//  ColorModels+HSLUV.swift
//
//
//  Created by Florian Zand on 24.01.26.
//

import Foundation
import FZSwiftUtils

extension ColorModels {
    /// The color components for a color in the HSLUV color space.
    public struct HSLUV: ColorModel {
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
            "HSLUV(hue: \(hue), saturation: \(saturation), lightness: \(lightness), alpha: \(alpha))"
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
        
        /// The color in the LCHUV color space.
        public var lchuv: LCHUV {
            let lightness = lightness * 100
            let chroma = saturation == 0 ? 0 : ColorMath.maxChroma(lightness, hue) * saturation
            // let chroma saturation > 0 ? ColorMath.maxChroma(lightness, hue) * saturation : 0
            return .init(lightness: lightness, chroma: chroma, hue: hue, alpha: alpha)
        }
        
        /// The color in the XYZ color space.
        public var xyz: ColorModels.XYZ {
            lchuv.xyz
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

public extension ColorModel where Self == ColorModels.HSLUV {
    /// Returns the color components for a color in the HSLUV color space.
    static func hsluv(_ components: [Double]) -> Self {
        .init(components)
    }
    
    /// Returns the color components for a color in the HSLUV color space.
    static func hsluv(hue: Double, saturation: Double, lightness: Double, alpha: Double = 1.0) -> Self {
        .init(hue: hue, saturation: saturation, lightness: lightness, alpha: alpha)
    }
}
