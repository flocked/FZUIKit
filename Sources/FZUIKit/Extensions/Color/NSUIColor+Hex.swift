//
//  NSUIColor+Hex.swift
//
// Parts taken from:
//  https://github.com/CodeEditApp
//  Created by Lukas Pistrol on 23.03.22.
//
//  Created by Florian Zand on 06.10.22.
//

import FZSwiftUtils

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public extension NSUIColor {
    /// Initializes a color from a hex string (e.g. `#1D2E3F`) and an optional alpha value.
    convenience init?(hex: String, alpha: CGFloat = 1.0) {
        var hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        if hex.hasPrefix("#") {
            hex = hex.replacingOccurrences(of: "#", with: "")
        }
        var hexValue: UInt64 = 0
        guard Scanner(string: hex).scanHexInt64(&hexValue) else {
            return nil
        }

        let r, g, b, a, divisor: CGFloat
        switch hex.count {
        case 3:
            divisor = 15
            r = CGFloat((hexValue & 0xF00) >> 8) / divisor
            g = CGFloat((hexValue & 0x0F0) >> 4) / divisor
            b = CGFloat( hexValue & 0x00F) / divisor
            a = 1
        case 4:
            divisor = 15
            r = CGFloat((hexValue & 0xF000) >> 12) / divisor
            g = CGFloat((hexValue & 0x0F00) >> 8) / divisor
            b = CGFloat((hexValue & 0x00F0) >> 4) / divisor
            a = CGFloat( hexValue & 0x000F) / divisor
        case 6:
            divisor = 255
            r = CGFloat((hexValue & 0xFF0000) >> 16) / divisor
            g = CGFloat((hexValue & 0x00FF00) >> 8) / divisor
            b = CGFloat( hexValue & 0x0000FF) / divisor
            a = 1
        case 8:
            divisor = 255
            r = CGFloat((hexValue & 0xFF000000) >> 24) / divisor
            g = CGFloat((hexValue & 0x00FF0000) >> 16) / divisor
            b = CGFloat((hexValue & 0x0000FF00) >> 8) / divisor
            a = CGFloat( hexValue & 0x000000FF) / divisor
        default:
            return nil
        }

        #if os(iOS) || os(watchOS) || os(tvOS)
        self.init(red: r, green: g, blue: b, alpha: a)
        #else
        self.init(calibratedRed: r, green: g, blue: b, alpha: a)
        #endif
    }

    /// Initializes a color from an hex Integer  (e.g. `0x1D2E3F`) and an optional alpha value.
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let r = (hex >> 16) & 0xFF
        let g = (hex >> 8) & 0xFF
        let b = hex & 0xFF
        let red = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue = CGFloat(b) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    /// Returns an Integer representing the color in hex format (e.g. `0x112233`)
    var hex: Int {
        let rgba = rgbaComponents()
        if rgba.alpha == 1.0 {
            return lround(rgba.red * 255.0) << 16 | lround(rgba.green * 255.0) << 8 | lround(rgba.blue * 255.0)
        } else {
            return lround(rgba.red * 255.0) << 24 | lround(rgba.green * 255.0) << 16 | lround(rgba.blue * 255.0) << 8 | lround(rgba.alpha * 255.0)
        }
    }

    /// Returns a hex string representing the color (e.g. `#112233`)
    var hexString: String {
        if rgbaComponents().alpha == 1.0 {
            return "#" + String(format: "%06x", hex)
        } else {
            return "#" + String(format: "#%08x", hex)
        }
    }
}
