//
//  ColorModel+LAB.swift
//  
//
//  Created by Florian Zand on 14.12.25.
//

import Foundation
import FZSwiftUtils

extension ColorModels {
    /// The color components for a color in the CIE Lab color space.
    public struct LAB: ColorModel {
        public var animatableData: SIMD4<Double>
        
        /// The lightness component of the color.
        public var lightness: Double {
            get { animatableData.x }
            set { animatableData.x = newValue }
        }
        
        /// The green-red component of the color.
        public var greenRed: Double {
            get { animatableData.y }
            set { animatableData.y = newValue }
        }
        
        /// The blue-yellow component of the color.
        public var blueYellow: Double {
            get { animatableData.z }
            set { animatableData.z = newValue }
        }
        
        /// The alpha value of the color.
        public var alpha: Double {
            get { animatableData.w }
            set { animatableData.w = newValue.clamped(to: 0...1) }
        }
        
        public var description: String {
            "LAB(lightness: \(lightness), greenRed: \(greenRed), blueYellow: \(blueYellow), alpha: \(alpha))"
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
        
        /// The color in the the XYZ color space.
        public var xyz: XYZ {
            let fy = (lightness + 16.0) / 116.0
            let fx = fy + greenRed / 500.0
            let fz = fy - blueYellow / 200.0
            return XYZ(x: Self.fInv(fx) * XYZ.WhitePoint.D55.x, y: Self.fInv(fy) * XYZ.WhitePoint.D55.y, z: Self.fInv(fz) * XYZ.WhitePoint.D55.z, alpha: alpha)
        }
        
        /// The color in the LCH color space.
        public var lch: LCH {
            let chroma = ColorMath.chromaFromCartesian(greenRed, blueYellow)
            let hue = ColorMath.hueFromCartesian(blueYellow, greenRed)
            return .init(lightness: lightness, chroma: chroma, hue: hue, alpha: alpha)
        }
        
        /// Creates the color with the specified components.
        public init(lightness: Double, greenRed: Double, blueYellow: Double, alpha: Double = 1.0) {
            animatableData = .init(lightness, greenRed, blueYellow, alpha)
        }
        
        public init(_ components: [Double]) {
            precondition(components.count >= 3, "You need to provide at least 3 components for a color in CIE LAB color space.")
            self.init(lightness: components[0], greenRed: components[1], blueYellow: components[2], alpha: components[safe: 3] ?? 0.0)
        }
    }
}

extension ColorModels.LAB {
    fileprivate static let delta = 6.0 / 29.0
    fileprivate static let threshold = delta * delta * delta
    fileprivate static let k = 3 * delta * delta
    fileprivate static let four29 = 4.0 / 29.0
    
    @inline(__always)
    static func f(_ t: Double) -> Double {
        t > threshold ? cbrt(t) : t / k + four29
    }
    
    @inline(__always)
    static func fInv(_ t: Double) -> Double {
        t > delta ? t * t * t : k * (t - four29)
    }
}

public extension ColorModel where Self == ColorModels.LAB {
    /// Returns the color components for a color in the CIE Lab color space.
    static func lab(_ components: [Double]) -> Self {
        .init(components)
    }
    
    /// Returns the color components for a color in the CIE Lab color space.
    static func lab(lightness: Double, greenRed: Double, blueYellow: Double, alpha: Double = 1.0) -> Self {
        .init(lightness: lightness, greenRed: greenRed, blueYellow: blueYellow, alpha: alpha)
    }
}
