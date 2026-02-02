//
//  ColorModels+DisplayP3.swift
//
//
//  Created by Florian Zand on 24.01.26.
//

import Foundation
import CoreGraphics
import FZSwiftUtils

extension ColorModels {
    /// The color components for a color in the DisplayP3 color space.
    public struct DisplayP3: ColorModel {
        public var animatableData: SIMD4<Double>
        
        /// The red component of the color.
        public var red: Double {
            get { animatableData.x }
            set { animatableData.x = newValue }
        }
        
        /// The green component of the color.
        public var green: Double {
            get { animatableData.y }
            set { animatableData.y = newValue }
        }
        
        /// The blue component of the color.
        public var blue: Double {
            get { animatableData.z }
            set { animatableData.z = newValue }
        }
        
        /// The alpha value of the color.
        public var alpha: Double {
            get { animatableData.w }
            set { animatableData.w = newValue.clamped(to: 0...1) }
        }
        
        /// The linear red component of the color.
        public var linearRed: Double {
            get { ColorMath.RGB.toLinear(red) }
            set { red = ColorMath.RGB.toNonlinear(newValue) }
        }
        
        /// The linear green component of the color.
        public var linearGreen: Double {
            get { ColorMath.RGB.toLinear(green) }
            set { green = ColorMath.RGB.toNonlinear(newValue) }
        }
        
        /// The linear blue component of the color.
        public var linearBlue: Double {
            get { ColorMath.RGB.toLinear(blue) }
            set { blue = ColorMath.RGB.toNonlinear(newValue) }
        }
        
        public var components: [Double] {
            get { [red, green, blue, alpha] }
            set {
                red = newValue[safe: 0] ?? red
                green = newValue[safe: 1] ?? green
                blue = newValue[safe: 2] ?? blue
                alpha = newValue[safe: 3] ?? alpha
            }
        }
        
        public var description: String {
            "DisplayP3(red: \(red), green: \(green), blue: \(blue), alpha: \(alpha))"
        }
        
        public var cgColor: CGColor {
            CGColor(colorSpace: .extendedDisplayP3, components: components.map({CGFloat($0)}))!
        }
        
        private static let toXZY: [SIMD3<Double>] = [
            SIMD3(0.48657095, 0.26566769, 0.19821729),
            SIMD3(0.22897456, 0.69173852, 0.07928691),
            SIMD3(0.0,        0.04511338, 1.04394437)]
        
        /// The color in the XYZ color space.
        public var xyz: XYZ {
            let rgb = SIMD3(linearRed, linearGreen, linearBlue)
            let x = rgb.dot(Self.toXZY[0])
            let y = rgb.dot(Self.toXZY[1])
            let z = rgb.dot(Self.toXZY[2])
            return .init(x: x, y: y, z: z, alpha: alpha)
        }

        /// The color in the HSB color space.
        public var hsb: HSB {
            let hsb = ColorMath.RGB.toHSX(animatableData, isHSL: false)
            return .init(hue: hsb.hue, saturation: hsb.saturation, brightness: hsb.brightness, alpha: hsb.alpha)
        }
        
        /// The color in the HSL color space.
        public var hsl: HSL {
            let hsl = ColorMath.RGB.toHSX(animatableData, isHSL: true)
            return .init(hue: hsl.hue, saturation: hsl.saturation, lightness: hsl.brightness, alpha: hsl.alpha)
        }
        
        /// Creates the color with the specified components.
        public init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
            animatableData = .init(red, green, blue, alpha)
        }
        
        /// Creates the color with the specified linear components.
        public init(linearRed red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
            self.init(red: ColorMath.RGB.toNonlinear(red), green: ColorMath.RGB.toNonlinear(green), blue: ColorMath.RGB.toNonlinear(blue), alpha: alpha)
        }
        
        public init(_ components: [Double]) {
            precondition(components.count >= 3, "You need to provide at least 3 components for a color in SRGB color space.")
            self.init(red: components[0], green: components[1], blue: components[2], alpha: components[safe: 3] ?? 1.0)
        }
    }
}

public extension ColorModel where Self == ColorModels.DisplayP3 {
    /// Returns the color components for a color in the Display P3 color space.
    static func displayP3(_ components: [Double]) -> Self {
        .init(components)
    }
    
    /// Returns the color components for a color in the Display P3 color space.
    static func displayP3(red: Double, green: Double, blue: Double, alpha: Double = 1.0) -> Self {
        .init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /// Returns the color components for a color in the Display P3 color space.
    static func displayP3(linearRed red: Double, green: Double, blue: Double, alpha: Double = 1.0) -> Self {
        .init(linearRed: red, green: green, blue: blue, alpha: alpha)
    }
}
