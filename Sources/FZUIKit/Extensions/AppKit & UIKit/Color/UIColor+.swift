//
//  UIColor+.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

#if canImport(UIKit)
import UIKit

public extension UIColor {
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

    var dynamicColors: (light: UIColor, dark: UIColor) {
        let light = self.resolvedColor(with: .init(userInterfaceStyle: .light))
        let dark = self.resolvedColor(with: .init(userInterfaceStyle: .dark))
        return (light, dark)
    }
}

public extension UIColor {
    func blended(withFraction fraction: CGFloat, of color: UIColor) -> UIColor {
        let progress = fraction.clamped(max: 1.0)
        let fromComponents = rgbaComponents()
        let toComponents = color.rgbaComponents()

        let r = (1 - progress) * fromComponents.red + progress * toComponents.red
        let g = (1 - progress) * fromComponents.green + progress * toComponents.green
        let b = (1 - progress) * fromComponents.blue + progress * toComponents.blue
        let a = (1 - progress) * fromComponents.alpha + progress * toComponents.alpha

        return NSUIColor(red: r, green: g, blue: b, alpha: a)
    }
}

public extension UIColor {
    static var shadowColor: UIColor {
        return UIColor.black
    }
}
#endif
