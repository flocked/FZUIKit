//
//  NSUIColor+RGB.swift
//
//
//  Created by Florian Zand on 04.12.23.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import SwiftUI
import FZSwiftUtils

extension NSUIColor {
    
    
    #if os(macOS)
    /**
     Returns the RGBA (red, green, blue, alpha) components of the color.
     - Parameter colorSpace: The `RGB` based color space for the components, or `nil` to automatically determinate a color space.
     */
    public func rgbaComponents(using colorSpace: NSColorSpace? = nil) -> RGBAComponents {
        if let colorSpace = colorSpace, colorSpace.colorSpaceModel != .rgb {
            fatalError("The provided color space isn't rgb based, which is needed for rgbaComponents()")
        }
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if let colorSpace = colorSpace {
            usingColorSpace(colorSpace)
        } else if self.colorSpace.colorSpaceModel == .rgb {
            
        }
        if let color = usingColorSpace(.deviceRGB) ?? usingColorSpace(.genericRGB) {
            color.getRed(&r, green: &g, blue: &b, alpha: &a)
        } else {
            fatalError("Could not convert color to RGBA.")
        }
        return RGBAComponents(r, g, b, a)
    }
    #endif
    /// Returns the RGBA (red, green, blue, alpha) components of the color.
    @_disfavoredOverload
    public func rgbaComponents(using colorSpace: CGColorSpaceName? = nil) -> RGBAComponents {
        if let colorSpace = colorSpace, colorSpace.model != .rgb {
            fatalError("The provided color space isn't rgb based, which is needed for rgbaComponents()")
        }
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        #if os(macOS)
        if let color = usingColorSpace(.deviceRGB) ?? usingColorSpace(.genericRGB) {
            color.getRed(&r, green: &g, blue: &b, alpha: &a)
        } else {
            fatalError("Could not convert color to RGBA.")
        }
        #else
        if !getRed(&r, green: &g, blue: &b, alpha: &a) {
            if getWhite(&r, alpha: &a) {
                return RGBAComponents(r, r, r, a)
            } else {
                fatalError("Could not convert color to RGBA.")
            }
        }
        #endif
        return RGBAComponents(r, g, b, a)
    }

    #if os(iOS) || os(tvOS) || os(watchOS)
        /// The red component of the color.
        var redComponent: CGFloat {
            rgbaComponents().red
        }

        /// The green component of the color.
        var greenComponent: CGFloat {
            rgbaComponents().green
        }

        /// The blue component of the color.
        var blueComponent: CGFloat {
            rgbaComponents().blue
        }

        /// The alpha component of the color.
        var alphaComponent: CGFloat {
            rgbaComponents().alpha
        }
    #endif

    /// Returns a new color object with the specified red component (between `0.0` and `1.0`).
    @objc open func withRed(_ red: CGFloat) -> NSUIColor {
        #if os(macOS) || os(iOS) || os(tvOS)
        let dynamic = dynamicColors
        if dynamic.light != dynamic.dark {
            return NSUIColor(light: NSUIColor(dynamic.light.rgbaComponents().red(red)), dark: NSUIColor(dynamic.dark.rgbaComponents().red(red)))
        }
        #endif
        return NSUIColor(rgbaComponents().red(red))
    }

    /// Returns a new color object with the specified green component (between `0.0` and `1.0`).
    @objc open func withGreen(_ green: CGFloat) -> NSUIColor {
        #if os(macOS) || os(iOS) || os(tvOS)
        let dynamic = dynamicColors
        if dynamic.light != dynamic.dark {
            return NSUIColor(light: NSUIColor(dynamic.light.rgbaComponents().green(green)), dark: NSUIColor(dynamic.dark.rgbaComponents().green(green)))
        }
        #endif
        return NSUIColor(rgbaComponents().green(green))
    }

    /// Returns a new color object with the specified blue component (between `0.0` and `1.0`).
    @objc open func withBlue(_ blue: CGFloat) -> NSUIColor {
        #if os(macOS) || os(iOS) || os(tvOS)
        let dynamic = dynamicColors
        if dynamic.light != dynamic.dark {
            return NSUIColor(light: NSUIColor(dynamic.light.rgbaComponents().blue(blue)), dark: NSUIColor(dynamic.dark.rgbaComponents().blue(blue)))
        }
        #endif
        return NSUIColor(rgbaComponents().blue(blue))
    }

    /// Returns a new color object with the specified alpha value (between `0.0` and `1.0`).
    @objc open func withAlpha(_ alpha: CGFloat) -> NSUIColor {
        withAlphaComponent(alpha)
    }
}

/// The RGBA (red, green, blue, alpha) components of a color.
public struct RGBAComponents: Codable, Hashable {
    /// The red component of the color (between `0.0` to `1.0`).
    public var red: CGFloat {
        didSet { red = red.clamped(to: 0.0...1.0) }
    }
    
    /// Sets the red component of the color (between `0.0` to `1.0`).
    @discardableResult
    public func red(_ red: CGFloat) -> Self {
        var components = self
        components.red = red
        return components
    }

    /// The green component of the color (between `0.0` to `1.0`).
    public var green: CGFloat {
        didSet { green = green.clamped(to: 0.0...1.0) }
    }
    
    /// Sets the green component of the color (between `0.0` to `1.0`).
    @discardableResult
    public func green(_ green: CGFloat) -> Self {
        var components = self
        components.green = green
        return components
    }

    /// The blue component of the color (between `0.0` to `1.0`).
    public var blue: CGFloat {
        didSet { blue = blue.clamped(to: 0.0...1.0) }
    }
    
    /// Sets the blue component of the color (between `0.0` to `1.0`).
    @discardableResult
    public func blue(_ blue: CGFloat) -> Self {
        var components = self
        components.blue = blue
        return components
    }

    /// The alpha value of the color (between `0.0` to `1.0`).
    public var alpha: CGFloat {
        didSet { alpha = alpha.clamped(to: 0.0...1.0) }
    }
    
    /// Sets the alpha value of the color (between `0.0` to `1.0`).
    @discardableResult
    public func alpha(_ alpha: CGFloat) -> Self {
        var components = self
        components.alpha = alpha
        return components
    }
    
    /// The linear red component.
    public var linearRed: CGFloat {
        get { srgbToLinear(red) }
        set { red = linearToSRGB(newValue) }
    }
    
    /// Sets the linear red component.
    public func linearRed(_ linearRed: CGFloat) -> Self {
        var components = self
        components.linearRed = linearRed
        return components
    }
    
    /// The linear green component.
    public var linearGreen: CGFloat {
        get { srgbToLinear(green) }
        set { green = linearToSRGB(newValue) }
    }
    
    /// Sets the linear green component.
    public func linearGreen(_ linearGreen: CGFloat) -> Self {
        var components = self
        components.linearGreen = linearGreen
        return components
    }
    
    /// The linear blue component.
    public var linearBlue: CGFloat {
        get { srgbToLinear(blue) }
        set { blue = linearToSRGB(newValue) }
    }
    
    /// Sets the linear blue component.
    public func linearBlue(_ linearBlue: CGFloat) -> Self {
        var components = self
        components.linearBlue = linearBlue
        return components
    }
    
    @inline(__always)
    private func srgbToLinear(_ c: CGFloat) -> CGFloat {
        c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
    }
    
    @inline(__always)
    private func linearToSRGB(_ c: CGFloat) -> CGFloat {
        c <= 0.0031308 ? 12.92 * c : 1.055 * pow(c, 1.0 / 2.4) - 0.055
    }
    
    /**
     Blends the color components with the specified components.

     - Parameters:
        - fraction: The amount of the color to blend (between `0.0` and `1.0`).
        - components: The components to blend.
     */
    public mutating func blend(withFraction fraction: CGFloat, of components: Self) {
        self = blended(withFraction: fraction, of: components)
    }
    
    /**
     Blends the color components with the specified components.

     - Parameters:
        - fraction: The amount of the color to blend (between `0.0` and `1.0`).
        - components: The components to blend.
     
     - Returns: The color components blended with the specified components.
     */
    public func blended(withFraction fraction: CGFloat, of components: Self) -> Self {
        let fraction = fraction.clamped(to: 0...1.0)
        return Self(red + (components.red - red) * fraction, green + (components.green - green) * fraction, blue + (components.blue - blue) * fraction, alpha + (components.alpha - alpha) * fraction)
    }
    
    /**
     Creates RGBA components with the specified red, green, blue and alpha components.
     
     - Parameters:
        - red: The red component of the color (between `0.0` to `1.0`).
        - green: The green component of the color (between `0.0` to `1.0`).
        - blue: The blue component of the color (between `0.0` to `1.0`).
        - alpha: The alpha value of the color (between `0.0` to `1.0`).
     */
    public init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        self.red = red.clamped(to: 0.0...1.0)
        self.green = green.clamped(to: 0.0...1.0)
        self.blue = blue.clamped(to: 0.0...1.0)
        self.alpha = alpha.clamped(to: 0.0...1.0)
    }

    init(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) {
        self.red = red.clamped(to: 0.0...1.0)
        self.green = green.clamped(to: 0.0...1.0)
        self.blue = blue.clamped(to: 0.0...1.0)
        self.alpha = alpha.clamped(to: 0.0...1.0)
    }
    
    func hsla() -> HSLAComponents {
        hsba().hsla()
    }
    
    func hsba() -> HSBAComponents {
          let maxV = max(red, max(green, blue))
          let minV = min(red, min(green, blue))
          let delta = maxV - minV

          // Brightness
          let brightness = maxV

          // Saturation
          let saturation = maxV == 0 ? 0 : delta / maxV

          // Hue
          var hue: CGFloat = 0

          if delta != 0 {
              if maxV == red {
                  hue = (green - blue) / delta
              } else if maxV == green {
                  hue = 2 + (blue - red) / delta
              } else {
                  hue = 4 + (red - green) / delta
              }

              hue /= 6
              if hue < 0 { hue += 1 }
          }

        return .init(hue, saturation, brightness, alpha)
      }
}

public extension NSUIColor {
    /// Creates a color using the RGBA components.
    convenience init(_ rgbaComponents: RGBAComponents) {
        self.init(red: rgbaComponents.red, green: rgbaComponents.green, blue: rgbaComponents.blue, alpha: rgbaComponents.alpha)
    }
}

public extension Color {
    /// Creates a color using the RGBA components.
    init(_ rgbaComponents: RGBAComponents) {
        self.init(red: rgbaComponents.red, green: rgbaComponents.green, blue: rgbaComponents.blue, opacity: rgbaComponents.alpha)
    }
}

public extension CGColor {
    /// Returns the RGBA (red, green, blue, alpha) components of the color.
    func rgbaComponents() -> RGBAComponents? {
        if let rgbaComponents = nsUIColor?.rgbaComponents() {
            return rgbaComponents
        }
        var color = self
        if color.colorSpace?.model != .rgb, #available(iOS 9.0, macOS 10.11, tvOS 9.0, watchOS 2.0, *) {
            color = color.converted(to: .deviceRGB) ?? color.converted(to: .genericRGB) ?? color
        }
        guard color.colorSpace?.model == .rgb, let components = color.components else { return nil }
        switch components.count {
        case 2:
            return RGBAComponents(components[0], components[0], components[0], components[1])
        case 3:
            return RGBAComponents(components[0], components[1], components[2], 1.0)
        case 4:
            return RGBAComponents(components[0], components[1], components[2], components[3])
        default:
            #if os(macOS) || os(iOS) || os(tvOS)
            let ciColor = CIColor(cgColor: color)
            return RGBAComponents(ciColor.red, ciColor.green, ciColor.blue, ciColor.alpha)
            #else
            return nil
            #endif
        }
    }
}

public extension CFType where Self == CGColor {
    /// Creates a color using the RGBA components.
    init(_ rgbaComponents: RGBAComponents) {
        self.init(red: rgbaComponents.red, green: rgbaComponents.green, blue: rgbaComponents.blue, alpha: rgbaComponents.alpha)
    }
}

extension RGBAComponents {

}
