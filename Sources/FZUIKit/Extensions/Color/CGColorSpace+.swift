//
//  CGColorSpace+.swift
//  
//
//  Created by Florian Zand on 09.03.25.
//

import CoreGraphics
import FZSwiftUtils

extension CGColorSpace {
    /// Creates a device-dependent RGB color space.
    public static var deviceRGB: CGColorSpace {
        CGColorSpaceCreateDeviceRGB()
    }
    
    /// Creates a device-dependent CMYK color space.
    public static var deviceCMYK: CGColorSpace {
        CGColorSpaceCreateDeviceCMYK()
    }
    
    /// Creates a device-dependent grayscale color space.
    public static var deviceGray: CGColorSpace {
        CGColorSpaceCreateDeviceGray()
    }
    
    /// A Boolean value indicating whether the color space uses an extended range.
    public var usesExtendedRange: Bool {
        CGColorSpaceUsesExtendedRange(self)
    }
    
    /// A Boolean value indicating whether the color space uses the ITU-R BT.2100 transfer function.
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public var usesITUR_2100TF: Bool {
        CGColorSpaceUsesITUR_2100TF(self)
    }
    
    /// A Boolean value indicating whether the color space uses a PQ (Perceptual Quantizer) transfer function.
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    public var isPQBased: Bool {
        CGColorSpaceIsPQBased(self)
    }
    
    /// A Boolean value indicating whether the color space uses a HLG (Hybrid Log-Gamma) transfer function.
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    public var isHLGBased: Bool {
        CGColorSpaceIsHLGBased(self)
    }
    
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

    /// Returns the color space with an extended range.
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public var extended: CGColorSpace? {
        CGColorSpaceCreateExtended(self)
    }
    
    /// Returns the color space with a standard range.
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    public var standardRange: CGColorSpace {
        CGColorSpaceCreateCopyWithStandardRange(self)
    }
    
    /// The base color space of a derived color space, or itself if no base exists.
    @available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, *)
    public var base: CGColorSpace {
        CGColorSpaceCopyBaseColorSpace(self)
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

public extension CFType where Self == CGColorSpace {
    /// Creates a color space with the specified color sync profie.
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    init?(colorSyncProfile: ColorSyncProfile?, options: CFDictionary? = nil) {
        guard let colorSpace = CGColorSpaceCreateWithColorSyncProfile(colorSyncProfile, options) else { return nil }
        self = colorSpace
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
