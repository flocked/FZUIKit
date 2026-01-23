//
//  ColorModel+CMYB.swift
//  
//
//  Created by Florian Zand on 14.12.25.
//

import Foundation
import CoreGraphics
import FZSwiftUtils

extension ColorComponents {
    /// The color components for a color in the CMYK color space.
    public struct CMYK: _ColorModel {
        /// The cyan component of the color.
        public var cyan: Double
        /// The magenta component of the color.
        public var magenta: Double
        /// The yellow component of the color.
        public var yellow: Double
        /// The black component of the color.
        public var black: Double
        /// The alpha value of the color.
        public var alpha: Double {
            didSet { alpha = alpha.clamped(to: 0...1) }
        }
        
        public var description: String {
            "CMYK(cyan: \(cyan), magenta: \(magenta), yellow: \(yellow), black: \(black), alpha: \(alpha))"
        }
        
        public var components: [Double] {
            [cyan, magenta, yellow, black, alpha]
        }
        
        /// The color in the sRGB color space.
        public var rgb: SRGB {
            let k = black
            let r = (1 - cyan) * (1 - k)
            let g = (1 - magenta) * (1 - k)
            let b = (1 - yellow) * (1 - k)
            return SRGB(red: r, green: g, blue: b, alpha: alpha)
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
        
        /// The color in the the XYZ color space.
        public var xyz: XYZ {
            rgb.xyz
        }
        
        /// The color in the the CIE Lab color space.
        public var lab: LAB {
            rgb.lab
        }
        
        /// The color in the grayscale color space.
        public var gray: Gray {
            rgb.gray
        }
        
        /// Creates the color with the specified components.
        public init(cyan: Double, magenta: Double, yellow: Double, black: Double, alpha: Double = 1.0) {
            self.cyan = cyan
            self.magenta = magenta
            self.yellow = yellow
            self.black = black
            self.alpha = alpha
        }
        
        public init(_ components: [Double]) {
            precondition(components.count >= 4, "You need to provide at least 4 components for a color in CMYK color space.")
            self.init(cyan: components[0], magenta: components[1], yellow: components[2], black: components[3], alpha: components[safe: 4] ?? 1.0)
        }
        
        static let colorSpace = CGColorSpace(name: .genericCMYK)!
    }
}

public extension ColorModel where Self == ColorComponents.CMYK {
    /// Returns the color components for a color in the CMYK color space.
    static func cmyk(_ components: [Double]) -> Self {
        .init(components)
    }
    
    /// Returns the color components for a color in the CMYK color space.
    static func cmyk(cyan: Double, magenta: Double, yellow: Double, black: Double, alpha: Double = 1.0) -> Self {
        .init(cyan: cyan, magenta: magenta, yellow: yellow, black: black, alpha: alpha)
    }
}
