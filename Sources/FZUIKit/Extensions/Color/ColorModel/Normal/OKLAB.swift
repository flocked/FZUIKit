//
//  ColorModel+OKLAB.swift
//  
//
//  Created by Florian Zand on 14.12.25.
//

import Foundation
import FZSwiftUtils

extension ColorModels {
    /// The color components for a color in the OKLAB color space.
    public struct OKLAB: ColorModel {
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
            "OKLAB(lightness: \(lightness), greenRed: \(greenRed), blueYellow: \(blueYellow), alpha: \(alpha))"
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
        
        private static let toLMS: [SIMD3<Double>] = [
            SIMD3(1.0,  0.3963377774,  0.2158037573),
            SIMD3(1.0, -0.1055613458, -0.0638541728),
            SIMD3(1.0, -0.0894841775, -1.2914855480)]
        
        private static let toSRGB: [SIMD3<Double>] = [
            SIMD3( 4.0767416621, -3.3077115913,  0.2309699292),
            SIMD3(-1.2684380046,  2.6097574011, -0.3413193965),
            SIMD3(-0.0041960863, -0.7034186147,  1.7076147010)]
        
        /// The color in the sRGB color space.
        public var rgb: SRGB {
            let oklab = SIMD3(lightness, greenRed, blueYellow)
            var lms = SIMD3(oklab.dot(Self.toLMS[0]), oklab.dot(Self.toLMS[1]), oklab.dot(Self.toLMS[2]))
            lms = lms * lms * lms
            let red = lms.dot(Self.toSRGB[0])
            let green = lms.dot(Self.toSRGB[1])
            let blue = lms.dot(Self.toSRGB[2])
            return .init(linearRed: red, green: green, blue: blue, alpha: alpha)
        }
        
        /// The color in the OKLCH color space.
        public var oklch: OKLCH {
            let chroma = ColorMath.chromaFromCartesian(greenRed, blueYellow)
            let hue = ColorMath.hueFromCartesian(blueYellow, greenRed)
            return .init(lightness: lightness, chroma: chroma, hue: hue, alpha: alpha)
        }
        
        /// The color in the OKHSB color space.
        public var okhsb: OKHSB {
            let (hue, saturation, brightness) = ColorMath.OKLab.toHSX(self)
            return .init(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        }
        
        /// The color in the OKHSL color space.
        public var okhsl: OKHSL {
            let (hue, saturation, lightness) = ColorMath.OKLab.toHSX(self, hsl: true)
            return .init(hue: hue, saturation: saturation, lightness: lightness, alpha: alpha)
        }
        
        /// Creates the color with the specified components.
        public init(lightness: Double, greenRed: Double, blueYellow: Double, alpha: Double = 1.0) {
            animatableData = .init(lightness, greenRed, blueYellow, alpha)
        }
        
        public init(_ components: [Double]) {
            precondition(components.count >= 3, "You need to provide at least 3 components for a color in OKLAB color space.")
            self.init(lightness: components[0], greenRed: components[1], blueYellow: components[2], alpha: components[safe: 3] ?? 0.0)
        }
    }
}

public extension ColorModel where Self == ColorModels.OKLAB {
    /// Returns the color components for a color in the OKLAB color space.
    static func oklab(_ components: [Double]) -> Self {
        .init(components)
    }
    
    /// Returns the color components for a color in the OKLAB color space.
    static func oklab(lightness: Double, greenRed: Double, blueYellow: Double, alpha: Double = 1.0) -> Self {
        .init(lightness: lightness, greenRed: greenRed, blueYellow: blueYellow, alpha: alpha)
    }
}

extension ColorMath {
    enum OKLab {
        static func fromHSX(_ storage: SIMD4<Double>, hsl: Bool) -> ColorModels.OKLAB {
            let (hue, saturation, lightOrValue, alpha) = (storage.x, storage.y, storage.z, storage.w)            // Unit vector along hue
            let aUnit = cos(2.0 * .pi * hue)
            let bUnit = sin(2.0 * .pi * hue)
            
            // Max saturation info
            let stMax = getStMax(a: aUnit, b: bUnit)
            let sMax = stMax[0]
            let T = stMax[1]
            let s0 = 0.5
            let k = 1 - s0 / sMax
            
            // Compute perceptual C
            let Cv = saturation != 0 ? (T * s0 * saturation) / ((s0 + T) - k * T * saturation) : 0
            
            // Compute L for HSL or HSB
            let Lv: Double
            if hsl {
                // Undo toe for HSL lightness
                Lv = toeInv(lightOrValue)
            } else {
                // For HSB, lightOrValue is already Lv (brightness)
                Lv = lightOrValue
            }

            // Adjust C to match linear sRGB gamut
            let Cvt = Cv
            let rgbLinear = ColorModels.OKLAB(lightness: Lv, greenRed: aUnit * Cvt, blueYellow: bUnit * Cvt).rgb
            let maxRGB = max(rgbLinear.linearRed, rgbLinear.linearGreen, rgbLinear.linearBlue)
            let scaleL = maxRGB > 1e-6 ? pow(1.0 / maxRGB, 1.0 / 3.0) : 1.0
            
            let LFinal = Lv * scaleL
            let CFinal = Cvt * scaleL
            
            return ColorModels.OKLAB(lightness: LFinal, greenRed: CFinal * aUnit, blueYellow: CFinal * bUnit, alpha: alpha)
        }
        
        private static func getStMax(a: Double, b: Double, cusp: [Double]? = nil) -> [Double] {
            let _cusp = cusp ?? findCusp(a: a, b: b)
            let l = _cusp[0]
            let c = _cusp[1]
            return [c / l, c / (1 - l)]
        }
        
        private static func toeInv(_ x: Double) -> Double {
            let k1 = 0.206
            let k2 = 0.03
            let k3 = (1 + k1) / (1 + k2)
            return (x * x + k1 * x) / (k3 * (x + k2))
        }
        
        private static func findCusp(a: Double, b: Double) -> [Double] {
            let sCusp = computeMaxSaturation(a, b)
            let rgb = ColorModels.OKLAB(lightness: 1, greenRed: sCusp * a, blueYellow: sCusp * b).rgb
            let maxL = max(rgb.linearRed, max(rgb.linearGreen, rgb.linearBlue))
            let lCusp = maxL > 1e-6 ? pow(1.0 / maxL, 1.0/3.0) : 1.0
            return [lCusp, lCusp * sCusp]
        }
        
        static func toHSX(_ oklab: ColorModels.OKLAB, hsl: Bool = false) -> (hue: Double, saturation: Double, light: Double) {
            let C = chromaFromCartesian(oklab.greenRed, oklab.blueYellow)

            let aUnit = C != 0 ? oklab.greenRed / C : 1
            let bUnit = C != 0 ? oklab.blueYellow / C : 1

            let hue = hueFromCartesian(oklab.blueYellow, oklab.greenRed)

            let stMax = getStMax(a: aUnit, b: bUnit)
            let sMax = stMax[0]
            let T = stMax[1]
            let s0 = 0.5
            let k = 1 - s0 / sMax

            let Lv = oklab.lightness
            let Cv = C

            let Lvt = toeInv(Lv)
            let Cvt = Lv != 0 ? (Cv * Lvt) / Lv : 0
            
            // Scale to fit linear sRGB gamut
            let rgbLinear = ColorModels.OKLAB(lightness: Lvt, greenRed: aUnit * Cvt, blueYellow: bUnit * Cvt).rgb
            let maxRGB = max(rgbLinear.linearRed, rgbLinear.linearGreen, rgbLinear.linearBlue)
            let scaleL = maxRGB > 1e-6 ? pow(1.0 / maxRGB, 1.0 / 3.0) : 1.0
           
            let saturation = Cvt != 0 ? ((s0 + T) * Cvt) / (T * s0 + T * k * Cvt) : 0
            return (hue, saturation, hsl ? toe(Lvt * scaleL) : Lvt * scaleL)
        }

        private static func computeMaxSaturation(_ a: Double, _ b: Double) -> Double {
            let k0, k1, k2, k3, k4, wl, wm, ws: Double
            if (-1.88170328 * a - 0.80936493 * b > 1) {
                (k0, k1, k2, k3, k4) = (1.19086277, 1.76576728, 0.59662641, 0.75515197, 0.56771245)
                (wl, wm, ws) = (4.0767416621, -3.3077115913, 0.2309699292)
            } else if (1.81444104 * a - 1.19445276 * b > 1) {
                (k0, k1, k2, k3, k4) = (0.73956515, -0.45954404, 0.08285427, 0.1254107, 0.14503204)
                (wl, wm, ws) = (-1.2684380046, 2.6097574011, -0.3413193965)
            } else {
                (k0, k1, k2, k3, k4) = (1.35733652, -0.00915799, -1.1513021, -0.50559606, 0.00692167)
                (wl, wm, ws) = (-0.0041960863, -0.7034186147, 1.707614701)
            }
                
            var s = k0 + (k1 * a) + (k2 * b) + (k3 * a * a) + (k4 * a * b)
            let kl = 0.3963377774 * a + 0.2158037573 * b
            let km = -0.1055613458 * a - 0.0638541728 * b
            let ks = -0.0894841775 * a - 1.291485548 * b
                
            for _ in 0..<1 { // Halley step
                let l_ = 1 + s * kl, m_ = 1 + s * km, s_ = 1 + s * ks
                let l = l_*l_*l_, m = m_*m_*m_, sc = s_*s_*s_
                let f = wl*l + wm*m + ws*sc
                let f1 = 3 * (wl*kl*l_*l_ + wm*km*m_*m_ + ws*ks*s_*s_)
                let f2 = 6 * (wl*kl*kl*l_ + wm*km*km*m_ + ws*ks*ks*s_)
                s = s - (f * f1) / (f1 * f1 - 0.5 * f * f2)
            }
            return s
        }
    }
}
