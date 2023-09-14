//
//  Color+.swift
//
//
//  Created by Florian Zand on 06.10.22.
//

import SwiftUI

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public extension NSUIColor {
    /// A SwiftUI representation of the color.
    var swiftUI: Color {
        return Color(self)
    }
}

#if os(macOS) || os(iOS) || os(tvOS)
public extension Color {
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, *)
    init(light lightModeColor: @escaping @autoclosure () -> Color,
         dark darkModeColor: @escaping @autoclosure () -> Color)
    {
        self.init(NSUIColor(
            light: NSUIColor(lightModeColor()),
            dark: NSUIColor(darkModeColor())
        ))
    }
}
#endif

@available(macOS 11.0, iOS 14.0, watchOS 7.0, *)
public extension Color {
    var secondary: Color {
        opacity(0.15)
    }

    /// A random color.
    static func random() -> Color {
        return Color(NSUIColor.random())
    }
    
    /// A random pastel color.
    static func randomPastel() -> Color {
        return Color(NSUIColor.randomPastel())
    }

    /**
     Creates a new color from the current mixed with with the specified color and amount.
     
     - Parameters:
        - color: The color to mix.
        - amount: The amount of the color to mix with the current color.
     
     - Returns: The new mixed color.
     */
    func mixed(with color: Color, by amount: CGFloat = 0.5) -> Color {
        let amount = amount.clamped(max: 1.0)
        let nsUIColor = NSUIColor(self)
        #if os(macOS)
        return Color(nsUIColor.blended(withFraction: amount, of: NSUIColor(color)) ?? nsUIColor)
        #elseif canImport(UIKit)
        return Color(nsUIColor.blended(withFraction: amount, of: NSUIColor(color)))
        #endif
    }
    
    /**
     Brightens the color by the specified amount.
     
     - Parameters amount: The amount of brightness.
     - Returns: The brightened color.
     */
    func lighter(by amount: CGFloat = 0.2) -> Color {
        let amount = amount.clamped(max: 1.0)
        return brightness(1.0 + amount)
    }

    /**
     Darkens the color by the specified amount.
     
     - Parameters amount: The amount of darken.
     - Returns: The darkened color.
     */
    func darkened(by amount: CGFloat = 0.2) -> Color {
        let amount = amount.clamped(max: 1.0)
        return brightness(1.0 - amount)
    }

    internal func brightness(_ amount: CGFloat) -> Color {
        var amount = amount
        if amount > 1.0 {
            amount = amount - 1.0
            return mixed(with: .white, by: amount)
        } else if amount < 1.0 {
            amount = amount.clamped(max: 1.0)
            amount = 1.0 - amount
            return mixed(with: .black, by: amount)
        }
        return self
    }
}
