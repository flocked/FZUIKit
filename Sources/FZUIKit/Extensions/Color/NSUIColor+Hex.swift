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
        guard let cgColor = ColorModels.SRGB(hex: hex, alpha: alpha)?.cgColor else { return nil }
        self.init(cgColor: cgColor)
    }

    /// Initializes a color from an hex Integer  (e.g. `0x1D2E3F`) and an optional alpha value.
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let cgColor = ColorModels.SRGB(hex: hex, alpha: alpha).cgColor
        #if os(macOS)
        self.init(cgColor: cgColor)!
        #else
        self.init(cgColor: cgColor)
        #endif
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
}
