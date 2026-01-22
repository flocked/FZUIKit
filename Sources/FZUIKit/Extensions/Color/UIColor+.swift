//
//  UIColor+.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

#if canImport(UIKit)
import UIKit

#if os(iOS) || os(tvOS)
public extension UIColor {
    /**
     Creates a dynamic catalog color with the specified light and dark color.
     
     - Parameters:
        - lightColor: The light color.
        - darkColor: The dark color.
     */
    convenience init(light lightColor: @escaping @autoclosure () -> UIColor, dark darkColor: @escaping @autoclosure () -> UIColor) {
        self.init { $0.userInterfaceStyle == .dark ? darkColor() : lightColor() }
    }
    
    /// A `CIColor` representation of the color.
    var ciColor: CIColor {
        CIColor(color: self)
    }
}
#endif
#endif
