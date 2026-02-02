//
//  ColorModel+Math.swift
//
//
//  Created by Florian Zand on 25.01.26.
//

import Foundation

enum ColorMath {
    static func wrapUnit(_ x: Double) -> Double {
        let r = x.truncatingRemainder(dividingBy: 1.0)
        return r < 0 ? r + 1 : r
    }
    
    private static let kToe = (1 + 0.206) / (1 + 0.03)
    
    @inline(__always)
    static func toe(_ x: Double) -> Double {
        0.5 * (kToe * x - 0.206 + sqrt((kToe * x - 0.206) * (kToe * x - 0.206) + 4 * 0.03 * kToe * x))
    }
    
    @inline(__always)
    static func hueToVector(_ h: Double) -> (x: Double, y: Double) {
        let θ = h * 2 * .pi
        return (cos(θ), sin(θ))
    }
    
    @inline(__always)
    static func hueFromVector(_ x: Double, _ y: Double) -> Double {
        let hue = atan2(y, x) / (2 * .pi)
        return hue < 0 ? hue + 1 : hue
        // return atan2(y, x) / (2 * .pi)
    }
    
    static func hueFromVector(_ x: Double, _ y: Double, reference: Double) -> Double {
        hueFromVector(x, y) + reference - (reference - floor(reference))
    }
    
    @inline(__always)
    static func hueFromCartesian(_ a: Double, _ b: Double) -> Double {
        var hue = atan2(b, a) / (2.0 * .pi)
        if hue < 0 { hue += 1 }
        return hue
    }
    
    @inline(__always)
    static func cartesianFromPolar(hue: Double, chroma: Double) -> (a: Double, b: Double) {
        let hRad = hue * 2.0 * .pi
        return (chroma * cos(hRad), chroma * sin(hRad))
    }
    
    @inline(__always)
    static func chromaFromCartesian(_ a: Double, _ b: Double) -> Double {
        sqrt(a * a + b * b)
    }
    
    static func maxChroma(_ lightness: Double, _ hue: Double) -> Double {
        let bounds = getBounds(lightness)
        let theta = hue * 2 * Double.pi
        var minLen = Double.infinity
        for line in bounds {
            let length = line.intercept / (sin(theta) - line.slope * cos(theta))
            if length >= 0 {
                minLen = min(minLen, length)
            }
        }
        return minLen
    }
    
    private static let boundsMatrix = [
        [ 3.240969941904521, -1.537383177570093, -0.498610760293     ],
        [-0.96924363628087,   1.87596750150772,   0.041555057407175 ],
        [ 0.055630079696993, -0.20397695888897,   1.056971514242878 ]
    ]
    
    private static func getBounds(_ lightness: Double) -> [(slope: Double, intercept: Double)] {
        let sub1 = pow(lightness + 16, 3) / 1560896
        let sub2 = sub1 > 0.0088564516 ? sub1 : lightness / 903.2962962
        var result: [(slope: Double, intercept: Double)] = []
        for c in 0..<3 {
            let m1 = boundsMatrix[c][0]
            let m2 = boundsMatrix[c][1]
            let m3 = boundsMatrix[c][2]
            for t in [0.0, 1.0] {
                let top1 = (284517 * m1 - 94839 * m3) * sub2
                let top2 = (838422 * m3 + 769860 * m2 + 731718 * m1) * lightness * sub2
                - 769860 * t * lightness
                let bottom = (632260 * m3 - 126452 * m2) * sub2 + 126452 * t
                result.append((slope: top1 / bottom, intercept: top2 / bottom))
            }
        }
        return result
    }
}

extension ColorMath {
    enum RGB {
        private static let invGamma = 1.0 / 2.4
        
        @inline(__always)
        static func toLinear(_ c: Double) -> Double {
            let absC = abs(c)
            let res = absC <= 0.04045
            ? absC / 12.92
            : pow((absC + 0.055) / 1.055, 2.4)
            return c < 0 ? -res : res
        }
        
        @inline(__always)
        static func toNonlinear(_ c: Double) -> Double {
            let absC = abs(c)
            let res = absC <= 0.0031308
            ? 12.92 * absC
            : 1.055 * pow(absC, invGamma) - 0.055
            return c < 0 ? -res : res
        }
        
        static func toHSX(_ storage: SIMD4<Double>, isHSL: Bool = true) -> (hue: Double, saturation: Double, brightness: Double, alpha: Double) {
            let (hue, delta, maxV, minV) = hueChromaMaxMin(red: storage.x, green: storage.y, blue: storage.z)
            if isHSL {
                let lightness = (maxV + minV) / 2
                let saturation = lightness > 0 && lightness < 1 ? delta / (1 - abs(2 * lightness - 1)) : 0
                return (hue, saturation, lightness, storage.w)
            }
            return (hue, maxV != 0 ? delta / maxV : 0, maxV, storage.w)
        }
        
        private static func hueChromaMaxMin(red: Double, green: Double, blue: Double) -> (hue: Double, delta: Double, maxV: Double, minV: Double) {
            let maxV = max(red, green, blue)
            let minV = min(red, green, blue)
            let delta = maxV - minV
            var hue: Double = 0
            if delta > 0 {
                hue = (maxV == red ? (green - blue) / delta
                       : maxV == green ? (blue - red) / delta + 2
                       : (red - green) / delta + 4) / 6
                if hue < 0 { hue += 1 }
            }
            return (hue, delta, maxV, minV)
        }
    }
}

extension ColorMath {
    enum LAB {
        private static let delta = 6.0 / 29.0
        private static let threshold = delta * delta * delta
        private static let k = 3 * delta * delta
        private static let four29 = 4.0 / 29.0
        
        @inline(__always)
        static func f(_ t: Double) -> Double {
            t > threshold ? cbrt(t) : t / k + four29
        }
        
        @inline(__always)
        static func fInv(_ t: Double) -> Double {
            t > delta ? t * t * t : k * (t - four29)
        }
    }
}
