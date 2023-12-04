//
//  NSUIColor+HSBA.swift
//
//
//  Created by Florian Zand on 06.10.23.
//

#if canImport(UIKit)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import SwiftUI

extension NSUIColor {
  /**
   Returns the HSB (hue, saturation, brightness) components.

   - returns: The HSB components as a tuple (h, s, b).
   */
    public final func hsbaComponents() -> HSBAComponents {
    var h: CGFloat = 0.0
    var s: CGFloat = 0.0
    var b: CGFloat = 0.0

    #if os(iOS) || os(tvOS) || os(watchOS)
      getHue(&h, saturation: &s, brightness: &b, alpha: nil)

      return HSBAComponents(h, s, b, alphaComponent)
    #elseif os(OSX)
      if isEqual(NSUIColor.black) {
          return HSBAComponents(0.0, 0.0, 0.0, 1.0)
      }
      else if isEqual(NSUIColor.white) {
          return HSBAComponents(0.0, 0.0, 1.0, 1.0)
      }

      getHue(&h, saturation: &s, brightness: &b, alpha: nil)

        return HSBAComponents(h, s, b, alphaComponent)
    #endif
  }

  #if os(iOS) || os(tvOS) || os(watchOS)
    /**
     The hue component as CGFloat between 0.0 to 1.0.
     */
    public final var hueComponent: CGFloat {
      return hsbaComponents().hue
    }

    /**
     The saturation component as CGFloat between 0.0 to 1.0.
     */
    public final var saturationComponent: CGFloat {
      return hsbaComponents().saturation
    }

    /**
     The brightness component as CGFloat between 0.0 to 1.0.
     */
    public final var brightnessComponent: CGFloat {
      return hsbaComponents().brightness
    }
  #endif
}

/// The HSBA (hue, saturation, brightness, alpha) components of a color.
public struct HSBAComponents {
    /// The hue component of the color.
    public var hue: CGFloat
    
    /// The saturation component of the color.
    public var saturation: CGFloat
    
    /// The brightness component of the color.
    public var brightness: CGFloat
    
    /// The alpha value of the color.
    public var alpha: CGFloat
    
    public init(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        self.hue = hue
        self.saturation = saturation
        self.brightness = brightness
        self.alpha = alpha
    }
    
    internal init(_ hue: CGFloat, _ saturation: CGFloat, _ brightness: CGFloat, _ alpha: CGFloat) {
        self.hue = hue
        self.saturation = saturation
        self.brightness = brightness
        self.alpha = alpha
    }
    
    #if os(macOS)
    /// Returns the `NSColor`.
    public func toNSColor() -> NSUIColor {
        NSUIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    #else
    /// Returns the `UIColor`.
    public func toUIColor() -> NSUIColor {
        NSUIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    #endif
    
    /// Returns the SwiftUI `Color`.
    public func toColor() -> Color {
        Color(hue: hue, saturation: saturation, brightness: brightness, opacity: alpha)
    }
}

public extension NSUIColor {
    convenience init(_ hsbaComponents: HSBAComponents) {
        self.init(hue: hsbaComponents.hue, saturation: hsbaComponents.saturation, brightness: hsbaComponents.brightness, alpha: hsbaComponents.alpha)
    }
}

public extension Color {
    init(_ hsbaComponents: HSBAComponents) {
        self.init(hue: hsbaComponents.hue, saturation: hsbaComponents.saturation, brightness: hsbaComponents.brightness, opacity: hsbaComponents.alpha)
    }
}
