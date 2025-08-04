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

public extension NSUIColor {
    /// A random color.
    static var random: NSUIColor {
        NSUIColor(hue: CGFloat.random(in: 0.0 ... 1.0), saturation: 0.6, lightness: 0.5)
    }
    
    /// A random pastel color.
    static var randomPastel: NSUIColor {
        NSUIColor(hue: .random(in: 0 ... 1), saturation: 1.0, brightness: .random(in: 0.75 ... 0.9), alpha: 1.0)
    }
    
    /**
     Creates a new color representing the color of the current color in the specified color space.
     
     - Parameter space: The color space of the new color.
     
     - Returns: The new color object. This method converts the receiver's color to an equivalent one in the new color space. Although the new color might have different component values, it looks the same as the original. Returns `nil` if conversion is not possible. If the receiver's color space is the same as that specified in space, this method returns the same color object.
     */
    func usingCGColorSpace(_ space: CGColorSpace) -> NSUIColor? {
        #if os(macOS)
        guard let nsColorSpace = NSColorSpace(cgColorSpace: space) else { return nil }
        guard nsColorSpace != colorSpace else { return self }
        return usingColorSpace(nsColorSpace) ?? withSupportedColorSpace()?.usingColorSpace(nsColorSpace)
        #else
        guard cgColor.colorSpace != space else { return self }
        guard let cgColor = cgColor.converted(to: space, intent: .defaultIntent, options: nil) else { return nil }
        return NSUIColor(cgColor: cgColor)
        #endif
    }
    
    /**
     Creates a new color representing the color of the current color in the specified color space.
     
     - Parameter name: The name of the color space of the new.
     
     - Returns: The new color. This method converts the receiver's color to an equivalent one in the new color space. Although the new color might have different component values, it looks the same as the original. Returns `nil` if conversion is not possible. If the receiver's color space is the same as that specified in space, this method returns the same color object.
     */
    func usingCGColorSpace(_ name: CGColorSpaceName) -> NSUIColor? {
        guard let space = name.colorSpace else { return nil }
        return usingCGColorSpace(space)
    }
    
    /// A Boolean value indicating whether the color is light.
    var isLight: Bool {
        let components = rgbaComponents()
        let brightness = ((components.red * 299.0) + (components.green * 587.0) + (components.blue * 114.0)) / 1000.0
        return brightness >= 0.5
    }
    
    /// A Boolean value indicating whether the color is visible (`alphaComponent` isn't `0`).
    var isVisible: Bool {
        alphaComponent > 0.0
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
    
    /// A Boolean value indicating whether the color contains a different light and dark color variant.
    var isDynamic: Bool {
        let dyamic = self.dynamicColors
        return dyamic.light != dyamic.dark
    }
    
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
}
