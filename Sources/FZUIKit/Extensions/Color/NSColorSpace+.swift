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
    
    /// Returns the color space extended linearized.
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public var extendedLinearized: NSColorSpace? {
        guard let colorSpace = cgColorSpace?.extendedLinearized else { return nil }
        return NSColorSpace(cgColorSpace: colorSpace)
    }
    
    /// Returns the color space extended.
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public var extended: NSColorSpace? {
        guard let colorSpace = cgColorSpace?.extended else { return nil }
        return NSColorSpace(cgColorSpace: colorSpace)
    }
}

#endif
