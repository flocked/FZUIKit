//
//  CGColorSpace+.swift
//  
//
//  Created by Florian Zand on 09.03.25.
//

#if os(macOS)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

extension CGColorSpace {
    /// The color space that represents a calibrated or device-dependent RGB color space.
    public static let deviceRGB = "kCGColorSpaceDeviceRGB" as CFString
    /// The color space that represents a calibrated or device-dependent CMYK color space.
    public static let deviceCMYK = "kCGColorSpaceDeviceCMYK" as CFString
    /// The color space that represents a calibrated or device-dependent gray color space.
    public static let deviceGray = "kCGColorSpaceDeviceGray" as CFString
    
    /// Returns the color space linearized.
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public var linearized: CGColorSpace? {
        CGColorSpaceCreateLinearized(self)
    }
    
    /// Returns the color space extended linearized.
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public var extendedLinearized: CGColorSpace? {
        CGColorSpaceCreateExtendedLinearized(self)
    }
    
    /// Returns the color space extended.
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public var extended: CGColorSpace? {
        CGColorSpaceCreateExtended(self)
    }
}

extension CGColorSpaceModel: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknown: return "unknown"
        case .monochrome: return "monochrome"
        case .rgb: return "rgb"
        case .cmyk: return "cmyk"
        case .lab: return "lab"
        case .deviceN: return "deviceN"
        case .indexed: return "indexed"
        case .pattern: return "pattern"
        case .XYZ: return "XYZ"
        default: return "unknown(\(rawValue))"
        }
    }
}
