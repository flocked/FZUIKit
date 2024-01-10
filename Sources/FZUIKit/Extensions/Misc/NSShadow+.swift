//
//  NSShadow+.swift
//
//
//  Created by Florian Zand on 19.10.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

extension NSShadow {
    /// A black shadow.
    public static func black(opacity: CGFloat = 0.3, radius: CGFloat = 2.0, offset: CGPoint = CGPoint(x: 1.0, y: -1.5)) -> Self {
        let shadow = Self()
        #if os(macOS)
        shadow.shadowColor = .shadowColor.withAlphaComponent(opacity)
        #else
        shadow.shadowColor = NSUIColor.black.withAlphaComponent(opacity)
        #endif
        shadow.shadowBlurRadius = radius
        shadow.shadowOffset = CGSize(offset.x, offset.y)
        return shadow
    }

    #if os(macOS)
    /// A shadow with accent color.
    public static func accentColor(opacity: CGFloat = 0.3, radius: CGFloat = 2.0, offset: CGPoint = CGPoint(x: 1.0, y: -1.5)) -> Self {
        let shadow = Self()
        shadow.shadowColor = .controlAccentColor.withAlphaComponent(opacity)
        shadow.shadowBlurRadius = radius
        shadow.shadowOffset = CGSize(offset.x, offset.y)
        return shadow
    }
    #endif

    /// A shadow with the specified color.
    public static func color(_ color: NSUIColor, opacity: CGFloat = 0.3, radius: CGFloat = 2.0, offset: CGPoint = CGPoint(x: 1.0, y: -1.5)) -> Self {
        let shadow = Self()
        shadow.shadowColor = color.withAlphaComponent(opacity)
        shadow.shadowBlurRadius = radius
        shadow.shadowOffset = CGSize(offset.x, offset.y)
        return shadow
    }

    /// Creates a shadow from the shadow values of the specified layer.
    public convenience init(layer: CALayer) {
        self.init()
        self.shadowColor = layer.shadowColor?.nsUIColor?.withAlphaComponent(CGFloat(layer.shadowOpacity))
        self.shadowOffset = layer.shadowOffset
        self.shadowBlurRadius = layer.shadowRadius
    }
}

#endif
