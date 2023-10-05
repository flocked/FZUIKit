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

public extension NSUIColor {
    /**
     Creates a color object with the specified hue, saturation, lightness, and alpha channel values.

     - Parameters:
        - hue: The hue of the color.
        - saturation: The saturation of the color.
        - lightness: The lightness of the color.
        - alpha: The alpha channel value of the color.
     */
    convenience init(hue: CGFloat, saturation: CGFloat, lightness: CGFloat, alpha: CGFloat = 1) {
        let h = hue / 360.0
        var s = saturation / 100.0
        let l = lightness / 100.0

        let t = s * ((l < 0.5) ? l : (1.0 - l))
        let b = l + t
        s = (l > 0.0) ? (2.0 * t / b) : 0.0

        self.init(hue: h, saturation: s, brightness: b, alpha: alpha)
    }
}

internal struct HSL {
    var h: CGFloat = 0.0
    var s: CGFloat = 0.0
    var l: CGFloat = 0.0
    var a: CGFloat = 1.0

    init(hue: CGFloat, saturation: CGFloat, lightness: CGFloat, alpha _: CGFloat = 1.0) {
        h = hue.truncatingRemainder(dividingBy: 360.0) / 360.0
        s = saturation.clamped(max: 1.0)
        l = lightness.clamped(max: 1.0)
        a = saturation.clamped(max: 1.0)
    }

    init(color: NSUIColor) {
        #if os(macOS)
        let color = color.withSupportedColorSpace() ?? color
        #endif
        var b = CGFloat()
        color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        
        l = ((2.0 - s) * b) / 2.0

        switch l {
        case 0.0, 1.0:
            s = 0.0
        case 0.0..<0.5:
            s = (s * b) / (l * 2.0)
        default:
            s = (s * b) / (2.0 - l * 2.0)
        }
        
        h = h * 360.0
        s = s * 100.0
        l = l * 100.0
    }

    func toColor() -> NSUIColor {
        let (r, g, b, a) = rgbaComponents()
        return NSUIColor(red: r, green: g, blue: b, alpha: a)
    }

    /// The RGBA components.
    func rgbaComponents() -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        let m2 = l <= 0.5 ? l * (s + 1.0) : (l + s) - (l * s)
        let m1 = (l * 2.0) - m2

        let r = hueToRGB(m1: m1, m2: m2, h: h + (1.0 / 3.0))
        let g = hueToRGB(m1: m1, m2: m2, h: h)
        let b = hueToRGB(m1: m1, m2: m2, h: h - (1.0 / 3.0))

        return (r, g, b, CGFloat(a))
    }

    private func hueToRGB(m1: CGFloat, m2: CGFloat, h: CGFloat) -> CGFloat {
        let hue = (h.truncatingRemainder(dividingBy: 1) + 1).truncatingRemainder(dividingBy: 1)

        if hue * 6 < 1.0 {
            return m1 + ((m2 - m1) * hue * 6.0)
        } else if hue * 2.0 < 1.0 {
            return m2
        } else if hue * 3.0 < 1.9999 {
            return m1 + ((m2 - m1) * ((2.0 / 3.0) - hue) * 6.0)
        }

        return m1
    }

    func adjustedHue(amount: CGFloat) -> HSL {
        let amount = amount.clamped(max: 1.0)
        return HSL(hue: (h * 360.0) + amount, saturation: s, lightness: l, alpha: a)
    }

    func lighter(amount: CGFloat) -> HSL {
        let amount = amount.clamped(max: 1.0)
        return HSL(hue: h * 360.0, saturation: s, lightness: l + amount, alpha: a)
    }

    func darkened(amount: CGFloat) -> HSL {
        let amount = amount.clamped(max: 1.0)
        return lighter(amount: amount * -1.0)
    }

    func saturated(amount: CGFloat) -> HSL {
        let amount = amount.clamped(max: 1.0)
        return HSL(hue: h * 360.0, saturation: s + amount, lightness: l, alpha: a)
    }

    func desaturated(amount: CGFloat) -> HSL {
        let amount = amount.clamped(max: 1.0)
        return saturated(amount: amount * -1.0)
    }
}
