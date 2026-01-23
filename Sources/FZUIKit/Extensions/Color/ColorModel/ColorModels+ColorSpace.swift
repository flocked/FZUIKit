//
//  ColorModels+ColorSpace.swift
//  
//
//  Created by Florian Zand on 14.12.25.
//

import Foundation
import CoreGraphics

extension ColorModels {
    /// Represents a color space.
    public enum ColorSpace: String, Equatable, Hashable, Sendable, CustomStringConvertible {
        /// sRGB.
        case srgb
        /// HSL.
        case hsl
        /// HSB.
        case hsb
        /// OKLAB.
        case oklab
        /// OKLCH.
        case oklch
        /// XYZ.
        case xyz
        /// LAB.
        case lab
        /// Gray.
        case gray
        /// CMYK.
        case cmyk
        
        public var description: String {
           rawValue
        }
    }
}


/*
extension ColorModels {
    /// Represents a color space.
    public struct ColorSpace: CustomStringConvertible, Equatable, Hashable {
        /// The name of the color space.
        public let name: String
        /// The number of components of the color space.
        public let numberOfComponents: Int
        /// The `CGColorSpace` of the color space.
        public let cgColorSpace: CGColorSpace

        public var description: String { name }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(name)
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.name == rhs.name
        }
        
        /// sRGB color space.
        public static let srgb = Self("sRGB")
        /// HSL color space.
        public static let hsl = Self("HSL")
        /// HSB color space.
        public static let hsb = Self("HSB")
        /// OKLAB color space.
        public static let oklab = Self("OKLAB")
        /// OKLCH color space.
        public static let oklch = Self("OKLCH")
        /// XZY color space.
        public static let xyz = Self("XYZ")
        /// LAB color space.
        public static let lab = Self("LAB")
        /// Gray color space.
        public static let gray = Self("Gray", numberOfComponents: 2, cgColorSpace: CGColorSpace(name: .extendedGray)!)
        /// CMYK color space.
        public static let cmyk = Self("CMYK", numberOfComponents: 5, cgColorSpace: CGColorSpace(name: .genericCMYK)!)
        
        init(_ name: String, numberOfComponents: Int = 4, cgColorSpace: CGColorSpace = CGColorSpace(name: .extendedSRGB)!) {
            self.name = name
            self.numberOfComponents = numberOfComponents
            self.cgColorSpace = cgColorSpace
        }
    }
}
*/
