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

    /// Returns the available system color spaces for the specified model
    public func availableColorSpaces(with model: CGColorSpaceModel) -> [CGColorSpace] {
        var names: [String] = []
        switch model {
        case .monochrome:
            names = ["kCGColorSpaceExtendedGray", "kCGColorSpaceExtendedLinearGray", "kCGColorSpaceGenericGrayGamma2_2", "kCGColorSpaceLinearGray", "kCGColorSpaceDeviceGray"]
        case .rgb:
            names = ["kCGColorSpaceACESCGLinear", "kCGColorSpaceAdobeRGB1998", "kCGColorSpaceCoreMedia709", "kCGColorSpaceDCIP3", "kCGColorSpaceDisplayP3", "kCGColorSpaceDisplayP3_HLG", "kCGColorSpaceDisplayP3_PQ", "kCGColorSpaceDisplayP3_PQ", "kCGColorSpaceExtendedDisplayP3", "kCGColorSpaceExtendedITUR_2020", "kCGColorSpaceExtendedLinearDisplayP3", "kCGColorSpaceExtendedLinearITUR_2020", "kCGColorSpaceExtendedLinearSRGB", "kCGColorSpaceExtendedSRGB", "kCGColorSpaceGenericRGBLinear", "kCGColorSpaceITUR_2020", "kCGColorSpaceITUR_2020_sRGBGamma", "kCGColorSpaceITUR_2100_HLG", "kCGColorSpaceITUR_2100_HLG", "kCGColorSpaceITUR_2100_PQ", "kCGColorSpaceITUR_2100_PQ", "kCGColorSpaceITUR_2100_PQ", "kCGColorSpaceITUR_709", "kCGColorSpaceITUR_709_HLG", "kCGColorSpaceITUR_709_PQ", "kCGColorSpaceLinearDisplayP3", "kCGColorSpaceLinearITUR_2020", "kCGColorSpaceLinearSRGB", "kCGColorSpaceROMMRGB", "kCGColorSpaceSRGB", "kCGColorSpaceDeviceRGB"]
        case .cmyk:
            names = ["kCGColorSpaceGenericCMYK", "kCGColorSpaceDeviceCMYK"]
        case .lab:
            names = ["kCGColorSpaceGenericLab"]
        case .XYZ:
            names = ["kCGColorSpaceGenericXYZ"]
        case .pattern:
            names = ["kCGColorSpaceColoredPattern"]
        default: break
        }
        return names.map({ $0 as CFString }).compactMap({ CGColorSpace(name: $0) })
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
