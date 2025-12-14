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
    
    /// A Boolean value indicating whether the color space is linear.
    public var isLinear: Bool {
        (name as? String)?.contains("Linear") == true
    }
    
    /// A Boolean value indicating whether the color space uses the ITU-R BT.2100 transfer function.
    public var usesITUR_2100TF: Bool {
        CGColorSpaceUsesITUR_2100TF(self)
    }
    
    /// A Boolean value indicating whether the color space uses a PQ (Perceptual Quantizer) transfer function.
    public var isPQBased: Bool {
        CGColorSpaceIsPQBased(self)
    }
    
    /// A Boolean value indicating whether the color space uses a HLG (Hybrid Log-Gamma) transfer function.
    public var isHLGBased: Bool {
        CGColorSpaceIsHLGBased(self)
    }
    
    /// Returns a linear version of the color space.
    public var linear: CGColorSpace? {
        if name as? String == "kCGColorSpaceGenericRGB" {
            return CGColorSpace(name: .genericRGBLinear)
        }
        return CGColorSpaceCreateLinearized(self)
    }
    
    /// Returns a non-linear version of the color space.
    public var nonLinear: CGColorSpace? {
        guard let name = name as? String, isLinear else { return nil }
        return CGColorSpace(name: name.removingOccurrences(of: "Linear") as CFString)
    }

    /// Returns a linear version of the color space with extended range.
    public var extendedLinear: CGColorSpace? {
        CGColorSpaceCreateExtendedLinearized(self)
    }
        
    /// Returns the color space with a standard range.
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    public var standardRange: CGColorSpace {
        CGColorSpaceCreateCopyWithStandardRange(self)
    }

    /// Returns the color space with an extended range.
    public var extendedRange: CGColorSpace? {
        CGColorSpaceCreateExtended(self)
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
    
    public static func == (lhs: CGColorSpace, rhs: CGColorSpaceName) -> Bool {
        guard let name = lhs.name as? String else { return false }
        return name == rhs.rawValue
    }
}

public extension CFType where Self == CGColorSpace {
    /// Creates a color space with the specified color sync profie.
    init?(colorSyncProfile: ColorSyncProfile?, options: CFDictionary? = nil) {
        guard let colorSpace = CGColorSpaceCreateWithColorSyncProfile(colorSyncProfile, options) else { return nil }
        self = colorSpace
    }
}

extension CGColorSpaceModel: Swift.CustomStringConvertible {
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
    
    ///The number of color components in a color space with this model.
    public var numberOfComponents: Int {
        switch self {
        case .monochrome: return 1
        case .rgb, .lab, .XYZ: return 3
        case .cmyk: return 4
        default: return 0
        }
    }
}
