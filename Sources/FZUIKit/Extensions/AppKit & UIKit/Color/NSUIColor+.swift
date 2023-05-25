//
//  File.swift
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
    func rgbaComponents() -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        var color: NSUIColor? = self
        #if os(macOS)
            let supportedColorSpaces: [NSColorSpace] = [.sRGB, .extendedSRGB, .genericRGB, .adobeRGB1998, .deviceRGB, .displayP3]
            if supportedColorSpaces.contains(colorSpace) == false {
                color = (usingColorSpace(.extendedSRGB) ?? usingColorSpace(.sRGB)) ?? nil
            }
        #endif
        color?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue, alpha)
    }

    func hsbaComponents() -> (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        var h: CGFloat = 0.0
        var s: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0

        var color: NSUIColor? = self
        #if os(macOS)
            color = withSupportedColorSpace()
        #endif
        color?.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return (hue: h, saturation: s, brightness: b, alpha: a)
    }

    func hslaComponents() -> (hue: CGFloat, saturation: CGFloat, lightness: CGFloat, alpha: CGFloat) {
        let hsl = HSL(color: self)
        let rgba = rgbaComponents()
        return (hue: hsl.h, saturation: hsl.s, lightness: hsl.l, alpha: rgba.alpha)
    }

    func withRed(_ red: CGFloat) -> NSUIColor {
        let rgba = rgbaComponents()
        return NSUIColor(red: red, green: rgba.green, blue: rgba.blue, alpha: rgba.alpha)
    }

    func withGreen(_ green: CGFloat) -> NSUIColor {
        let rgba = rgbaComponents()
        return NSUIColor(red: rgba.red, green: green, blue: rgba.blue, alpha: rgba.alpha)
    }

    func withBlue(_ blue: CGFloat) -> NSUIColor {
        let rgba = rgbaComponents()
        return NSUIColor(red: rgba.red, green: rgba.green, blue: blue, alpha: rgba.alpha)
    }

    func withAlpha(_ alpha: CGFloat) -> NSUIColor {
        let rgba = rgbaComponents()
        return NSUIColor(red: rgba.red, green: rgba.green, blue: rgba.blue, alpha: alpha)
    }

    func withHue(_ hue: CGFloat) -> NSUIColor {
        let hsba = hsbaComponents()
        return NSUIColor(hue: hue, saturation: hsba.saturation, brightness: hsba.brightness, alpha: hsba.alpha)
    }

    func withSaturation(_ saturation: CGFloat) -> NSUIColor {
        let hsba = hsbaComponents()
        return NSUIColor(hue: hsba.hue, saturation: hsba.saturation, brightness: saturation, alpha: hsba.alpha)
    }

    func withBrightness(_ brightness: CGFloat) -> NSUIColor {
        let hsba = hsbaComponents()
        return NSUIColor(hue: hsba.hue, saturation: hsba.saturation, brightness: brightness, alpha: hsba.alpha)
    }

    static func random() -> NSUIColor {
        return NSUIColor(hue: CGFloat.random(in: 0.0 ... 1.0), saturation: 0.6, lightness: 0.5)
        /*
         return NSUIColor(red: CGFloat.random(in: 0.0...1.0), green: CGFloat.random(in: 0.0...1.0), blue: CGFloat.random(in: 0.0...1.0), alpha: 1.0)
          */
    }

    static func randomPastel() -> NSUIColor {
        return NSUIColor(hue: CGFloat.random(in: 0.0 ... 1.0), saturation: 0.8, lightness: 0.8)
    }

    func usingCGColorSpace(_ colorSpace: CGColorSpace) -> NSUIColor? {
        guard let cgColor = cgColor.converted(to: colorSpace, intent: .defaultIntent, options: nil) else { return nil }
        return NSUIColor(cgColor: cgColor)
    }

    #if os(macOS)
        var isPatternColor: Bool {
            return (Swift.type(of: self) == NSClassFromString("NSPatternColor"))
        }

        var patternImageCGColor: CGColor? {
            guard isPatternColor else { return nil }
            return CGColor.fromImage(patternImage)
        }
    #endif
}
