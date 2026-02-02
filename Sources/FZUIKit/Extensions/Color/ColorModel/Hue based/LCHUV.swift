//
//  ColorModel+LCHUV.swift
//
//
//  Created by Florian Zand on 24.01.26.
//

import Foundation
import FZSwiftUtils

extension ColorModels {
    /// The color components for a color in the LCHUV color space.
    public struct LCHUV: ColorModel {
        var storage: SIMD4<Double>

        /// The lightness component of the color.
        public var lightness: Double {
            get { storage.x }
            set { storage.x = newValue }
        }
        
        /// The chroma component of the color.
        public var chroma: Double {
            get { storage.y }
            set { storage.y = newValue }
        }
        
        /// The hue component of the color.
        public var hue: Double {
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
            "LCHUV(lightness: \(lightness), chroma: \(chroma), hue: \(hue), alpha: \(alpha))"
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
        
        /// The color in the the LUV color space.
        public var luv: LUV {
            let cartesian = ColorMath.cartesianFromPolar(hue: hue, chroma: chroma)
            return .init(lightness: lightness, greenRed: cartesian.a, blueYellow: cartesian.b, alpha: alpha)
        }
        
        /// The color in the HSLUV color space.
        public var hsluv: HSLUV {
            let maxC = ColorMath.maxChroma(lightness, hue)
            let saturation = maxC > 0 ? chroma / maxC : 0
            return .init(hue: hue, saturation: saturation, lightness: lightness / 100, alpha: alpha)
        }
        
        /// The color in the HPLUV color space.
        public var hpluv: HPLUV {
            let maxC = ColorMath.maxChroma(lightness, hue)
            let saturation = maxC > 0 ? chroma / maxC : 0
            let lightness = lightness / 100
            return .init(hue: hue, saturation: saturation, lightness: lightness, alpha: alpha)
        }
        
        /// The color in the XYZ color space.
        public var xyz: ColorModels.XYZ {
            luv.xyz
        }
        
        public var animatableData: SIMD8<Double> {
            get {
                let vector = ColorMath.hueToVector(hue)
                return .init(vector.x, vector.y, lightness, chroma, alpha, 0, 0, 0)
            }
            set {
                hue = ColorMath.hueFromVector(newValue[0], newValue[1], reference: hue)
                lightness = newValue[2]
                chroma = newValue[3]
                alpha = newValue[4]
            }
        }
        
        /// Creates the color with the specified components.
        public init(lightness: Double, chroma: Double, hue: Double, alpha: Double = 1.0) {
            storage = .init(lightness, chroma, hue, alpha)
        }
        
        /// Creates the color with the specified components.
        public init(lightness: Double, chroma: Double, hueDegrees: Double, alpha: Double = 1.0) {
            storage = .init(lightness, chroma, hueDegrees/360.0, alpha)
        }
        
        public init(_ components: [Double]) {
            precondition(components.count >= 3, "You need to provide at least 3 components for a color in OKLCH color space.")
            self.init(lightness: components[0], chroma: components[1], hue: components[2], alpha: components[safe: 3] ?? 0.0)
        }
    }
}

public extension ColorModel where Self == ColorModels.LCHUV {
    /// Returns the color components for a color in the LChuv color space.
    static func lcluv(_ components: [Double]) -> Self {
        .init(components)
    }
    
    /// Returns the color components for a color in the LChuv color space.
    static func lcluv(lightness: Double, chroma: Double, hue: Double, alpha: Double = 1.0) -> Self {
        .init(lightness: lightness, chroma: chroma, hue: hue, alpha: alpha)
    }
}
