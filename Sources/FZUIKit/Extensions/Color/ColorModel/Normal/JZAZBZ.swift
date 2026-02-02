//
//  ColorModels+JZAZBZ.swift
//
//
//  Created by Florian Zand on 25.01.26.
//

import Foundation
import FZSwiftUtils

extension ColorModels {
    /// The color components for a color in the JzAzBz color space.
    public struct JZAZBZ: ColorModel {
        public var animatableData: SIMD4<Double>
        
        /// The jz component of the color.
        public var jz: Double {
            get { animatableData.x }
            set { animatableData.x = newValue }
        }
        
        /// The az component of the color.
        public var az: Double {
            get { animatableData.y }
            set { animatableData.y = newValue }
        }
        
        /// The bz component of the color.
        public var bz: Double {
            get { animatableData.z }
            set { animatableData.z = newValue }
        }
        
        /// The alpha value of the color.
        public var alpha: Double {
            get { animatableData.w }
            set { animatableData.w = newValue.clamped(to: 0...1) }
        }
        
        public var components: [Double] {
            get { [jz, az, bz, alpha] }
            set {
                jz = newValue[safe: 0] ?? jz
                az = newValue[safe: 1] ?? az
                bz = newValue[safe: 2] ?? bz
                alpha = newValue[safe: 3] ?? alpha
            }
        }
        
        /// The color in the XYZ color space.
        public var xyz: ColorModels.XYZ {
            ColorMath.JZAZBZ.toXYZ(self)
        }
        
        /// The color in the JZCZHZ color space.
        public var jzczhz: JZCZHZ {
            let cz = sqrt(az * az + bz * bz)
            var hz = atan2(bz, az) * 180.0 / .pi
            if hz < 0 {
                hz += 360.0
            }
            return .init(jz: jz, chroma: cz, hue: hz, alpha: alpha)
        }
        
        public var description: String {
            "JZAZBZ(jz: \(jz), az: \(az), az: \(az), alpha: \(alpha))"
        }
        
        public init(jz: Double, az: Double, bz: Double, alpha: Double = 1.0) {
            animatableData = .init(jz, az, bz, alpha)
        }
        
        public init(_ components: [Double]) {
            precondition(components.count >= 3, "You need to provide at least 3 components for a color in JZAZBZ color space.")
            self.init(jz: components[0], az: components[1], bz: components[2], alpha: components[safe: 3] ?? 1.0)
        }
    }
}

public extension ColorModel where Self == ColorModels.JZAZBZ {
    /// Returns the color components for a color in the JZAZBZ color space.
    static func jzazbz(_ components: [Double]) -> Self {
        .init(components)
    }
    
    /// Returns the color components for a color in the JZAZBZ color space.
    static func jzazbz(jz: Double, az: Double, bz: Double, alpha: Double = 1.0) -> Self {
        .init(jz: jz, az: az, bz: bz, alpha: alpha)
    }
}

extension ColorMath {
    enum JZAZBZ {
        private static let b: Double = 1.15
        private static let g: Double = 0.66
        private static let n: Double = 2610.0 / pow(2.0, 14.0)
        private static let ninv: Double = pow(2.0, 14.0) / 2610.0
        private static let c1: Double = 3424.0 / pow(2.0, 12.0)
        private static let c2: Double = 2413.0 / pow(2.0, 7.0)
        private static let c3: Double = 2392.0 / pow(2.0, 7.0)
        private static let p: Double = (1.7 * 2523.0) / pow(2.0, 5.0)
        private static let pinv: Double = pow(2.0, 5.0) / (1.7 * 2523.0)
        private static let d: Double = -0.56
        private static let d0: Double = 1.6295499532821566e-11
        
        private static let coneToXYZ: [SIMD3<Double>] = [
            SIMD3(1.9242264357876067,  -1.0047923125953657,  0.037651404030618),
            SIMD3(0.35031676209499907,  0.7264811939316552, -0.06538442294808501),
            SIMD3(-0.09098281098284752, -0.3127282905230739,  1.5227665613052603)]
        
        private static let iabToCone: [SIMD3<Double>] = [
            SIMD3(1,                   0.13860504327153927,   0.05804731615611883),
            SIMD3(1,                  -0.1386050432715393,   -0.058047316156118904),
            SIMD3(1,                  -0.09601924202631895,  -0.81189189605603900)]
        
        private static let XYZToCone: [SIMD3<Double>] = [
            SIMD3(0.41478972, 0.579999, 0.0146480),
            SIMD3(-0.2015100, 1.120649, 0.0531008),
            SIMD3(-0.0166008, 0.264800, 0.6684799)]
        
        private static let coneToIab: [SIMD3<Double>] = [
            SIMD3(0.5, 0.5, 0.0),
            SIMD3(3.524000, -4.066708, 0.542708),
            SIMD3(0.199076, 1.096799, -1.295875)]
        
        static func toXYZ(_ jzazbz: ColorModels.JZAZBZ) -> ColorModels.XYZ {
            // 1. Recover Iz
            let iz = (jzazbz.jz + d0) / (1.0 + d - d * (jzazbz.jz + d0))
            // 2. Iab vector
            let iab = SIMD3(iz, jzazbz.az, jzazbz.bz)
            // 3. Iab → PQ-LMS
            let pqlms = SIMD3(
                iab.dot(iabToCone[0]),
                iab.dot(iabToCone[1]),
                iab.dot(iabToCone[2]))
            // 4. PQ decode
            let lms = SIMD3(
                pqDecode(pqlms[0]),
                pqDecode(pqlms[1]),
                pqDecode(pqlms[2]))
            // 5. LMS → modified XYZ
            let modifiedXYZ = SIMD3(
                lms.dot(coneToXYZ[0]),
                lms.dot(coneToXYZ[1]),
                lms.dot(coneToXYZ[2]))
            let za = modifiedXYZ.z
            // 6. Undo blue-curvature fix
            let xa = (modifiedXYZ.x + (b - 1.0) * za) / b
            let ya = (modifiedXYZ.y + (g - 1.0) * xa) / g
            return .init(x: xa, y: ya, z: za, alpha: jzazbz.alpha)
        }
        
        static func fromXYZ(_ xyz: ColorModels.XYZ) -> ColorModels.JZAZBZ {
            // 1. Modify X and Y to minimize blue curvature
            let modifiedXYZ = SIMD3(
                b * xyz.x - (b - 1.0) * xyz.z,
                g * xyz.y - (g - 1.0) * xyz.x,
                xyz.z)
            // 2. Move to LMS cone domain using SIMD dot products
            let lms = SIMD3(
                modifiedXYZ.dot(XYZToCone[0]),
                modifiedXYZ.dot(XYZToCone[1]),
                modifiedXYZ.dot(XYZToCone[2]))
            // 3. PQ-encode LMS
            let encodedLMS = SIMD3(
                pqEncode(lms[0]),
                pqEncode(lms[1]),
                pqEncode(lms[2]))
            // 4. Calculate Iz, az, bz via SIMD dot products
            let iab = SIMD3(
                encodedLMS.dot(coneToIab[0]),
                encodedLMS.dot(coneToIab[1]),
                encodedLMS.dot(coneToIab[2]))
            // 5. Final Jz calculation
            let iz = iab[0]
            let jz = ((1.0 + d) * iz) / (1.0 + d * iz) - d0
            return .init(jz: jz, az: iab[1], bz: iab[2], alpha: xyz.alpha)
        }
        
        @inline(__always)
        private static func pqEncode(_ val: Double) -> Double {
            let v = val / 10000.0
            let vn = spow(v, n)
            let num = c1 + c2 * vn
            let denom = 1.0 + c3 * vn
            return spow(num / denom, p)
        }
        
        @inline(__always)
        private static func pqDecode(_ val: Double) -> Double {
            let vp = spow(val, pinv)
            let num = c1 - vp
            let denom = c3 * vp - c2
            return 10000.0 * spow(num / denom, ninv)
        }
        
        @inline(__always)
        private static func spow(_ val: Double, _ exp: Double) -> Double {
            return val < 0 ? -pow(-val, exp) : pow(val, exp)
        }
    }
}
