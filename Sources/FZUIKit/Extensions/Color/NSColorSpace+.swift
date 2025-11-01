//
//  NSColorSpace+.swift
//
//
//  Created by Florian Zand on 09.03.25.
//

#if os(macOS)
import AppKit

extension NSColorSpace {
    /// Initializes and returns a color space object initialized from a `CGColorSpace` with the specified name.
    public convenience init?(name: CGColorSpaceName) {
        guard let cgColorSpace = CGColorSpace(name: name) else { return nil }
        self.init(cgColorSpace: cgColorSpace)
    }
    
    /// Returns the color space linearized.
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public var linearized: NSColorSpace? {
        guard let colorSpace = cgColorSpace?.linearized else { return nil }
        return NSColorSpace(cgColorSpace: colorSpace)
    }
    
    /// Returns the color space non-linearized.
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public var nonLinearized: NSColorSpace {
        guard let cgColorSpace = cgColorSpace?.nonLinearized else { return self }
        return NSColorSpace(cgColorSpace: cgColorSpace) ?? self
    }
    
    /// Returns the color space extended linearized.
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public var extendedLinearized: NSColorSpace? {
        guard let colorSpace = cgColorSpace?.extendedLinearized else { return nil }
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
    
    /// Calibrated color space with red, green, blue, and alpha components.
    public static var calibratedRGB: NSColorSpace {
        NSColorSpace(name: .genericRGB) ?? .deviceRGB
    }
    
    /// Calibrated color space with white and alpha components (pure white is 1.0)
    public static var calibratedGray: NSColorSpace {
        NSColorSpace(name: .genericGray) ?? .deviceGray
    }
    
    /// Returns all color spaces available on the system that are displayed in the color panel, in the order they are displayed in the color panel.
    public static func allAvailableColorSpaces() -> [NSColorSpace] {
        availableColorSpaces(with: .unknown).sorted(by: \.colorSpaceModel.rawValue)
    }
    
    /*
    /// Returns the NSColorSpace with the specified name.
    public static func named(_ name: NSColorSpaceName) -> NSColorSpace? {
        for model in NSColorSpace.Model.allCases {
            if let colorSpace = cachedAvailableColorSpaces(for: model).first(where: { $0.name == name }) {
                return colorSpace
            }
        }
        return nil
    }
    
    private static func cachedAvailableColorSpaces(with model: Model) -> [NSColorSpace] {
        if let spaces = cachedAvailableColorSpaces[model] {
            return spaces
        }
        let spaces = NSColorSpace.availableColorSpaces(with: model)
        cachedAvailableColorSpaces[model] = spaces
        return spaces
    }
    
    private static var cachedAvailableColorSpaces: [Model: [NSColorSpace]] {
        get { getAssociatedValue("cachedAvailableColorSpaces") ?? [:] }
        set { setAssociatedValue(newValue, key: "cachedAvailableColorSpaces") }
    }
     */
}

extension NSColorSpace.Model: CaseIterable {
    public static let allCases: [Self] = [.rgb, .cmyk, .gray,.lab, .deviceN, .indexed, .patterned]
}
#endif
