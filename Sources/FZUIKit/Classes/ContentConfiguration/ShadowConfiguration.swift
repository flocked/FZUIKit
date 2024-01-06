//
//  ContentConfiguration+Shadow.swift
//
//
//  Created by Florian Zand on 03.09.22.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import FZSwiftUtils
import SwiftUI

/**
 A configuration that specifies the appearance of a shadow.
 
 `NSView/UIView` and `CALayer` can be configurated by passing the configuration to `configurate(using configuration: ShadowConfiguration)`.
 */
public struct ShadowConfiguration: Hashable {
    /// The type of a shadow.
    public enum ShadowType {
        /// Inner shadow.
        case inner
        /// Outer shadow.
        case outer
    }
    
    /// The color of the shadow.
    public var color: NSUIColor? = .black {
        didSet { updateResolvedColor() } }
    
    /// The color transformer for resolving the shadow color.
    public var colorTransform: ColorTransformer? = nil {
        didSet { updateResolvedColor() } }
    
    /// Generates the resolved shadow color, using the shadow color, color transformer and optionally the opacity.
    public func resolvedColor(withOpacity: Bool = false) -> NSUIColor? {
        if let color = withOpacity == true ? color?.withAlphaComponent(opacity) : color {
            return colorTransform?(color) ?? color
        }
        return nil
    }
    
    /// The opacity of the shadow.
    public var opacity: CGFloat = 0.3
    
    /// The blur radius of the shadow.
    public var radius: CGFloat = 2.0
    
    /// The offset of the shadow.
    public var offset: CGPoint = .init(x: 1.0, y: -1.5)

    /// A Boolean value that indicates whether the shadow is invisible (when the color is `nil`, `clear` or the opacity `0`).
    internal var isInvisible: Bool {
        return (_resolvedColor == nil || _resolvedColor?.alphaComponent == 0.0 || opacity == 0.0)
    }
    
    internal var _resolvedColor: NSUIColor? = nil
    internal mutating func updateResolvedColor() {
        _resolvedColor = resolvedColor()
    }
    
    /// Initalizes a shadow configuration.
    public init(color: NSUIColor? = .black,
                opacity: CGFloat = 0.3,
                radius: CGFloat = 2.0,
                offset: CGPoint = CGPoint(x: 1.0, y: -1.5))
    {
        self.color = color
        self.opacity = opacity
        self.radius = radius
        self.offset = offset
        self.updateResolvedColor()
    }

    /// A configuration without shadow.
    public static func none() -> Self { return Self(color: nil, opacity: 0.0) }
    
    /// A configuration for a black shadow.
    public static func black(opacity: CGFloat = 0.4, radius: CGFloat = 2.0, offset: CGPoint = CGPoint(x: 1.0, y: -1.5)) -> Self { return Self(color: .black, opacity: opacity, radius: radius, offset: offset) }
    
    #if os(macOS)
    /// A configuration for a accent color shadow.
    public static func accentColor(opacity: CGFloat = 0.3, radius: CGFloat = 2.0, offset: CGPoint = CGPoint(x: 1.0, y: -1.5)) -> Self { return Self(color: .controlAccentColor, opacity: opacity, radius: radius, offset: offset) }
    #endif
    
    /// A configuration for a shadow with the specified color.
    public static func color(_ color: NSUIColor, opacity: CGFloat = 0.3, radius: CGFloat = 2.0, offset: CGPoint = CGPoint(x: 1.0, y: -1.5)) -> Self {
        return Self(color: color, opacity: opacity, radius: radius, offset: offset)
    }
}

public extension View {
    @ViewBuilder
    /**
     Configurates the shadow of the view.

     - Parameters:
        - configuration:The configuration for configurating the apperance.
     */
    func configurate(using configuration: ShadowConfiguration, type: ShadowConfiguration.ShadowType) -> some View {
        if type == .outer {
            if configuration.isInvisible == false, let color = configuration.resolvedColor(withOpacity: true)?.swiftUI {
                self
                    .shadow(color: color, radius: configuration.radius, x: configuration.offset.x, y: configuration.offset.y)
            } else {
                self
            }
        } else {
            if configuration.isInvisible == false, let color = configuration.resolvedColor(withOpacity: true)?.swiftUI {
                self
                    .shadow(color: color, radius: configuration.radius, x: configuration.offset.x, y: configuration.offset.y)
            } else {
                self
            }
        }
    }
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
public extension BackgroundStyle {
    /**
     Creates a shadow style with the specified configuration.

     - Parameters:
        - configuration:The configuration for configurating the apperance.
     */
    func shadowConfiguration(_ configuration: ShadowConfiguration) -> some ShapeStyle {
          self
            .shadow(.drop(color: configuration.resolvedColor(withOpacity: true)?.swiftUI ?? .black.opacity(0.0), radius: configuration.radius, x: configuration.offset.x, y: configuration.offset.y))
    }
    
    /**
     Creates a inner shadow style with the specified configuration.

     - Parameters:
        - configuration:The configuration for configurating the apperance.
     */
    func innerShadowConfiguration(_ configuration: ShadowConfiguration) -> some ShapeStyle {
          self
            .shadow(.inner(color: configuration.resolvedColor(withOpacity: true)?.swiftUI ?? .black.opacity(0.0), radius: configuration.radius, x: configuration.offset.x, y: configuration.offset.y))
    }
}

public extension NSShadow {
    /// Creates a shadow with the specified shadow configuration.
    convenience init(configuration: ShadowConfiguration) {
        self.init()
        self.configurate(using: configuration)
    }
    
    /// Configurates the shadow.
    func configurate(using configuration: ShadowConfiguration) {
        self.shadowColor = configuration.resolvedColor(withOpacity: true)
        self.shadowOffset = CGSize(width: configuration.offset.x, height: configuration.offset.y)
        self.shadowBlurRadius = configuration.radius
    }
}

public extension NSUIView {
    /**
     Configurates the shadow of the view.

     - Parameters:
     - configuration:The configuration of the shadow.
     */
    func configurate(using configuration: ShadowConfiguration, type: ShadowConfiguration.ShadowType) {
        if type == .outer {
            self.shadowColor = configuration._resolvedColor
            self.shadowOffset = configuration.offset
            self.shadowOpacity = configuration.opacity
            self.shadowRadius = configuration.radius
        } else {
            optionalLayer?.configurate(using: configuration, type: type)
        }
    }
    
    internal var innerShadowLayer: InnerShadowLayer? {
        #if os(macOS)
         self.layer?.firstSublayer(type: InnerShadowLayer.self)
        #else
        self.layer.firstSublayer(type: InnerShadowLayer.self)
        #endif

    }
}

public extension CALayer {
    /**
     Configurates the shadow of the layer.

     - Parameters:
        - configuration:The configuration of the shadow.
     */
    func configurate(using configuration: ShadowConfiguration, type: ShadowConfiguration.ShadowType) {
        if type == .outer {
            self.shadow = configuration
        } else {
            if configuration.isInvisible {
                self.innerShadowLayer?.removeFromSuperlayer()
            } else {
                if self.innerShadowLayer == nil {
                    let innerShadowLayer = InnerShadowLayer()
                    self.addSublayer(withConstraint: innerShadowLayer)
                    innerShadowLayer.sendToBack()
                    innerShadowLayer.zPosition = -CGFloat(Float.greatestFiniteMagnitude) + 1
                }
                self.innerShadowLayer?.configuration = configuration
            }
        }
    }
    
    
    internal var innerShadowLayer: InnerShadowLayer? {
        self.firstSublayer(type: InnerShadowLayer.self)
    }
}

/*
public extension NSMutableAttributedString {
    /// Configurates the shadow of the attributed string.
    func configurate(using configuration: ShadowConfiguration) {
        var attributes = self.attributes(at: 0, effectiveRange: nil)
        attributes[.shadow] = configuration.isInvisible ? nil : NSShadow(configuration: configuration)
        self.setAttributes(attributes, range: NSRange(0..<length))
    }
}

@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
public extension AttributedString {
    /// Configurates the shadow of the attributed string.
    mutating func configurate(using configuration: ShadowConfiguration) {
        self.shadow = configuration.isInvisible ? nil : NSShadow(configuration: configuration)
    }
}
*/
#endif
