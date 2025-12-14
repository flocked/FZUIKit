//
//  ColorModel+Gray.swift
//  FZUIKit
//
//  Created by Florian Zand on 14.12.25.
//

import Foundation
import CoreGraphics
import FZSwiftUtils

extension ColorComponents {
    /// The color components for a color in the grayscale color space.
    public struct Gray: ColorModelInternal {
        /// The white component of the color.
        public var white: Double
        /// The alpha value of the color.
        public var alpha: Double {
            didSet { alpha = alpha.clamped(to: 0...1) }
        }
        
        public var components: [Double] { [white, alpha] }
        
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
        
        /// Creates the color with the specified components.
        public init(white: Double, alpha: Double = 1.0) {
            self.white = white
            self.alpha = alpha
        }
        
        public init(_ components: [Double]) {
            precondition(components.count >= 1, "You need to provide at least 1 component for a color in grayscale color space.")
            self.init(white: components[0], alpha: components[safe: 1] ?? 1.0)
        }
                
        public static let colorSpace = CGColorSpace(name: .extendedGray)!
    }
}

public extension ColorModel where Self == ColorComponents.Gray {
    /// Returns the color components for a color in the grayscale color space.
    static func gray(_ components: [Double]) -> Self {
        .init(components)
    }
    
    /// Returns the color components for a color in the grayscale color space.
    static func gray(white: Double, alpha: Double = 1.0) -> Self {
        .init(white: white, alpha: alpha)
    }
}
