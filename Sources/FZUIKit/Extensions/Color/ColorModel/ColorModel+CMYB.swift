//
//  ColorModel+CMYB.swift
//  
//
//  Created by Florian Zand on 14.12.25.
//

import Foundation
import CoreGraphics
import FZSwiftUtils

extension ColorModels {
    /// The color components for a color in the CMYK color space.
    public struct CMYK: ColorModel {
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
            get { [cyan, magenta, yellow, black, alpha] }
            set {
                cyan = newValue[safe: 0] ?? cyan
                magenta = newValue[safe: 1] ?? magenta
                yellow = newValue[safe: 2] ?? yellow
                black = newValue[safe: 2] ?? black
                alpha = newValue[safe: 4] ?? alpha
            }
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
        
        /// The color in the LCH color space.
        public var lch: LCH {
            rgb.lch
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
                
        public var cgColor: CGColor {
            CGColor(colorSpace: CGColorSpace(name: .genericCMYK)!, components:  components.map({CGFloat($0)}))!
        }
        
        /// Returns an Integer representing the color in hex format (e.g. `0x112233`)
        public var hex: Int {
            rgb.hex
        }
        
        /// Returns a hex string representing the color (e.g. `#112233`)
        public var hexString: String {
            rgb.hexString
        }
    }
}

public extension ColorModel where Self == ColorModels.CMYK {
    /// Returns the color components for a color in the CMYK color space.
    static func cmyk(_ components: [Double]) -> Self {
        .init(components)
    }
    
    /// Returns the color components for a color in the CMYK color space.
    static func cmyk(cyan: Double, magenta: Double, yellow: Double, black: Double, alpha: Double = 1.0) -> Self {
        .init(cyan: cyan, magenta: magenta, yellow: yellow, black: black, alpha: alpha)
    }
}
