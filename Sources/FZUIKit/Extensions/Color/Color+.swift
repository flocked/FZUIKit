//
//  Color+.swift
//
//
//  Created by Florian Zand on 06.10.22.
//

import SwiftUI

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

extension Color {
    #if os(macOS)
    /// `NSColor` representation of the color.
    public var nsColor: NSColor {
        NSColor(self)
    }
    #else
    /// `UIColor` representation of the color.
    public var uiColor: UIColor {
        UIColor(self)
    }
    #endif

    var nsUIColor: NSUIColor {
        NSUIColor(self)
    }
    
    /// A random color.
    public static var random: Color {
        NSUIColor.random.swiftUI
    }
    
    /// A random pastel color.
    public static var randomPastel: Color {
        NSUIColor.randomPastel.swiftUI
    }
    
    /// A Boolean value indicating whether the color is light.
    public var isLight: Bool {
        nsUIColor.isLight
    }
    
    /// A Boolean value indicating whether the color is visible (alpha value isn't zero).
    public var isVisible: Bool {
        rgb().alpha != 0.0
    }
}

#if os(macOS) || os(iOS) || os(tvOS)
extension Color {
    /**
     Creates a color that uses the specified block to generate its color data dynamically.
     
     - Parameters:
        - lightColor: The light color.
        - darkColor: The dark color.
     */
    public init(light lightColor: @escaping @autoclosure () -> Color, dark darkColor: @escaping @autoclosure () -> Color) {
        #if os(macOS)
        self.init(nsColor: NSUIColor(light: lightColor().nsUIColor, dark: darkColor().nsUIColor))
        #else
        self.init(uiColor: NSUIColor(light: lightColor().nsUIColor, dark: darkColor().nsUIColor))
        #endif
    }
    
    /// Generates the resolved color for the specified environment.
    func resolvedColor(in environment: EnvironmentValues) -> Color {
        #if os(macOS)
        resolvedColor(for: environment.colorScheme == .light ? .aqua : .darkAqua)
        #else
        resolvedColor(with: environment.colorScheme == .light ? .light : .dark)
        #endif
    }
    
    #if os(macOS)
    /**
     Generates the resolved color for the specified appearance.
     
     - Parameter appearance: The appearance of the resolved color.
     */
    public func resolvedColor(for appearance: NSAppearance = .currentDrawing()) -> Color {
        nsColor.resolvedColor(for: appearance).swiftUI
    }
    
    /**
     Generates the resolved color for the specified appearance provider object (e.g. `NSView`, `NSWindow` or `NSApplication`).
     
     It uses the objects's [effectiveAppearance](https://developer.apple.com/documentation/appkit/nsappearancecustomization/effectiveappearance) for resolving the color.
     
     - Parameter appearanceProvider: The object for the resolved color.
     - Returns: A resolved color for the object.
     */
    public func resolvedColor<AppearanceProvider: NSAppearanceCustomization>(for appearanceProvider: AppearanceProvider) -> Color {
        resolvedColor(for: appearanceProvider.effectiveAppearance)
    }
    #else
    /**
     Returns the version of the current color that results from the specified traits.

     - Parameter traitCollection: v
     */
    public func resolvedColor(with traitCollection: UITraitCollection) -> Color {
        uiColor.resolvedColor(with: traitCollection).swiftUI
    }
    #endif

    /// Returns the dynamic light and dark color variation of the color.
    public var dynamicColors: DynamicColor {
        DynamicColor(nsUIColor.dynamicColors)
    }
    
    /// A Boolean value indicating whether the color contains a different light and dark color variant.
    public var isDynamic: Bool {
        dynamicColors.isDynamic
    }
    
    /// The dynamic light and dark variations of a color.
    public struct DynamicColor {
        /// The light color.
        public let light: Color
        
        /// The dark color.
        public let dark: Color
        
        /// A Boolean value indicating whether the light color differs to the dark color.
        public var isDynamic: Bool {
            light != dark
        }
        
        init(_ colors: NSUIColor.DynamicColor) {
            self.light = colors.light.swiftUI
            self.dark = colors.dark.swiftUI
        }
    }
}
#endif

extension Color: Swift.Encodable, Swift.Decodable {
    public init(from decoder: any Decoder) throws {
        #if os(macOS)
        self.init(nsColor: try NSUIColor(from: decoder))
        #else
        self.init(uiColor: try NSUIColor(from: decoder))
        #endif
    }
    
    public func encode(to encoder: any Encoder) throws {
        try nsUIColor.encode(to: encoder)
    }
}

public extension NSUIColor {
    /// A `SwiftUI` representation of the color.
    var swiftUI: Color {
        #if os(macOS)
        Color(nsColor: self)
        #else
        Color(uiColor: self)
        #endif
    }
}
