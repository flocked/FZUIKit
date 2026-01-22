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
    /// A `SwiftUI` representation of the color.
    var swiftUI: Color {
        Color(self)
    }
}

#if os(macOS) || os(iOS) || os(tvOS)
@available(macOS 11.0, iOS 14.0, watchOS 7.0, *)
extension Color {
    /**
     Creates a color that uses the specified block to generate its color data dynamically.
     
     - Parameters:
        - lightColor: The light color.
        - darkColor: The dark color.
     */
    public init(light lightColor: @escaping @autoclosure () -> Color, dark darkColor: @escaping @autoclosure () -> Color) {
        #if os(macOS)
        self.init(nsColor: NSUIColor(light: lightColor().nsUIColor, dark: darkColor().nsUIColor))
        #else
        self.init(uiColor: NSUIColor(light: lightColor().nsUIColor, dark: darkColor().nsUIColor))
        #endif
    }
    
    /// A random color.
    public static var random: Color {
        NSUIColor.random.swiftUI
    }
    
    /// A random pastel color.
    public static var randomPastel: Color {
        NSUIColor.randomPastel.swiftUI
    }
    
    #if os(macOS)
    /// A `NSColor` representation of the color.
    public var nsColor: NSColor {
        NSColor(self)
    }
    #else
    /// A `UIColor` representation of the color.
    public var uiColor: UIColor {
        UIColor(self)
    }
    #endif
    
    var nsUIColor: NSUIColor {
        NSUIColor(self)
    }
    
    /// A Boolean value indicating whether the color is light.
    public var isLight: Bool {
        nsUIColor.isLight
    }
}
#endif
