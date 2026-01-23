//
//  ColorModel+XYZ.swift
//  
//
//  Created by Florian Zand on 14.12.25.
//

import Foundation
import CoreGraphics
import FZSwiftUtils

extension ColorComponents {
    /// The color components for a color in the XYZ color space.
    public struct XYZ: _ColorModel {
        /// The x component of the color.
        public var x: Double
        /// The y component of the color.
        public var y: Double
        /// The z component of the color.
        public var z: Double
        /// The alpha value of the color.
        public var alpha: Double {
            didSet { alpha = alpha.clamped(to: 0...1) }
        }
        
        public var description: String {
            "XYZ(x: \(x), y: \(y), z: \(z), alpha: \(alpha))"
        }
        
        public var components: [Double] { [x, y, z, alpha] }
        
        /// The color in the sRGB color space.
        public var rgb: SRGB {
            let rL =  3.2404542 * x - 1.5371385 * y - 0.4985314 * z
            let gL = -0.9692660 * x + 1.8760108 * y + 0.0415560 * z
            let bL =  0.0556434 * x - 0.2040259 * y + 1.0572252 * z
            return SRGB(linearRed: rL, green: gL, blue: bL, alpha: alpha)
        }
        
        /// The color in the OKLAB color space.
        public var oklab: OKLAB {
            rgb.oklab
        }
        
        /// The color in the OKLCH color space.
        public var oklch: OKLCH {
            rgb.oklch
        }
        
        /// The color in the HSB color space.
        public var hsb: HSB {
            rgb.hsb
        }
        
        /// The color in the HSL color space.
        public var hsl: HSL {
            rgb.hsl
        }
        
        /// The color in the CMYK color space.
        public var cmyk: CMYK {
            rgb.cmyk
        }
        
        /// The color in the grayscale color space.
        public var gray: Gray {
            rgb.gray
        }
        
        /// The color in the the CIE Lab color space.
        public var lab: LAB {
            let fx = labF(x / D65.Xn)
            let fy = labF(y / D65.Yn)
            let fz = labF(z / D65.Zn)
            return LAB(lightness: 116.0 * fy - 16.0, greenRed: 500.0 * (fx - fy), blueYellow: 200.0 * (fy - fz), alpha: alpha)
        }

        /// Creates the color with the specified components.
        public init(x: Double, y: Double, z: Double, alpha: Double = 1.0) {
            self.x = x
            self.y = y
            self.z = z
            self.alpha = alpha
        }
        
        public init(_ components: [Double]) {
            precondition(components.count >= 3, "You need to provide at least 3 components for a color in XYZ color space.")
            self.init(x: components[0], y: components[1], z: components[2], alpha: components[safe: 3] ?? 0.0)
        }
              
        #if os(macOS)
        var _components: [Double] { rgb.components }
        static let colorSpace = CGColorSpace(name: .extendedSRGB)!
        #else
        var _components: [Double] { components }
        static let colorSpace = CGColorSpace(name: .genericXYZ)!
        #endif
        
        @inline(__always)
        private func labF(_ t: Double) -> Double {
            t > 0.008856451679 ? cbrt(t) : 7.787037037 * t + 16.0 / 116.0
        }
    }
}

public extension ColorModel where Self == ColorComponents.XYZ {
    /// Returns the color components for a color in the XYZ color space.
    static func xyz(_ components: [Double]) -> Self {
        .init(components)
    }
    
    /// Returns the color components for a color in the XYZ color space.
    static func xyz(x: Double, y: Double, z: Double, alpha: Double = 1.0) -> Self {
        .init(x: x, y: y, z: z, alpha: alpha)
    }
}
