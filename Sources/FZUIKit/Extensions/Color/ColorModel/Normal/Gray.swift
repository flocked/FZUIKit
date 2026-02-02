//
//  ColorModel+Gray.swift
//  
//
//  Created by Florian Zand on 14.12.25.
//

import Foundation
import CoreGraphics
import FZSwiftUtils

extension ColorModels {
    /// The color components for a color in the grayscale color space.
    public struct Grayscale: ColorModel {
        public var animatableData: SIMD2<Double>

        /// The white component of the color.
        public var white: Double {
            get { animatableData.x }
            set { animatableData.x = newValue }
        }
        
        /// The alpha value of the color.
        public var alpha: Double {
            get { animatableData.y }
            set { animatableData.y = newValue.clamped(to: 0...1) }
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
            .init(red: white, green: white, blue: white, alpha: alpha)
        }
        
        /// Creates the color with the specified components.
        public init(white: Double, alpha: Double = 1.0) {
            animatableData = .init(white, alpha)
        }
        
        public init(_ components: [Double]) {
            precondition(components.count >= 1, "You need to provide at least 1 component for a color in grayscale color space.")
            self.init(white: components[0], alpha: components[safe: 1] ?? 1.0)
        }
                        
        public var cgColor: CGColor {
            CGColor(colorSpace: .extendedGray, components:  components.map({CGFloat($0)}))!
        }
    }
}

public extension ColorModel where Self == ColorModels.Grayscale {
    /// Returns the color components for a color in the grayscale color space.
    static func gray(_ components: [Double]) -> Self {
        .init(components)
    }
    
    /// Returns the color components for a color in the grayscale color space.
    static func gray(white: Double, alpha: Double = 1.0) -> Self {
        .init(white: white, alpha: alpha)
    }
}
