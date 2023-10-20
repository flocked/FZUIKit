//
//  NSUIColor+HSBA.swift
//
//
//  Created by Florian Zand on 06.10.23.
//

import Foundation

#if canImport(UIKit)
import UIKit
#elseif os(macOS)
import AppKit
#endif

extension NSUIColor {
  /**
   Returns the HSB (hue, saturation, brightness) components.

   - returns: The HSB components as a tuple (h, s, b).
   */
    public final func hsbaComponents() -> (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
    var h: CGFloat = 0.0
    var s: CGFloat = 0.0
    var b: CGFloat = 0.0

    #if os(iOS) || os(tvOS) || os(watchOS)
      getHue(&h, saturation: &s, brightness: &b, alpha: nil)

      return (h: h, s: s, b: b)
    #elseif os(OSX)
      if isEqual(NSUIColor.black) {
          return (0.0, 0.0, 0.0, 1.0)
      }
      else if isEqual(NSUIColor.white) {
          return (0.0, 0.0, 1.0, 1.0)
      }

      getHue(&h, saturation: &s, brightness: &b, alpha: nil)

        return (hue: h, saturation: s, brightness: b, alpha: alphaComponent)
    #endif
  }

  #if os(iOS) || os(tvOS) || os(watchOS)
    /**
     The hue component as CGFloat between 0.0 to 1.0.
     */
    public final var hueComponent: CGFloat {
      return hsbaComponents().h
    }

    /**
     The saturation component as CGFloat between 0.0 to 1.0.
     */
    public final var saturationComponent: CGFloat {
      return hsbaComponents().s
    }

    /**
     The brightness component as CGFloat between 0.0 to 1.0.
     */
    public final var brightnessComponent: CGFloat {
      return hsbaComponents().b
    }
  #endif
}
