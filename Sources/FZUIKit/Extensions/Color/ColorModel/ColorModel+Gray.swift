//
//  ColorModel+Gray.swift
//  
//
//  Created by Florian Zand on 14.12.25.
//

import Foundation
import CoreGraphics

extension ColorModels {
    /// The color components for a color in the grayscale color space.
    public struct Gray: ColorModel {
        /// The white component of the color.
        public var white: Double
        /// The alpha value of the color.
        public var alpha: Double {
            didSet { alpha = alpha.clamped(to: 0...1) }
        }
        
        public var components: [Double] {
            get { [white, alpha] }
            set {
                white = newValue[safe: 0] ?? white
                alpha = newValue[safe: 1] ?? alpha
            }
        }
        
        public var description: String {
            "Gray(white: \(white), alpha: \(alpha))"
        }
        
        /// The color in the sRGB color space.
        public var rgb: SRGB {
            SRGB(red: white, green: white, blue: white, alpha: alpha)
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
        
        /// The color inverted.
        public var inverted: Self {
            Self.init(white: 1.0-white, alpha: alpha)
        }
        
        /// Creates the color with the specified components.
        public init(white: Double, alpha: Double = 1.0) {
            self.white = white
            self.alpha = alpha
        }
        
        public init(_ components: [Double]) {
            precondition(components.count >= 1, "You need to provide at least 1 component for a color in grayscale color space.")
            self.init(white: components[0], alpha: components[safe: 1] ?? 1.0)
        }
                        
        public var cgColor: CGColor {
            CGColor(colorSpace: CGColorSpace(name: .extendedGray)!, components:  components.map({CGFloat($0)}))!
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

public extension ColorModel where Self == ColorModels.Gray {
    /// Returns the color components for a color in the grayscale color space.
    static func gray(_ components: [Double]) -> Self {
        .init(components)
    }
    
    /// Returns the color components for a color in the grayscale color space.
    static func gray(white: Double, alpha: Double = 1.0) -> Self {
        .init(white: white, alpha: alpha)
    }
}
