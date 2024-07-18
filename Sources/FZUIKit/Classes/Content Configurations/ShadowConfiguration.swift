//
//  ShadowConfiguration.swift
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
 
 The shadows of `NSView`, `UIView` and `CALayer` can be configurated by using the properties `innerShadow` and `outerShadow`.
 */
public struct ShadowConfiguration: Hashable {
    /// The type of a shadow.
    enum ShadowType {
        /// Inner shadow.
        case inner
        /// Outer shadow.
        case outer
    }
    
    /// The color of the shadow.
    public var color: NSUIColor? = .black {
        didSet { _resolvedColor = resolvedColor() }
    }
    
    /// The color transformer for resolving the shadow color.
    public var colorTransformer: ColorTransformer? {
        didSet { _resolvedColor = resolvedColor() }
    }
    
    /// Generates the resolved shadow color, using the shadow color, color transformer and optionally the opacity.
    public func resolvedColor(withOpacity: Bool = false) -> NSUIColor? {
        if let color = withOpacity == true ? color?.withAlphaComponent(opacity) : color {
            return colorTransformer?(color) ?? color
        }
        return nil
    }
    
    /// The opacity of the shadow.
    public var opacity: CGFloat = 0.3
    
    /// The blur radius of the shadow.
    public var radius: CGFloat = 2.0
    
    #if os(macOS)
    /// The offset of the shadow.
    public var offset: CGPoint = .init(x: 1.0, y: -1.5)
    #else
    /// The offset of the shadow.
    public var offset: CGPoint = .init(x: -1.0, y: 1.5)
    #endif
    
    /// A Boolean value that indicates whether the shadow is invisible (when the color is `nil`, `clear` or the opacity `0`).
    var isInvisible: Bool {
        (_resolvedColor == nil || _resolvedColor?.alphaComponent == 0.0 || opacity == 0.0)
    }
    
    var _resolvedColor: NSUIColor?
    
    #if os(macOS)
    /// Creates a shadow configuration.
    public init(color: NSUIColor? = .black,
                opacity: CGFloat = 0.3,
                radius: CGFloat = 2.0,
                offset: CGPoint = CGPoint(x: 1.0, y: -1.5))
    {
        self.color = color
        self.opacity = opacity
        self.radius = radius
        self.offset = offset
        _resolvedColor = resolvedColor()
    }
    #else
    /// Creates a shadow configuration.
    public init(color: NSUIColor? = .black,
                opacity: CGFloat = 0.3,
                radius: CGFloat = 2.0,
                offset: CGPoint = CGPoint(x: -1.0, y: 1.5))
    {
        self.color = color
        self.opacity = opacity
        self.radius = radius
        self.offset = offset
        _resolvedColor = resolvedColor()
    }
    #endif
    
    /// A configuration without shadow.
    public static func none() -> Self { Self(color: nil, opacity: 0.0) }
    
    #if os(macOS)
    
    /// A configuration for a black shadow.
    public static func black(opacity: CGFloat = 0.4, radius: CGFloat = 2.0, offset: CGPoint = CGPoint(x: 1.0, y: -1.5)) -> Self { Self(color: .black, opacity: opacity, radius: radius, offset: offset) }
    
    /// A configuration for a white shadow.
    public static func white(opacity: CGFloat = 0.4, radius: CGFloat = 2.0, offset: CGPoint = CGPoint(x: 1.0, y: 1.5)) -> Self { Self(color: .white, opacity: opacity, radius: radius, offset: offset) }
    
    /// A configuration for a shadow with the specified color.
    public static func color(_ color: NSUIColor, opacity: CGFloat = 0.3, radius: CGFloat = 2.0, offset: CGPoint = CGPoint(x: 1.0, y: -1.5)) -> Self {
        Self(color: color, opacity: opacity, radius: radius, offset: offset)
    }
    
    /// A configuration for a accent color shadow.
    public static func accentColor(opacity: CGFloat = 0.3, radius: CGFloat = 2.0, offset: CGPoint = CGPoint(x: 1.0, y: -1.5)) -> Self { Self(color: .controlAccentColor, opacity: opacity, radius: radius, offset: offset) }
    
    #else
    
    /// A configuration for a black shadow.
    public static func black(opacity: CGFloat = 0.4, radius: CGFloat = 2.0, offset: CGPoint = CGPoint(x: -1.0, y: 1.5)) -> Self { Self(color: .black, opacity: opacity, radius: radius, offset: offset) }
    
    /// A configuration for a white shadow.
    public static func white(opacity: CGFloat = 0.4, radius: CGFloat = 2.0, offset: CGPoint = CGPoint(x: -1.0, y: 1.5)) -> Self { Self(color: .white, opacity: opacity, radius: radius, offset: offset) }
    
    /// A configuration for a shadow with the specified color.
    public static func color(_ color: NSUIColor, opacity: CGFloat = 0.3, radius: CGFloat = 2.0, offset: CGPoint = CGPoint(x: -1.0, y: 1.5)) -> Self {
        Self(color: color, opacity: opacity, radius: radius, offset: offset)
    }
    #endif
    
    #if os(iOS)
    /// A configuration for a tint color shadow.
    @available(iOS 15.0, *)
    public static func tintColor(opacity: CGFloat = 0.3, radius: CGFloat = 2.0, offset: CGPoint = CGPoint(x: 1.0, y: -1.5)) -> Self { Self(color: .tintColor, opacity: opacity, radius: radius, offset: offset) }
    #endif
}

extension ShadowConfiguration: Codable {
    public enum CodingKeys: String, CodingKey {
        case color
        case resolvedColor
        case opacity
        case radius
        case offset
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(color, forKey: .color)
        try container.encode(_resolvedColor, forKey: .resolvedColor)
        try container.encode(opacity, forKey: .opacity)
        try container.encode(radius, forKey: .radius)
        try container.encode(offset, forKey: .offset)
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self = .init(color: try values.decode(Optional<NSUIColor>.self, forKey: .color),
                     opacity: try values.decode(CGFloat.self, forKey: .opacity),
                     radius: try values.decode(CGFloat.self, forKey: .radius),
                     offset: try values.decode(CGPoint.self, forKey: .offset))
        _resolvedColor = try values.decode(Optional<NSUIColor>.self, forKey: .resolvedColor)
    }
}

extension NSUIView {
    /**
     Configurates the shadow of the view.
     
     - Parameters:
     - configuration:The configuration of the shadow.
     - type: The type of shadow (either `inner` or `outer`).
     */
    func configurate(using configuration: ShadowConfiguration, type: ShadowConfiguration.ShadowType) {
        if type == .outer {
            shadowColor = configuration._resolvedColor
            shadowOffset = configuration.offset
            shadowOpacity = configuration.opacity
            shadowRadius = configuration.radius
            if !configuration.isInvisible {
                clipsToBounds = false
            }
        } else {
            optionalLayer?.configurate(using: configuration, type: type)
        }
    }
    
    internal var innerShadowLayer: InnerShadowLayer? {
        optionalLayer?.firstSublayer(type: InnerShadowLayer.self)
    }
}

extension CALayer {
    /**
     Configurates the shadow of the layer.
     
     - Parameters:
     - configuration:The configuration of the shadow.
     - type: The type of shadow (either `inner` or `outer`).
     */
    func configurate(using configuration: ShadowConfiguration, type: ShadowConfiguration.ShadowType) {
        if type == .outer {
            shadow = configuration
        } else {
            if configuration.isInvisible {
                innerShadowLayer?.removeFromSuperlayer()
            } else {
                if innerShadowLayer == nil {
                    let innerShadowLayer = InnerShadowLayer()
                    addSublayer(withConstraint: innerShadowLayer)
                    innerShadowLayer.sendToBack()
                    innerShadowLayer.zPosition = -CGFloat(Float.greatestFiniteMagnitude) + 1
                }
                innerShadowLayer?.configuration = configuration
            }
        }
    }
    
    internal var innerShadowLayer: InnerShadowLayer? {
        firstSublayer(type: InnerShadowLayer.self)
    }
}

public extension View {
    /**
     Adds a shadow to the view.
     
     - Parameter configuration:The configuration for configurating the shadow.
     */
    @ViewBuilder
    func shadow(_ configuration: ShadowConfiguration?)-> some View {
        if let configuration = configuration, !configuration.isInvisible, let color = configuration.resolvedColor(withOpacity: true)?.swiftUI {
            shadow(color: color, radius: configuration.radius, x: configuration.offset.x, y: -configuration.offset.y)
        } else {
            self
        }
    }
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
public extension ShadowStyle {
    /// Creates a inner shadow style with the specified shadow configuration.
    static func inner(_ configuration: ShadowConfiguration) -> ShadowStyle {
        .inner(color: configuration.color?.swiftUI ?? .clear, radius: configuration.radius, x: configuration.offset.x, y: configuration.offset.y)
    }
    
    /// Creates a drop shadow style with the specified shadow configuration.
    static func drop(_ configuration: ShadowConfiguration) -> ShadowStyle {
        .drop(color: configuration.color?.swiftUI ?? .clear, radius: configuration.radius, x: configuration.offset.x, y: configuration.offset.y)
    }
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension ShapeStyle where Self == AnyShapeStyle {
    /// Returns a shape style that applies the specified shadow configuration to the current style.
    public static func shadow(_ configuration: ShadowConfiguration) -> some ShapeStyle {
        .shadow(.drop(configuration))
    }
    
    /// Returns a shape style that applies the specified inner shadow configuration to the current style.
    public static func innerShadow(_ configuration: ShadowConfiguration) -> some ShapeStyle {
        .shadow(.inner(configuration))
    }
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
public extension BackgroundStyle {
    /**
     Creates a shadow style with the specified configuration.
     
     - Parameters:
     - configuration:The configuration for configurating the apperance.
     */
    func shadow(_ configuration: ShadowConfiguration) -> some ShapeStyle {
        shadow(.drop(configuration))
    }
    
    /**
     Creates a inner shadow style with the specified configuration.
     
     - Parameters:
     - configuration:The configuration for configurating the apperance.
     */
    func innerShadow(_ configuration: ShadowConfiguration) -> some ShapeStyle {
        shadow(.inner(configuration))
    }
}

public extension NSShadow {
    /// Creates a shadow with the specified shadow configuration.
    convenience init(configuration: ShadowConfiguration) {
        self.init()
        self.configuration = configuration
    }
    
    /// The shadow configuration.
    var configuration: ShadowConfiguration {
        get { 
            #if os(macOS)
            ShadowConfiguration(color: shadowColor, opacity: shadowColor?.alphaComponent ?? 1.0, radius: shadowBlurRadius, offset: shadowOffset.point)
            #else
            let shadowColor = shadowColor as? NSUIColor
            return ShadowConfiguration(color: shadowColor, opacity: shadowColor?.alphaComponent ?? 1.0, radius: shadowBlurRadius, offset: shadowOffset.point)
            #endif
        }
        set {
            shadowColor = newValue.resolvedColor(withOpacity: true)
            shadowOffset = newValue.offset.size
            shadowBlurRadius = newValue.radius
        }
    }
}


/// The Objective-C class for ``ShadowConfiguration``.
public class __ShadowConfiguration: NSObject, NSCopying {
    var color: NSUIColor?
    var colorTransformer: ColorTransformer?
    var opacity: CGFloat = 0.3
    var radius: CGFloat = 2.0
    var offset: CGPoint = .init(x: 1.0, y: -1.5)
    var _resolvedColor: NSUIColor?
    
    public init(color: NSUIColor?, opacity: CGFloat, radius: CGFloat, offset: CGPoint, resolvedColor: NSUIColor?) {
        self.color = color
        self.opacity = opacity
        self.radius = radius
        self.offset = offset
        self._resolvedColor = resolvedColor
        super.init()
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        __ShadowConfiguration(color: color, opacity: opacity, radius: radius, offset: offset, resolvedColor: _resolvedColor)
    }
}

extension ShadowConfiguration: ReferenceConvertible {
    /// The Objective-C type for the configuration.
    public typealias ReferenceType = __ShadowConfiguration
    
    public func _bridgeToObjectiveC() -> __ShadowConfiguration {
        return __ShadowConfiguration(color: color, opacity: opacity, radius: radius, offset: offset, resolvedColor: _resolvedColor)
    }
    
    public static func _forceBridgeFromObjectiveC(_ source: __ShadowConfiguration, result: inout ShadowConfiguration?) {
        result = ShadowConfiguration(color: source.color, opacity: source.opacity, radius: source.radius, offset: source.offset)
    }
    
    public static func _conditionallyBridgeFromObjectiveC(_ source: __ShadowConfiguration, result: inout ShadowConfiguration?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return true
    }
    
    public static func _unconditionallyBridgeFromObjectiveC(_ source: __ShadowConfiguration?) -> ShadowConfiguration {
        if let source = source {
            var result: ShadowConfiguration?
            _forceBridgeFromObjectiveC(source, result: &result)
            return result!
        }
        return ShadowConfiguration()
    }
    
    public var description: String {
              """
              ShadowConfiguration(
                color: \(String(describing: color))
                colorTransformer: \(String(describing: colorTransformer))
                opacity: \(opacity)
                radius: \(radius)
                offset: \(offset)
              )
              """
    }
    
    public var debugDescription: String {
        description
    }
}
#endif

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
