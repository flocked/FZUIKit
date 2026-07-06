//
//  CGColorSpace+.swift
//  
//
//  Created by Florian Zand on 09.03.25.
//

import CoreGraphics
import FZSwiftUtils
import Foundation
import ColorSync

extension CGColorSpace {
    /// Creates a device-dependent RGB color space.
    public static let deviceRGB = CGColorSpaceCreateDeviceRGB()
    
    /// Creates a device-dependent CMYK color space.
    public static let deviceCMYK = CGColorSpaceCreateDeviceCMYK()
    
    /// Creates a device-dependent grayscale color space.
    public static let deviceGray = CGColorSpaceCreateDeviceGray()
    
    /// A Boolean value indicating whether the color space uses an extended range [-Inf, +Inf].
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
    
    /// Returns a linearized version of the color space.
    public var linear: CGColorSpace? {
        if name as? String == "kCGColorSpaceGenericRGB" {
            return CGColorSpace(name: .genericRGBLinear)
        }
        return CGColorSpaceCreateLinearized(self)
    }
    
    /// Returns a non-linearized version of the color space.
    public var nonLinear: CGColorSpace? {
        guard let name = name as? String, name.contains("Linear") else { return nil }
        return CGColorSpace(name: name.removingOccurrences(of: "Linear") as CFString)
    }

    /// Returns a linearized version of the color space with an extended range  (`[-Inf, +Inf]`).
    public var extendedLinear: CGColorSpace? {
        CGColorSpaceCreateExtendedLinearized(self)
    }
        
    /// Returns the color space with a standard range  (`[0.0, 1.0]`).
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    public var standardRange: CGColorSpace {
        CGColorSpaceCreateCopyWithStandardRange(self)
    }

    /// Returns the color space with an extended range  (`[-Inf, +Inf]`).
    public var extendedRange: CGColorSpace? {
        CGColorSpaceCreateExtended(self)
    }
    
    /**
     Returns the base color space, or the color space without any image-specific metadata.

     If the color space is a pattern or an indexed color space, it's base color space is returned.

     If the color space contains image-specific metadata associated with the gain map, it is returned without the metadata.

     Otherwise the same color space is returned.
     */
    @available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, *)
    public var base: CGColorSpace {
        CGColorSpaceCopyBaseColorSpace(self)
    }
    
    public static func == (lhs: CGColorSpace, rhs: CGColorSpace.Name) -> Bool {
        guard let name = lhs.name as? String else { return false }
        return name == rhs.rawValue
    }
}

public extension CFType where Self == CGColorSpace {
    /// Creates a color space with the specified color sync profie.
    init?(colorSyncProfile: ColorSyncProfile) {
        guard let colorSpace = CGColorSpaceCreateWithColorSyncProfile(colorSyncProfile, nil) else { return nil }
        self = colorSpace
    }
    
    /// Creates an ICC-based color space using the ICC profile contained in the specified data.
    init?(iccData data: Data) {
        self.init(iccData: data as CFData)
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
