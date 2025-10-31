//
//  NSColor+.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

public extension NSColor {
    /**
     Creates a dynamic catalog color with the specified light and dark color.
     
     - Parameters:
        - name: The name of the color.
        - lightColor: The light color.
        - darkColor: The dark color.
     */
    convenience init(name: NSColor.Name? = nil, light lightColor: @escaping @autoclosure () -> NSColor, dark darkColor: @escaping @autoclosure () -> NSColor) {
        self.init(name: name, dynamicProvider: { appereance in
            appereance.isLight ? lightColor() : darkColor()
        })
    }
    
    /// Returns the dynamic light and dark colors.
    var dynamicColors: (light: NSColor, dark: NSColor) {
        (resolvedColor(for: .aqua), resolvedColor(for: .darkAqua))
    }
    
    /**
     Generates the resolved color for the specified appearance.
     
     - Parameter appearance: The appearance of the resolved color.
     */
    func resolvedColor(for appearance: NSAppearance? = nil) -> NSColor {
        resolvedColor(for: appearance, colorSpace: nil) ?? self
    }
    
    /**
     Generates the resolved color for the specified appearance and color space. If color space is `nil`, the color resolves to the first compatible color space.
     
     - Parameters:
        - appearance: The appearance of the resolved color.
        - colorSpace: The color space of the resolved color. If `nil`, the first compatible color space is used.
     - Returns: A color for the appearance and color space.
     */
    func resolvedColor(for appearance: NSAppearance? = nil, colorSpace: NSColorSpace?) -> NSColor? {
        guard type == .catalog else { return nil }
        if let colorSpace = colorSpace {
            return (appearance ?? .current()).performAsCurrentDrawingAppearance {
                usingColorSpace(colorSpace)
            }
        }
        return Self.supportedColorSpaces.lazy.compactMap({ self.resolvedColor(for: appearance, colorSpace: $0) }).first
    }
    
    
    /**
     Generates the resolved color for the specified appearance provider object (e.g. `NSView`, `NSWindow` or `NSApplication`).
     
     It uses the objects's `effectiveAppearance` for resolving the color.
     
     - Parameter appearanceProvider: The object for the resolved color.
     - Returns: A resolved color for the object.
     */
    func resolvedColor<AppearanceProvider>(for appearanceProvider: AppearanceProvider) -> NSColor where AppearanceProvider: NSAppearanceCustomization {
        resolvedColor(for: appearanceProvider.effectiveAppearance)
    }
    
    /// Creates a new color object with a supported color space.
    func withSupportedColorSpace() -> NSColor? {
        guard type == .componentBased || type == .catalog else { return nil }
        guard !Self.supportedColorSpaces.contains(colorSpace) else { return self }
        return Self.supportedColorSpaces.lazy.compactMap({ self.usingColorSpace($0) }).first
    }
    
    /// A `CIColor` representation of the color, or `nil` if the color cannot be accurately represented as `CIColor`.
    var ciColor: CIColor? {
        CIColor(color: self)
    }
    
    /// A Boolean value indicating whether the color has a color space. Accessing `colorSpace` directly crashes if a color doesn't have a color space. Therefore it's recommended to use this property prior.
    var hasColorSpace: Bool {
        type == .componentBased && !String(describing: self).contains("customDynamic")
    }
    
    /// The name of the color.
    var colorName: String? {
        try? NSObject.catchException {
            colorNameComponent
        }
    }
    
    /// The localized version of the color name.
    var localizedColorName: String? {
        try? NSObject.catchException {
            localizedColorNameComponent
        }
    }
    
    /// The catalog containing the color’s name.
    var catalogName: String? {
        try? NSObject.catchException {
            catalogNameComponent
        }
    }
    
    /// The localized version of the catalog name containing the color.
    var localizedCatalogName: String? {
        try? NSObject.catchException {
            localizedCatalogNameComponent
        }
    }
    
    /// Supported color spaces for displaying a color.
    internal static let supportedColorSpaces: [NSColorSpace] = [.deviceRGB, .sRGB, .extendedSRGB, .genericRGB, .adobeRGB1998, .displayP3]
}

extension NSColor.SystemEffect: CustomStringConvertible {
    public var description: String {
        switch self {
        case .none: return "none"
        case .pressed: return "pressed"
        case .deepPressed: return "deepPressed"
        case .disabled: return "disabled"
        case .rollover: return "rollover"
        @unknown default: return "unknown"
        }
    }
    
    
}
#endif
