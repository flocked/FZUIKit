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
        #if os(macOS)
        Color(nsColor: self)
        #else
        Color(uiColor: self)
        #endif
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

public extension Color {
    /// Returns the dynamic light and dark color variation of the color.
    var dynamicColors: DynamicColor {
        let dynamicColors = nsUIColor.dynamicColors
        return DynamicColor(dynamicColors.light.swiftUI, dynamicColors.dark.swiftUI)
    }
    
    /// A Boolean value indicating whether the color contains a different light and dark color variant.
    var isDynamic: Bool {
        dynamicColors.isDynamic
    }
    
    /// The dynamic light and dark variations of a color.
    struct DynamicColor {
        /// The light color.
        public let light: Color
        
        /// The dark color.
        public let dark: Color
        
        /// A Boolean value indicating whether the light color differs to the dark color.
        public var isDynamic: Bool {
            light != dark
        }
        
        init(_ light: Color, _ dark: Color) {
            self.light = light
            self.dark = dark
        }
    }
}
#endif
