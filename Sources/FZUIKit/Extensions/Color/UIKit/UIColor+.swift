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
            convenience init(
                light lightColor: @escaping @autoclosure () -> UIColor,
                dark darkColor: @escaping @autoclosure () -> UIColor) {
                self.init { traitCollection in
                    switch traitCollection.userInterfaceStyle {
                    case .dark: return darkColor()
                    default: return lightColor()
                    }
                }
            }

            /// Returns the dynamic light and dark colors.
            var dynamicColors: (light: UIColor, dark: UIColor) {
                let light = resolvedColor(with: .init(userInterfaceStyle: .light))
                let dark = resolvedColor(with: .init(userInterfaceStyle: .dark))
                return (light, dark)
            }
        }
    #endif

    public extension UIColor {
        /**
         Creates a new color object whose component values are a weighted sum of the current color object and the specified color object's.

         - Parameters:
            - fraction: The amount of the color to blend with the receiver's color. The method converts color and a copy of the receiver to RGB, and then sets each component of the returned color to fraction of color’s value plus 1 – fraction of the receiver’s.
            - color: The color to blend with the receiver's color.

         - Returns: The resulting color object.
         */
        func blended(withFraction fraction: CGFloat, of color: UIColor) -> UIColor {
            NSUIColor(rgbaComponents().blended(withFraction: fraction, of: color.rgbaComponents()))
        }
    }
#endif
