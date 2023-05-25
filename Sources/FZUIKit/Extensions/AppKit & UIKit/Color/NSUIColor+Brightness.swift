//
//  File.swift
//
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
    func tinted(by amount: CGFloat = 0.2) -> NSUIColor {
        #if os(macOS)
            return blended(withFraction: amount, of: .white) ?? self
        #else
            return blended(withFraction: amount, of: .white)
        #endif
    }

    func shaded(by amount: CGFloat = 0.2) -> NSUIColor {
        #if os(macOS)
            return blended(withFraction: amount, of: .black) ?? self
        #else
            return blended(withFraction: amount, of: .black)
        #endif
    }

    func lighter(by amount: CGFloat = 0.2) -> NSUIColor {
        return HSL(color: self).lighter(amount: amount).toColor()
    }

    func darkened(by amount: CGFloat = 0.2) -> NSUIColor {
        return HSL(color: self).darkened(amount: amount).toColor()
    }

    final func saturated(by amount: CGFloat = 0.2) -> NSUIColor {
        return HSL(color: self).saturated(amount: amount).toColor()
    }

    func desaturated(by amount: CGFloat = 0.2) -> NSUIColor {
        return HSL(color: self).desaturated(amount: amount).toColor()
    }

    func grayscaled(mode: GrayscalingMode = .lightness) -> NSUIColor {
        let (r, g, b, a) = rgbaComponents()

        let l: CGFloat
        switch mode {
        case .luminance:
            l = (0.299 * r) + (0.587 * g) + (0.114 * b)
        case .lightness:
            l = 0.5 * (max(r, g, b) + min(r, g, b))
        case .average:
            l = (1.0 / 3.0) * (r + g + b)
        case .value:
            l = max(r, g, b)
        }

        return HSL(hue: 0.0, saturation: 0.0, lightness: l, alpha: a).toColor()
    }

    enum GrayscalingMode: String, Hashable {
        case luminance = "Luminance"
        case lightness = "Lightness"
        case average = "Average"
        case value = "Value"
    }
}
