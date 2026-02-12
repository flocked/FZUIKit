//
//  NSUIColor+.swift
//
//
//  Created by Florian Zand on 20.09.22.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import FZSwiftUtils

public extension NSUIColor {
    /// A random color.
    static var random: NSUIColor {
        NSUIColor(.hsl(hue: .random(in: 0 ... 1), saturation: 0.6, lightness: 0.5))
    }
    
    /// A random pastel color.
    static var randomPastel: NSUIColor {
        NSUIColor(hue: .random(in: 0 ... 1), saturation: 1.0, brightness: .random(in: 0.75 ... 0.9), alpha: 1.0)
    }
    
    /// Creates a new color object that has the same color space and component values as the current color object, but with the specified alpha value.
    func opacity(_ opacity:  CGFloat) -> NSUIColor {
        withAlphaComponent(opacity.clamped(to: 0...1.0))
    }
    
    /**
     Creates a new color representing the color of the current color in the specified color space.
     
     If the receiver’s color space is the same as the specified, this method returns the same color object.
     
     - Parameter space: The color space of the new color.
     - Returns: The new color object. This method converts the receiver's color to an equivalent one in the new color space. Although the new color might have different component values, it looks the same as the original. Returns `nil` if conversion is not possible.
     */
    @_disfavoredOverload
    func usingColorSpace(_ space: CGColorSpace) -> NSUIColor? {
        #if os(macOS)
        if let colorSpace = NSColorSpace(cgColorSpace: space), let color = usingColorSpace(colorSpace, includeVariation: true) {
            return color
        }
        #endif
        #if os(macOS) || os(iOS) || os(tvOS)
        let dynamicColors = dynamicColors
        if dynamicColors.isDynamic {
            var light = dynamicColors.light.cgColor
            var dark = dynamicColors.dark.cgColor
            guard light.colorSpace != space || dark.colorSpace != space else { return self }
            if light.colorSpace != space {
                guard let color = light.converted(to: space) else { return nil }
                light = color
            }
            if dark.colorSpace != space {
                guard let color = dark.converted(to: space) else { return nil }
                dark = color
            }
            guard let light = light.nsUIColor, let dark = dark.nsUIColor else { return nil }
            return NSUIColor(light: light, dark: dark)
        }
        #endif
        let cgColor = cgColor
        guard cgColor.colorSpace != space else { return self }
        return cgColor.converted(to: space)?.nsUIColor
    }
    
    /**
     Creates a new color representing the color of the current color in the specified color space.
     
     If the receiver's color space is the same as the color space with the specified name, this method returns the same color object.
     
     - Parameter colorSpaceName: The name of the color space of the new color.
     - Returns: The new color. This method converts the receiver's color to an equivalent one in the new color space. Although the new color might have different component values, it looks the same as the original. Returns `nil` if conversion is not possible.
     */
    @_disfavoredOverload
    func usingColorSpace(_ colorSpaceName: CGColorSpaceName) -> NSUIColor? {
        guard let space = CGColorSpace(name: colorSpaceName) else { return nil }
        return usingColorSpace(space)
    }
    
    /// A Boolean value indicating whether the color is visible (`alphaComponent` isn't `0`).
    var isVisible: Bool {
        rgb().alpha > 0.0
    }
    
    #if os(iOS) || os(tvOS)
    /**
     Generates the resolved color for the specified environment.
     
     It uses the environment's `traitCollection` for resolving the color.
     
     - Parameter environment: The environment for the resolved color.
     - Returns: A resolved color for the environment.
     */
    func resolvedColor<Environment: UITraitEnvironment>(for environment: Environment) -> NSUIColor {
        resolvedColor(with: environment.traitCollection)
    }
    #endif
    
    #if os(macOS) || os(iOS) || os(tvOS)
    
    /**
     Creates a gradient color object that uses the specified gradient and size.
     
     - Parameters:
        - gradient: The gradient.
        - size: The size of the gradient.
     
     - Returns: A gradient color.
     */
    convenience init(gradient: Gradient, size: CGSize) {
        let backgroundGradientLayer = CAGradientLayer()
        backgroundGradientLayer.bounds.size = size
        backgroundGradientLayer.gradient = gradient
        let backgroundColorImage = backgroundGradientLayer.renderedImage!.nsUIImage
        self.init(patternImage: backgroundColorImage)
    }
    #endif
    
    #if os(macOS)
    /// All syten colors.
    static var systemColors: [NSUIColor] {
        var colors: [NSUIColor] = [.white, .black, .systemRed, .systemGreen, .systemBlue, .systemOrange, .systemYellow, .systemBrown, .systemPink, .systemPurple, .systemGray, .systemTeal, .systemIndigo]
        if #available(macOS 12.0, iOS 15.0, tvOS 15.0, *) {
            colors.append(.systemCyan)
        }
        return colors
    }
    #elseif os(iOS) || os(tvOS)
    /// All syten colors.
    static var systemColors: [NSUIColor] {
        var colors: [NSUIColor] = [.white, .black, .systemRed, .systemGreen, .systemBlue, .systemOrange, .systemYellow, .systemBrown, .systemPink, .systemPurple, .systemGray, .systemTeal, .systemIndigo]
        if #available(iOS 15.0, tvOS 15.0, *) {
            colors += [.systemMint, .tintColor, .systemCyan]
        }
        return colors
    }
    #endif
    
    #if !os(macOS)
    /// The alpha value of the color.
    var alphaComponent: CGFloat {
        var alpha: CGFloat = 1.0
        getRed(nil, green: nil, blue: nil, alpha: &alpha)
        return alpha
    }
    #endif
    
    /**
     Creates a color with the specified color space and components.
     
     - Parameters:
        - colorSpace: A color space for the new color.
        - components: An array of the components in the specified color space to use to create the color object. The order of these components is determined by the color-space profile, with the alpha component always last. (If you want the created color to be opaque, specify `1.0` for the alpha component.)
     - Returns: A new color.
     */
    @_disfavoredOverload
    convenience init?(colorSpace: CGColorSpace, components: [CGFloat]) {
        guard let cgColor = CGColor(colorSpace: colorSpace, components: components.count == colorSpace.numberOfComponents ? components + [1.0] : components) else { return nil }
        self.init(cgColor: cgColor)
    }
    
    /**
     Creates a color with the specified color space and components.
     
     - Parameters:
        - colorSpace: A color space for the new color.
        - components: An array of the components in the specified color space to use to create the color object. The order of these components is determined by the color-space profile, with the alpha component always last. (If you want the created color to be opaque, specify `1.0` for the alpha component.)
     - Returns: A new color.
     */
    @_disfavoredOverload
    convenience init?(colorSpace: CGColorSpaceName, components: [CGFloat]) {
        guard let cgColor = CGColor(colorSpace: colorSpace, components: components.count == colorSpace.numberOfComponents ? components + [1.0] : components) else { return nil }
        self.init(cgColor: cgColor)
    }
    
    /**
     Creates a color object using the specified image object.
     
     You can use pattern colors to set the fill or stroke color just as you’d a solid color. During drawing, the image in the pattern color is tiled as necessary to cover the given area.
          
     - Parameter image: The image to use when creating the pattern color.
     - Returns: The pattern color.
     */
    convenience init(patternImage image: CGImage) {
        self.init(patternImage: NSUIImage(cgImage: image))
    }
    
    /// Returns the color components of the color.
    var components: [CGFloat]? {
        cgColor.components
    }
    
    /// Returns the color components for the color in the specified color space.
    @_disfavoredOverload
    func components(for colorSpace: CGColorSpaceName) -> [CGFloat]? {
        cgColor.components(for: colorSpace)
    }
    
    /// Returns the color components for the color in the specified color space.
    func components(for colorSpace: CGColorSpace) -> [CGFloat]? {
        cgColor.components(for: colorSpace)
    }
}

#if os(macOS) || os(iOS) || os(tvOS)
public extension NSUIColor {
    /// Returns the dynamic light and dark color variation of the color.
    var dynamicColors: DynamicColor {
        #if os(macOS)
        DynamicColor(resolvedColor(for: .aqua), resolvedColor(for: .darkAqua))
        #else
        DynamicColor(resolvedColor(with: .light), resolvedColor(with: .dark))
        #endif
    }
    
    /// A Boolean value indicating whether the color contains a different light and dark color variant.
    var isDynamic: Bool {
        dynamicColors.isDynamic
    }
    
    /// The dynamic light and dark variations of a color.
    struct DynamicColor {
        /// The light color.
        public let light: NSUIColor
        
        /// The dark color.
        public let dark: NSUIColor
        
        /// A Boolean value indicating whether the light color differs to the dark color.
        public var isDynamic: Bool {
            light != dark
        }
        
        init(_ light: NSUIColor, _ dark: NSUIColor) {
            self.light = light
            self.dark = dark
        }
    }
}
#endif

extension NSUIColor: Swift.Encodable, Swift.Decodable {
    public func encode(to encoder: Encoder) throws {
        try encoder.encodeSingle(archivedData())
    }
}

extension Decodable where Self: NSUIColor {
    public init(from decoder: Decoder) throws {
        self = try Self.unarchive(decoder.decodeSingle())
    }
}
