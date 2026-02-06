//
//  ColorModel+ColorSpace.swift
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
        /// OKHSB.
        case okhsb
        /// OKHSL
        case okhsl
        /// XYZ.
        case xyz
        /// LAB.
        case lab
        /// LCH.
        case lch
        /// LUV.
        case luv
        /// HPLUV.
        case hpluv
        /// Grayscale.
        case gray
        /// Generic CMYK.
        case cmyk
        /// Display P3.
        case displayP3
        /// HWB.
        case hwb
        /// LCHUV.
        case lchuv
        /// HSLUV.
        case hsluv
        /// JZCZHZ.
        case jzczhz
        /// JZAZBZ.
        case jzazbz

        public var description: String { rawValue }
    }
    
    ///  The mode used to convert a color to grayscale.
    public enum GrayscalingMode: String, Hashable {
        /// Linear relative luminance (XYZ Y value).
        case luminance
        /// Perceptually correct sRGB gamma-corrected luminance.
        case perceptual
        /// HSL lightness value.
        case lightness
        /// Average of RGB channels.
        case average
        /// HSB/HSV brightness value.
        case value
    }
}
