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
    /// nitializes a `Color` from a HEX String (e.g.: `#1D2E3F`) and an optional alpha value.
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        let scanner = Scanner(string: hex)
        if hex.hasPrefix("#") {
            scanner.currentIndex = hex.index(after: hex.startIndex)
        }
        scanner.scanHexInt64(&int)
        self.init(hex: Int(int), alpha: alpha)
    }

    /// Initializes a `Color` from an HEX Int  (e.g.: `0x1D2E3F`)and an optional alpha value.
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let r = (hex >> 16) & 0xFF
        let g = (hex >> 8) & 0xFF
        let b = hex & 0xFF
        let red = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue = CGFloat(b) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    /// Returns an Int representing the `NSColor` in hex format (e.g.: 0x112233)
    var hex: Int {
        guard let components = cgColor.components, components.count >= 3 else { return 0 }
        let red = lround(Double(components[0]) * 255.0) << 16
        let green = lround(Double(components[1]) * 255.0) << 8
        let blue = lround(Double(components[2]) * 255.0)
        return red | green | blue
    }

    /// Returns a HEX String representing the `NSColor` (e.g.: #112233)
    var hexString: String {
        let color = hex
        return "#" + String(format: "%06x", color)
    }
}
