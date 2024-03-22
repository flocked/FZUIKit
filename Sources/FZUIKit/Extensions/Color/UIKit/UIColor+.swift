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
                - light: The light color.
                - dark: The dark color.
             */
            convenience init(
                light lightModeColor: @escaping @autoclosure () -> UIColor,
                dark darkModeColor: @escaping @autoclosure () -> UIColor
            ) {
                self.init { traitCollection in
                    switch traitCollection.userInterfaceStyle {
                    case .light:
                        return lightModeColor()
                    case .dark:
                        return darkModeColor()
                    case .unspecified:
                        return lightModeColor()
                    @unknown default:
                        return lightModeColor()
                    }
                }
            }

            /// Returns the dynamic light and dark colors.
            var dynamicColors: (light: UIColor, dark: UIColor) {
                let light = self.resolvedColor(with: .init(userInterfaceStyle: .light))
                let dark = self.resolvedColor(with: .init(userInterfaceStyle: .dark))
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
            let progress = fraction.clamped(to: 0.0...1.0)
            let fromComponents = rgbaComponents()
            let toComponents = color.rgbaComponents()

            let r = (1 - progress) * fromComponents.red + progress * toComponents.red
            let g = (1 - progress) * fromComponents.green + progress * toComponents.green
            let b = (1 - progress) * fromComponents.blue + progress * toComponents.blue
            let a = (1 - progress) * fromComponents.alpha + progress * toComponents.alpha
            return NSUIColor(red: r, green: g, blue: b, alpha: a)
        }
    }
#endif
