//
//  NSUIColor+.swift
//
//
//  Created by Florian Zand on 20.09.22.
//

import FZSwiftUtils

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public extension NSUIColor {
    /// A random color.
    static func random() -> NSUIColor {
        return NSUIColor(hue: CGFloat.random(in: 0.0 ... 1.0), saturation: 0.6, lightness: 0.5)
        /*
         return NSUIColor(red: CGFloat.random(in: 0.0...1.0), green: CGFloat.random(in: 0.0...1.0), blue: CGFloat.random(in: 0.0...1.0), alpha: 1.0)
          */
    }

    /// A random pastel color.
    static func randomPastel() -> NSUIColor {
        return NSUIColor(hue: CGFloat.random(in: 0.0 ... 1.0), saturation: 0.8, lightness: 0.8)
    }

    /**
     Returns a new color object in the specified `CGColorSpace`.
     - Parameter colorSpace: The color space of the color.
     - Returns: A `CGColor` object in the `CGColorSpace`.
     */
    func usingCGColorSpace(_ colorSpace: CGColorSpace) -> NSUIColor? {
        guard let cgColor = cgColor.converted(to: colorSpace, intent: .defaultIntent, options: nil) else { return nil }
        return NSUIColor(cgColor: cgColor)
    }
    
    /**
     A Boolean value that indicates whether the color is light or dark.

     It is useful when you need to know whether you should display the text in black or white.
     */
    func isLight() -> Bool {
      let components = rgbaComponents()
      let brightness = ((components.red * 299.0) + (components.green * 587.0) + (components.blue * 114.0)) / 1000.0

      return brightness >= 0.5
    }
    
    #if os(macOS) || os(iOS) || os(tvOS)
    /**
     Generates the resolved color for the specified view,.
     
     - Parameter view: The view for the resolved color.
     - Returns: A resolved color for the view.
     */
    func resolvedColor(for view: NSUIView) -> NSUIColor {
        #if os(macOS)
        self.resolvedColor(for: view.effectiveAppearance)
        #elseif canImport(UIKit)
        self.resolvedColor(with: view.traitCollection)
        #endif
    }
    
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
        backgroundGradientLayer.colors = gradientColors.map({$0.cgColor})
        let backgroundColorImage = backgroundGradientLayer.renderedImage
        self.init(patternImage: backgroundColorImage)
    }
    #endif
    
    /// A Boolean value that indicates whether the color is visible (`alphaComponent` isn't zero).
    var isVisible: Bool {
        self.alphaComponent != 0.0
    }
}
