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
import SwiftUI

public extension NSUIColor {
    /// Initializes a color from a hex string (e.g. `#1D2E3F`) and an optional alpha value.
    convenience init?(hex: String, alpha: CGFloat = 1.0) {
        guard let rgb = ColorModels.SRGB(hex: hex, alpha: alpha) else { return nil }
        #if os(macOS)
        self.init(calibratedRed: rgb.red, green: rgb.green, blue: rgb.blue, alpha: rgb.alpha)
        #else
        self.init(red: rgb.red, green: rgb.green, blue: rgb.blue, alpha: rgb.alpha)
        #endif
    }

    /// Initializes a color from an hex Integer  (e.g. `0x1D2E3F`) and an optional alpha value.
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let rgb = ColorModels.SRGB(hex: hex, alpha: alpha)
        #if os(macOS)
        self.init(calibratedRed: rgb.red, green: rgb.green, blue: rgb.blue, alpha: rgb.alpha)
        #else
        self.init(red: rgb.red, green: rgb.green, blue: rgb.blue, alpha: rgb.alpha)
        #endif
    }

    /// Returns an Integer representing the color in hex format (e.g. `0x112233`)
    var hex: Int {
        rgb().hex
    }

    /// Returns a hex string representing the color (e.g. `#112233`)
    var hexString: String {
        rgb().hexString
    }
}

public extension CFType where Self == CGColor {
    /// Initializes a color from a hex string (e.g. `#1D2E3F`) and an optional alpha value.
    init?(hex: String, alpha: CGFloat = 1.0) {
        guard let color = NSUIColor(hex: hex, alpha: alpha)?.cgColor else { return nil }
        self = color
    }

    /// Initializes a color from an hex Integer  (e.g. `0x1D2E3F`) and an optional alpha value.
    init(hex: Int, alpha: CGFloat = 1.0) {
       self = NSUIColor(hex: hex, alpha: alpha).cgColor
    }
}

public extension CGColor {
    /// Returns an Integer representing the color in hex format (e.g. `0x112233`)
    var hex: Int {
        rgb().hex
    }

    /// Returns a hex string representing the color (e.g. `#112233`)
    var hexString: String {
        rgb().hexString
    }
}

public extension Color {
    /// Initializes a color from a hex string (e.g. `#1D2E3F`) and an optional alpha value.
    init?(hex: String, alpha: CGFloat = 1.0) {
        guard let color = NSUIColor(hex: hex, alpha: alpha)?.swiftUI else { return nil }
        self = color
    }

    /// Initializes a color from an hex Integer  (e.g. `0x1D2E3F`) and an optional alpha value.
    init(hex: Int, alpha: CGFloat = 1.0) {
       self = NSUIColor(hex: hex, alpha: alpha).swiftUI
    }
    
    /// Returns an Integer representing the color in hex format (e.g. `0x112233`)
    var hex: Int {
        rgb().hex
    }

    /// Returns a hex string representing the color (e.g. `#112233`)
    var hexString: String {
        rgb().hexString
    }
}

/*
 var hex: Int {
     let rgb = rgb()
     if rgb.alpha == 1.0 {
         return lround(rgb.red * 255.0) << 16 | lround(rgb.green * 255.0) << 8 | lround(rgb.blue * 255.0)
     } else {
         return lround(rgb.red * 255.0) << 24 | lround(rgb.green * 255.0) << 16 | lround(rgb.blue * 255.0) << 8 | lround(rgb.alpha * 255.0)
     }
 }

 var hexString: String {
     let rgb = rgb()
     if rgb.alpha == 1.0 {
         return "#" + String(format: "%06x", lround(rgb.red * 255.0) << 16 | lround(rgb.green * 255.0) << 8 | lround(rgb.blue * 255.0))
     } else {
         return "#" + String(format: "#%08x", lround(rgb.red * 255.0) << 24 | lround(rgb.green * 255.0) << 16 | lround(rgb.blue * 255.0) << 8 | lround(rgb.alpha * 255.0))
     }
 }
 */
