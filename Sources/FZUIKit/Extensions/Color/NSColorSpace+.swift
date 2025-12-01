//
//  NSColorSpace+.swift
//
//
//  Created by Florian Zand on 09.03.25.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSColorSpace {
    /// Initializes and returns a color space object initialized from a `CGColorSpace` with the specified name.
    public convenience init?(name: CGColorSpaceName) {
        guard let cgColorSpace = CGColorSpace(name: name) else { return nil }
        self.init(cgColorSpace: cgColorSpace)
    }
    
    /// Returns the color space linearized.
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public var linear: NSColorSpace? {
        guard let colorSpace = cgColorSpace?.linear else { return nil }
        return NSColorSpace(cgColorSpace: colorSpace)
    }
    
    /// Returns the color space non-linearized.
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public var nonLinear: NSColorSpace {
        guard let cgColorSpace = cgColorSpace?.nonLinear else { return self }
        return NSColorSpace(cgColorSpace: cgColorSpace) ?? self
    }
    
    /// Returns the color space extended linearized.
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public var extendedLinear: NSColorSpace? {
        guard let colorSpace = cgColorSpace?.extendedLinear else { return nil }
        return NSColorSpace(cgColorSpace: colorSpace)
    }
    
    /// Returns the color space with a standard range.
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    public var standardRange: NSColorSpace {
        guard let cgColorSpace = cgColorSpace?.standardRange else { return self }
        return NSColorSpace(cgColorSpace: cgColorSpace) ?? self
    }
    
    /// Returns the color space extended.
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public var extendedRange: NSColorSpace? {
        guard let colorSpace = cgColorSpace?.extendedRange else { return nil }
        return NSColorSpace(cgColorSpace: colorSpace)
    }
    
    /// A Boolean value indicating whether the color space uses an extended range.
    public var usesExtendedRange: Bool {
        cgColorSpace?.usesExtendedRange ?? false
    }
    
    /// A Boolean value indicating whether the color space is linear.
    public var isLinear: Bool {
        cgColorSpace?.isLinear ?? false
    }
    
    /// A Boolean value indicating whether the color space uses the ITU-R BT.2100 transfer function.
    @available(macOS 11.0, *)
    public var usesITUR_2100TF: Bool {
        cgColorSpace?.usesITUR_2100TF ?? false
    }
    
    /// A Boolean value indicating whether the color space uses a PQ (Perceptual Quantizer) transfer function.
    @available(macOS 12.0, *)
    public var isPQBased: Bool {
        cgColorSpace?.isPQBased ?? false
    }
    
    /// A Boolean value indicating whether the color space uses a HLG (Hybrid Log-Gamma) transfer function.
    @available(macOS 12.0, *)
    public var isHLGBased: Bool {
        cgColorSpace?.isHLGBased ?? false
    }
    
    /// The base color space of a derived color space, or itself if no base exists.
    @available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, *)
    public var base: NSColorSpace {
        guard let cgColorSpace = cgColorSpace?.base else { return self }
        return NSColorSpace(cgColorSpace: cgColorSpace) ?? self
    }
    
    /// The name of the color space.
    public var name: NSColorSpaceName? {
        guard let name: String = value(forKey: "colorSpaceName") else { return nil }
        return NSColorSpaceName(rawValue: name)
    }
    
    /// Returns all color spaces available on the system that are displayed in the color panel, in the order they are displayed in the color panel.
    public static func allAvailableColorSpaces() -> [NSColorSpace] {
        availableColorSpaces(with: .unknown).sorted(by: \.colorSpaceModel.rawValue)
    }
}

extension NSColorSpace.Model: Swift.CaseIterable, Swift.CustomStringConvertible {
    public var description: String {
        switch self {
        case .gray: return "gray"
        case .rgb: return "rgb"
        case .cmyk: return "cmyk"
        case .lab: return "lab"
        case .deviceN: return "deviceN"
        case .indexed: return "indexed"
        case .patterned: return "patterned"
        default: return "unknown"
        }
    }
    
    public static let allCases: [Self] = [.rgb, .cmyk, .gray,.lab, .deviceN, .indexed, .patterned]
}
#endif
