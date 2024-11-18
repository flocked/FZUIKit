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
     Returns a new color object in the specified `CGColorSpace`.
     
     - Parameter colorSpace: The color space of the color.
     
     - Returns: A `NSColor` object in the color space.
     */
    func usingCGColorSpace(_ colorSpace: CGColorSpace) -> NSUIColor? {
        guard let cgColor = cgColor.converted(to: colorSpace, intent: .defaultIntent, options: nil) else { return nil }
        return NSUIColor(cgColor: cgColor)
    }
    
    /**
     A Boolean value that indicates whether the color is light.
     
     It is useful when you need to know whether you should display the text in black or white.
     */
    var isLight: Bool {
        let components = rgbaComponents()
        let brightness = ((components.red * 299.0) + (components.green * 587.0) + (components.blue * 114.0)) / 1000.0
        
        return brightness >= 0.5
    }
    
    /// A Boolean value that indicates whether the color is visible (`alphaComponent` isn't `0`).
    var isVisible: Bool {
        alphaComponent != 0.0
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
    
    /// A Boolean value that indicates whether the color contains a different light and dark color variant.
    var isDynamic: Bool {
        let dyamic = self.dynamicColors
        return dyamic.light != dyamic.dark
    }
    
    /**
     Creates a gradient color object that uses the specified colors and frame as gradient.
     
     - Parameters:
        - gradientColors: The colors of the gradient.
        - frame: The frame of the gradient.
     
     - Returns: A gradient color.
     */
    convenience init(gradientColors: [NSUIColor], frame: CGRect) {
        let backgroundGradientLayer = CAGradientLayer()
        backgroundGradientLayer.frame = frame
        backgroundGradientLayer.colors = gradientColors.map(\.cgColor)
        let backgroundColorImage = backgroundGradientLayer.renderedImage
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
