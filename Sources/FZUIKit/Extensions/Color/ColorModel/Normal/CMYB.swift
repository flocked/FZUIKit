//
//  ColorModel+CMYB.swift
//  
//
//  Created by Florian Zand on 14.12.25.
//

import Foundation
import FZSwiftUtils

extension ColorModels {
    /// The color components for a color in the generic CMYK color space.
    public struct CMYK: ColorModel {
        public var animatableData: SIMD8<Double>
        
        /// The cyan component of the color.
        public var cyan: Double {
            get { animatableData[0] }
            set { animatableData[0] = newValue }
        }
        
        /// The magenta component of the color.
        public var magenta: Double {
            get { animatableData[1] }
            set { animatableData[1] = newValue.clamped(to: 0...1) }
        }
        
        /// The yellow component of the color.
        public var yellow: Double {
            get { animatableData[2] }
            set { animatableData[2] = newValue.clamped(to: 0...1) }
        }
        
        /// The black component of the color.
        public var black: Double {
            get { animatableData[3] }
            set { animatableData[3] = newValue.clamped(to: 0...1) }
        }
        
        /// The alpha value of the color.
        public var alpha: Double {
            get { animatableData[4] }
            set { animatableData[4] = newValue.clamped(to: 0...1) }
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
                black = newValue[safe: 3] ?? black
                alpha = newValue[safe: 4] ?? alpha
            }
        }
        
        /// The color in the sRGB color space.
        public var rgb: SRGB {
            let cmy = SIMD3(animatableData[0], animatableData[1], animatableData[2])
            let rgb = (SIMD3(1.0, 1.0, 1.0) - cmy) * (1.0 - black)
            return .init(red: rgb[0], green: rgb[1], blue: rgb[2], alpha: alpha)
        }
        
        /// Creates the color with the specified components.
        public init(cyan: Double, magenta: Double, yellow: Double, black: Double, alpha: Double = 1.0) {
            self.animatableData = .init(cyan.clamped(to: 0...1), magenta.clamped(to: 0...1), yellow.clamped(to: 0...1), black.clamped(to: 0...1), alpha.clamped(to: 0...1), 0, 0, 0)
        }
        
        public init(_ components: [Double]) {
            precondition(components.count >= 4, "You need to provide at least 4 components for a color in CMYK color space.")
            self.init(cyan: components[0], magenta: components[1], yellow: components[2], black: components[3], alpha: components[safe: 4] ?? 1.0)
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
