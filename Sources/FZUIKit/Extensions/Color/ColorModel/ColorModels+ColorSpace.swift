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
        
        public var description: String { rawValue }
    }
    
    /// Represents a RGB color space.
    public enum RGBColorSpace: String, Equatable, Hashable, Sendable, CustomStringConvertible {
        /// sRGB color space with standard range.
        case standard
        /// sRGB color space with extended range.
        case extended
        /// Calibrated or device-dependent RGB color space.
        case device
        /// Display P3 color space.
        case displayP3
        /// Display P3 color space with extended range.
        case extendedDisplayP3
        
        
        public var description: String { rawValue }
        
        var isExtended: Bool {
            self == .extended || self == .extendedDisplayP3
        }
        
        init?(_ color: CGColor) {
            switch color.colorSpace {
            case nil: return nil
            case .sRGB: self = .standard
            case .extendedSRGB: self = .extended
            case .deviceRGB: self = .device
            case .displayP3: self = .displayP3
            case .extendedDisplayP3: self = .extendedDisplayP3
            default: return nil
            }
        }
                
        var colorSpace: CGColorSpace? {
            switch self {
            case .standard: return .sRGB
            case .extended: return .extendedSRGB
            case .device: return .deviceRGB
            case .displayP3: return .displayP3
            case .extendedDisplayP3: return .extendedDisplayP3
            }
        }
    }
}

fileprivate extension CGColorSpace {
    static let sRGB = CGColorSpace(name: .sRGB)
    static let extendedSRGB = CGColorSpace(name: .extendedSRGB)
    static let displayP3 = CGColorSpace(name: .displayP3)
    static let extendedDisplayP3 = CGColorSpace(name: .extendedDisplayP3)
}
