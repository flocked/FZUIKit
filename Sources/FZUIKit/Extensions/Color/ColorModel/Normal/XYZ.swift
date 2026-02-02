//
//  ColorModel+XYZ.swift
//  
//
//  Created by Florian Zand on 14.12.25.
//

import Foundation
import FZSwiftUtils

extension ColorModels {
    /// The color components for a color in the XYZ color space.
    public struct XYZ: ColorModel {
        public var animatableData: SIMD4<Double>

        /// The x component of the color.
        public var x: Double {
            get { animatableData.x }
            set { animatableData.x = newValue }
        }
        
        /// The y component of the color.
        public var y: Double {
            get { animatableData.y }
            set { animatableData.y = newValue }
        }
        
        /// The z component of the color.
        public var z: Double {
            get { animatableData.z }
            set { animatableData.z = newValue }
        }
        
        /// The alpha value of the color.
        public var alpha: Double {
            get { animatableData.w }
            set { animatableData.w = newValue.clamped(to: 0...1) }
        }
        
        public var description: String {
            "XYZ(x: \(x), y: \(y), z: \(z), alpha: \(alpha))"
        }
        
        public var components: [Double] {
            get { [x, y, z, alpha] }
            set {
                x = newValue[safe: 0] ?? x
                y = newValue[safe: 1] ?? y
                z = newValue[safe: 2] ?? z
                alpha = newValue[safe: 3] ?? alpha
            }
        }
        
        private static let toRGB: [SIMD3<Double>] = [
            SIMD3( 3.2404542,  -1.5371385, -0.4985314),
            SIMD3(-0.9692660,  1.8760108,  0.0415560),
            SIMD3( 0.0556434, -0.2040259,  1.0572252)]
        
        /// The color in the sRGB color space.
        public var rgb: SRGB {
            let xyzVec = SIMD3(x, y, z)
            let red = xyzVec.dot(Self.toRGB[0])
            let green = xyzVec.dot(Self.toRGB[1])
            let blue = xyzVec.dot(Self.toRGB[2])
            return .init(linearRed: red, green: green, blue: blue, alpha: alpha)
        }
        
        /// The color in the XYZ color space.
        public var xyz: XYZ { self }
        
        /// The color in the LUV color space.
        public var luv: LUV {
            let un = XYZ.WhitePoint.D65.un
            let vn = XYZ.WhitePoint.D65.vn
            let denom = x + 15*y + 3*z
            let uPrime = denom != 0 ? 4*x/denom : 0
            let vPrime = denom != 0 ? 9*y/denom : 0
            let Y_Yn = y / XYZ.WhitePoint.D65.y
            let lightness: Double
            if Y_Yn > pow(6.0/29.0, 3.0) {
                lightness = 116 * pow(Y_Yn, 1/3.0) - 16
            } else {
                lightness = (29.0/3.0)*(29.0/3.0)*Y_Yn
            }
            let greenRed = 13 * lightness * (uPrime - un)
            let blueYellow = 13 * lightness * (vPrime - vn)
            return .init(lightness: lightness, greenRed: greenRed, blueYellow: blueYellow, alpha: alpha)
        }
        
        /// The color in the LAB color space.
        public var lab: LAB {
            let fx = ColorMath.LAB.f(x / XYZ.WhitePoint.D65.x)
            let fy = ColorMath.LAB.f(y / XYZ.WhitePoint.D65.y)
            let fz = ColorMath.LAB.f(z / XYZ.WhitePoint.D65.z)
            return .init(lightness: 116.0 * fy - 16.0, greenRed: 500.0 * (fx - fy), blueYellow: 200.0 * (fy - fz), alpha: alpha)
        }
        
        private static let toDisplayP3: [SIMD3<Double>] = [
            SIMD3( 2.493496911941425, -0.9313836179191239, -0.40271078445071684),
            SIMD3(-0.8294889695615747,  1.7626640603183463,  0.023624685841943577),
            SIMD3( 0.03584583024378447, -0.07617238926804182, 0.9568845240076872)]

        /// The color in the DisplayP3 color space.
        public var displayP3: DisplayP3 {
            let xyzVec = SIMD3(x, y, z)
            let red = xyzVec.dot(Self.toDisplayP3[0])
            let green = xyzVec.dot(Self.toDisplayP3[1])
            let blue = xyzVec.dot(Self.toDisplayP3[2])
            return .init(linearRed: red, green: green, blue: blue, alpha: alpha)
        }

        /// The color in the JZCZHZ color space.
        public var jzazbz: JZAZBZ {
            ColorMath.JZAZBZ.fromXYZ(self)
        }

        /// Creates the color with the specified components.
        public init(x: Double, y: Double, z: Double, alpha: Double = 1.0) {
            animatableData = .init(x, y, z, alpha)
        }
        
        public init(_ components: [Double]) {
            precondition(components.count >= 3, "You need to provide at least 3 components for a color in XYZ color space.")
            self.init(x: components[0], y: components[1], z: components[2], alpha: components[safe: 3] ?? 0.0)
        }
    }
}

extension ColorModels.XYZ {
    /// Represents a CIE XYZ white point in 3D space.
    public struct WhitePoint {
        /// The components of the white point.
        public let components: SIMD3<Double>
        
        /// The x component of the white point.
        public var x: Double { components.x }
        /// The y component of the white point.
        public var y: Double { components.y }
        /// The z component of the white point.
        public var z: Double { components.z }
        
        /// The u' chromaticity coordinate of the white point.
        public var un: Double {
            4.0 * components.x / components.sum()
        }
        
        /// The v' chromaticity coordinate of the white point.
        public var vn: Double {
            9.0 * components.y / components.sum()
        }
        
        /// D50.
        public static let D50 = Self(0.96422, 1.00000, 0.82521)
        /// D55.
        public static let D55 = Self(0.95682, 1.00000, 0.92149)
        /// D60.
        public static let D60 = Self(0.96720, 1.00000, 0.81427)
        /// D65.
        public static let D65 = Self(0.95047, 1.00000, 1.08883)
        /// D75.
        public static let D75 = Self(0.94972, 1.00000, 1.22638)
        
        /// Creates a white point from the specified `x`, `y` and `z` components.
        public init(_ x: Double, _ y: Double, _ z: Double) {
            self.components = .init(x, y, z)
        }
    }
}

public extension ColorModel where Self == ColorModels.XYZ {
    /// Returns the color components for a color in the XYZ color space.
    static func xyz(_ components: [Double]) -> Self {
        .init(components)
    }
    
    /// Returns the color components for a color in the XYZ color space.
    static func xyz(x: Double, y: Double, z: Double, alpha: Double = 1.0) -> Self {
        .init(x: x, y: y, z: z, alpha: alpha)
    }
}
