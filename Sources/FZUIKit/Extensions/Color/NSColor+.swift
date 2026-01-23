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
    convenience init(name: String? = nil, light lightColor: @escaping @autoclosure () -> NSColor, dark darkColor: @escaping @autoclosure () -> NSColor) {
        self.init(name: name, dynamicProvider: { appereance in appereance.isLight ? lightColor() : darkColor() })
    }
    
    /**
     Creates a color object from the specified components of the given color space.
     
     - Parameters:
        - colorSpace: An `NSColorSpace` object representing a color space. The colorspace should be component-based.
        - components: An array of the components in the specified color space to use to create the `NSColor` object. The order of these components is determined by the color-space profile, with the alpha component always last. (If you want the created color to be opaque, specify `1.0` for the alpha component.)
     - Returns: The color object.
     */
    convenience init(colorSpace: NSColorSpace, components: [CGFloat]) {
        var components = components.count == colorSpace.numberOfColorComponents ? components + [1.0] : components
        precondition(components.count == colorSpace.numberOfColorComponents+1, "Invalid number of components for \(colorSpace): expected \(colorSpace.numberOfColorComponents) or \(colorSpace.numberOfColorComponents+1), got \(components.count)")
        self.init(colorSpace: colorSpace, components: &components, count: components.count)
    }
    
    /**
     Creates a color object from the specified components in the extended sRGB colorspace.
     
     - Parameters:
        - red: The red component of the color object.
        - green: The green component of the color object.
        - blue: The blue component of the color object.
        - alpha: The opacity value of the color object.
     - Returns: The color object.
     */
    convenience init(extendedSRGBRed red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1.0) {
        self.init(colorSpace: .extendedSRGB, components: [red, green, blue, alpha])
    }
    
    /**
     Generates the resolved color for the specified appearance.
     
     - Parameter appearance: The appearance of the resolved color.
     */
    func resolvedColor(for appearance: NSAppearance = .currentDrawing()) -> NSColor {
        guard type == .catalog else { return self }
        return appearance.performAsCurrentDrawingAppearance {
            NSColor(cgColor: cgColor) ?? self
        }
    }
    
    /**
     Generates the resolved color for the specified appearance provider object (e.g. `NSView`, `NSWindow` or `NSApplication`).
     
     It uses the objects's [effectiveAppearance](https://developer.apple.com/documentation/appkit/nsappearancecustomization/effectiveappearance) for resolving the color.
     
     - Parameter appearanceProvider: The object for the resolved color.
     - Returns: A resolved color for the object.
     */
    func resolvedColor<AppearanceProvider: NSAppearanceCustomization>(for appearanceProvider: AppearanceProvider) -> NSColor {
        resolvedColor(for: appearanceProvider.effectiveAppearance)
    }
    
    /// Creates a new color object with a supported color space.
    func withSupportedColorSpace() -> NSColor? {
        guard type == .componentBased || type == .catalog else { return nil }
        guard safeColorSpace?.colorSpaceModel != .rgb else { return self }
        return [NSColorSpace.deviceRGB, .sRGB, .extendedSRGB, .genericRGB, .adobeRGB1998, .displayP3].lazy.compactMap({ self.usingColorSpace($0) }).first
    }
    
    /**
     Creates a new color object representing the color of the current color object in the specified color space.
     
     If the receiver’s color space is the same as the specified, this method returns the same color.

     - Parameters:
        - space: The color space of the new `NSColor` object.
        - includeVariation: A Boolean value indicating whether to include both variations of a dynamic color (e.g. a color that has a light and dark appearance).
     - Returns: The new `NSColor` object. This method converts the receiver’s color to an equivalent one in the new color space. Although the new color might have different component values, it looks the same as the original. Returns `nil` if conversion is not possible.
     */
    func usingColorSpace(_ space: NSColorSpace, includeVariation: Bool) -> NSColor? {
        guard includeVariation else { return usingColorSpace(space) }
        let dynamic = dynamicColors
        guard dynamic.light != dynamic.dark else { return usingColorSpace(space) }
        let light = dynamic.light.usingColorSpace(space)
        let dark = dynamic.dark.usingColorSpace(space)
        guard let light = light else { return dark }
        guard let dark = dark else { return light }
        return NSUIColor(light: light, dark: dark)
    }
    
    /// A `CIColor` representation of the color, or `nil` if the color cannot be accurately represented as `CIColor`.
    var ciColor: CIColor? {
        CIColor(color: self)
    }
    
    /**
     The color space associated with the color.
     
     This is a safe alternative to [colorSpace](https://developer.apple.com/documentation/appkit/nscolor/colorspace),  which crashes when accessed on colors that do not have an associated color space.
     */
    var safeColorSpace: NSColorSpace? {
        try? ObjCRuntime.catchException { colorSpace }
    }
    
    /**
     The name of the color.
     
     This is a safe alternative to [colorNameComponent](https://developer.apple.com/documentation/appkit/nscolor/colornamecomponent), which crashes when the color is not backed by a named color catalog.
     */
    var colorName: String? {
        try? ObjCRuntime.catchException { colorNameComponent }
    }
    
    /**
     The localized version of the color name.
     
     This is a safe alternative to [localizedColorNameComponent](https://developer.apple.com/documentation/appkit/nscolor/localizedcolornamecomponent), which crashes when the color is not backed by a named color catalog.
     */
    var localizedColorName: String? {
        try? ObjCRuntime.catchException { localizedColorNameComponent }
    }
    
    /**
     The catalog containing the color’s name.
     
     This is a safe alternative to [catalogNameComponent](https://developer.apple.com/documentation/appkit/nscolor/catalognamecomponent), which crashes when the color is not backed by a named color catalog.
     */
    var catalogName: String? {
        try? ObjCRuntime.catchException { catalogNameComponent }
    }
    
    /**
     The localized version of the catalog name containing the color.
     
     This is a safe alternative to [localizedCatalogNameComponent](https://developer.apple.com/documentation/appkit/nscolor/localizedcatalognamecomponent), which crashes when the color is not backed by a named color catalog.
     */
    var localizedCatalogName: String? {
        try? ObjCRuntime.catchException { localizedCatalogNameComponent }
    }
}

extension NSColor.ColorType: Swift.CustomStringConvertible {
    public var description: String {
        switch self {
        case .componentBased: return "componentBased"
        case .pattern: return "pattern"
        case .catalog: return "catalog"
        @unknown default: return "unknown"
        }
    }
}

extension NSColor.SystemEffect: Swift.CustomStringConvertible {
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
