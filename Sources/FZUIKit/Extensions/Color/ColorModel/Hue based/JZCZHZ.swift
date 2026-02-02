//
//  ColorModels+JZCZHZ.swift
//
//
//  Created by Florian Zand on 26.01.26.
//

import Foundation
import FZSwiftUtils

extension ColorModels {
    /// The color components for a color in the JzCzHz color space.
    public struct JZCZHZ: ColorModel {
        var storage: SIMD4<Double>
        
        /// The Jz component of the color.
        public var jz: Double {
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
        
        /// The color in the JZAZBZ color space.
        public var jzazbz: JZAZBZ {
            let hueRadians = hue * .pi / 180.0
            let az = chroma * cos(hueRadians)
            let bz = chroma * sin(hueRadians)
            return .init(jz: jz, az: az, bz: bz, alpha: alpha)
        }
        
        /// The color in the XYZ color space.
        public var xyz: XYZ {
            jzazbz.xyz
        }
        
        public var description: String {
            "JZCZHZ(jz: \(jz), chroma: \(chroma), hue: \(hue), alpha: \(alpha))"
        }
        
        public var components: [Double] {
            get { [jz, chroma, hue, alpha] }
            set {
                jz = newValue[safe: 0] ?? jz
                chroma = newValue[safe: 1] ?? chroma
                hue = newValue[safe: 2] ?? hue
                alpha = newValue[safe: 3] ?? alpha
            }
        }
        
        public var animatableData: SIMD8<Double> {
            get {
                let vector = ColorMath.hueToVector(hue)
                return .init(vector.x, vector.y, jz, chroma, alpha, 0, 0, 0)
            }
            set {
                hue = ColorMath.hueFromVector(newValue[0], newValue[1], reference: hue)
                jz = newValue[2]
                chroma = newValue[3]
                alpha = newValue[4]
            }
        }
        
        /// Creates the color with the specified components.
        public init(jz: Double, chroma: Double, hue: Double, alpha: Double = 1.0) {
            storage = .init(jz, chroma, hue, alpha)
        }
        
        /// Creates the color with the specified components.
        public init(jz: Double, chroma: Double, hueDegrees: Double, alpha: Double = 1.0) {
            storage = .init(jz, chroma, hueDegrees/360.0, alpha)
        }
        
        public init(_ components: [Double]) {
            precondition(components.count >= 3, "You need to provide at least 3 components for a color in JZAZBZ color space.")
            self.init(jz: components[0], chroma: components[1], hue: components[2], alpha: components[safe: 3] ?? 1.0)
        }
    }
}

public extension ColorModel where Self == ColorModels.JZCZHZ {
    /// Returns the color components for a color in the JZCZHZ color space.
    static func jzczhz(_ components: [Double]) -> Self {
        .init(components)
    }
    
    /// Returns the color components for a color in the JZCZHZ color space.
    static func jzczhz(jz: Double, chroma: Double, hue: Double, alpha: Double = 1.0) -> Self {
        .init(jz: jz, chroma: chroma, hue: hue, alpha: alpha)
    }
}
