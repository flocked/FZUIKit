//
//  NSColor+HSL.swift
//
// Parts taken from:
// Copyright 2015-present Yannick Loriot.
//
//  Created by Florian Zand on 06.10.22.
//
//

import FZSwiftUtils
import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif os(macOS)
import AppKit
#endif

extension NSUIColor {
  /**
   Initializes and returns a color object using the specified opacity and HSL component values.

   - parameter hue: The hue component of the color object, specified as a value from 0.0 to 360.0 degree.
   - parameter saturation: The saturation component of the color object, specified as a value from 0.0 to 1.0.
   - parameter lightness: The lightness component of the color object, specified as a value from 0.0 to 1.0.
   - parameter alpha: The opacity value of the color object, specified as a value from 0.0 to 1.0. Default to 1.0.
   */
  public convenience init(hue: CGFloat, saturation: CGFloat, lightness: CGFloat, alpha: CGFloat = 1) {
      var hue = hue
      if hue > 360 {
          hue = hue - 360
      }
      let h = hue / 360.0
      var s = saturation
      let l = lightness

      let t = s * ((l < 0.5) ? l : (1.0 - l))
      let b = l + t
      s = (l > 0.0) ? (2.0 * t / b) : 0.0

      self.init(hue: h, saturation: s, brightness: b, alpha: alpha)
  }

  // MARK: - Getting the HSL Components

  /**
   Returns the HSL (hue, saturation, lightness) components.

   Notes that the hue value is between 0.0 and 360.0 degree.

   - returns: The HSL components as a tuple (h, s, l).
   */
    public final func hslaComponents() -> HSLAComponents {
        var (h, s, b, a) = (CGFloat(), CGFloat(), CGFloat(), CGFloat())
        #if os(macOS)
        let color = self.withSupportedColorSpace() ?? self
        color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        #else
        getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        #endif
        
        let l = ((2.0 - s) * b) / 2.0

        switch l {
        case 0.0, 1.0:
            s = 0.0
        case 0.0..<0.5:
            s = (s * b) / (l * 2.0)
        default:
            s = (s * b) / (2.0 - l * 2.0)
        }

        return HSLAComponents(h * 360.0, s, l, a)
  }
}

/// The HSLA (hue, saturation, lightness, alpha) components of a color.
public struct HSLAComponents {
    /// The hue component of the color.
    public var hue: CGFloat
    
    /// The saturation component of the color.
    public var saturation: CGFloat
    
    /// The lightness component of the color.
    public var lightness: CGFloat
    
    /// The alpha value of the color.
    public var alpha: CGFloat
    
    public init(hue: CGFloat, saturation: CGFloat, lightness: CGFloat, alpha: CGFloat) {
        self.hue = hue
        self.saturation = saturation
        self.lightness = lightness
        self.alpha = alpha
    }
    
    internal init(_ hue: CGFloat, _ saturation: CGFloat, _ lightness: CGFloat, _ alpha: CGFloat) {
        self.hue = hue
        self.saturation = saturation
        self.lightness = lightness
        self.alpha = alpha
    }
    
    /// Returns the color.
    public func toColor() -> NSUIColor {
        NSUIColor(hue: hue, saturation: saturation, lightness: lightness, alpha: alpha)
    }
}

public extension NSUIColor {
    convenience init(_ hslaComponents: HSLAComponents) {
        self.init(hue: hslaComponents.hue, saturation: hslaComponents.saturation, lightness: hslaComponents.lightness, alpha: hslaComponents.alpha)
    }
}

/*
/// Hue-saturation-lightness structure to make the color manipulation easier.
internal struct HSL {
  /// Hue value between 0.0 and 1.0 (0.0 = 0 degree, 1.0 = 360 degree).
  var h: CGFloat = 0.0
  /// Saturation value between 0.0 and 1.0.
  var s: CGFloat = 0.0
  /// Lightness value between 0.0 and 1.0.
  var l: CGFloat = 0.0
  /// Alpha value between 0.0 and 1.0.
  var a: CGFloat = 1.0

  // MARK: - Initializing HSL Colors

  /**
  Initializes and creates a HSL color from the hue, saturation, lightness and alpha components.

  - parameter h: The hue component of the color object, specified as a value between 0.0 and 360.0 degree.
  - parameter s: The saturation component of the color object, specified as a value between 0.0 and 1.0.
  - parameter l: The lightness component of the color object, specified as a value between 0.0 and 1.0.
  - parameter a: The opacity component of the color object, specified as a value between 0.0 and 1.0.
  */
  init(hue: CGFloat, saturation: CGFloat, lightness: CGFloat, alpha: CGFloat = 1.0) {
    h = hue.truncatingRemainder(dividingBy: 360.0) / 360.0
      s = saturation.clamped(max: 1.0)
      l = lightness.clamped(max: 1.0)
      a = alpha.clamped(max: 1.0)
  }

  /**
  Initializes and creates a HSL (hue, saturation, lightness) color from a NSUIColor object.
  
  - parameter color: A NSUIColor object.
  */
  init(color: NSUIColor) {
    let rgba = color.rgbaComponents()

    let maximum   = max(rgba.red, max(rgba.green, rgba.blue))
    let minimum = min(rgba.red, min(rgba.green, rgba.blue))

    let delta = maximum - minimum

    h = 0.0
    s = 0.0
    l = (maximum + minimum) / 2.0

    if delta != 0.0 {
      if l < 0.5 {
        s = delta / (maximum + minimum)
      }
      else {
        s = delta / (2.0 - maximum - minimum)
      }

      if rgba.red == maximum {
        h = ((rgba.green - rgba.blue) / delta) + (rgba.green < rgba.blue ? 6.0 : 0.0)
      }
      else if rgba.green == maximum {
        h = ((rgba.blue - rgba.red) / delta) + 2.0
      }
      else if rgba.blue == maximum {
        h = ((rgba.red - rgba.green) / delta) + 4.0
      }
    }

    h /= 6.0
    a = rgba.alpha
  }

  // MARK: - Transforming HSL Color

  /**
  Returns the NSUIColor representation from the current HSV color.
  
  - returns: A NSUIColor object corresponding to the current HSV color.
  */
  func toColor() -> NSUIColor {
    let  (r, g, b, a) = rgbaComponents()

    return NSUIColor(red: r, green: g, blue: b, alpha: a)
  }

  /// Returns the RGBA components  from the current HSV color.
  func rgbaComponents() -> (CGFloat, CGFloat, CGFloat, CGFloat) {
    let m2 = l <= 0.5 ? l * (s + 1.0) : (l + s) - (l * s)
    let m1 = (l * 2.0) - m2

    let r = hueToRGB(m1: m1, m2: m2, h: h + (1.0 / 3.0))
    let g = hueToRGB(m1: m1, m2: m2, h: h)
    let b = hueToRGB(m1: m1, m2: m2, h: h - (1.0 / 3.0))
    
    return (r, g, b, CGFloat(a))
  }

  /// Hue to RGB helper function
  private func hueToRGB(m1: CGFloat, m2: CGFloat, h: CGFloat) -> CGFloat {
    let hue = moda(h, m: 1)

    if hue * 6 < 1.0 {
      return m1 + ((m2 - m1) * hue * 6.0)
    }
    else if hue * 2.0 < 1.0 {
      return m2
    }
    else if hue * 3.0 < 1.9999 {
      return m1 + ((m2 - m1) * ((2.0 / 3.0) - hue) * 6.0)
    }

    return m1
  }

  // MARK: - Deriving the Color

  /**
  Returns a color with the hue rotated along the color wheel by the given amount.

  - parameter amount: A float representing the number of degrees as ratio (usually between -360.0 degree and 360.0 degree).
  - returns: A HSL color with the hue changed.
  */
  func adjustedHue(amount: CGFloat) -> HSL {
    return HSL(hue: (h * 360.0) + amount, saturation: s, lightness: l, alpha: a)
  }

  /**
  Returns a color with the lightness increased by the given amount.

  - parameter amount: CGFloat between 0.0 and 1.0.
  - returns: A lighter HSL color.
  */
  func lighter(amount: CGFloat) -> HSL {
    return HSL(hue: h * 360.0, saturation: s, lightness: l + amount, alpha: a)
  }

  /**
  Returns a color with the lightness decreased by the given amount.

  - parameter amount: CGFloat between 0.0 and 1.0.
  - returns: A darker HSL color.
  */
  func darkened(amount: CGFloat) -> HSL {
    return lighter(amount: amount * -1.0)
  }

  /**
  Returns a color with the saturation increased by the given amount.

  - parameter amount: CGFloat between 0.0 and 1.0.
  - returns: A HSL color more saturated.
  */
  func saturated(amount: CGFloat) -> HSL {
    return HSL(hue: h * 360.0, saturation: s + amount, lightness: l, alpha: a)
  }

  /**
  Returns a color with the saturation decreased by the given amount.

  - parameter amount: CGFloat between 0.0 and 1.0.
  - returns: A HSL color less saturated.
  */
  func desaturated(amount: CGFloat) -> HSL {
    return saturated(amount: amount * -1.0)
  }
}

/**
 Returns the absolute value of the modulo operation.

 - Parameter x: The value to compute.
 - Parameter m: The modulo.
 */
fileprivate func moda(_ x: CGFloat, m: CGFloat) -> CGFloat {
  return (x.truncatingRemainder(dividingBy: m) + m).truncatingRemainder(dividingBy: m)
}
*/
