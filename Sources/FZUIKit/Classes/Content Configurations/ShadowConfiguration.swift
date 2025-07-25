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
 
 The shadows of `NSView/UIView` and `CALayer` can be configurated by using their `innerShadow` and `outerShadow` properties.
 */
public struct ShadowConfiguration: Hashable {
    
    /// The color of the shadow.
    public var color: NSUIColor? = .black
    
    /// The color transformer for resolving the shadow color.
    public var colorTransformer: ColorTransformer?
    
    /// Generates the resolved shadow color, using the shadow color, color transformer and optionally the opacity.
    public func resolvedColor(withOpacity: Bool = false) -> NSUIColor? {
        guard var color = color else { return nil }
        if withOpacity {
            color = ColorTransformer.opacity(opacity)(color)
        }
        return colorTransformer?(color) ?? color
    }
    
    /// The opacity of the shadow.
    public var opacity: CGFloat = 0.4 {
        didSet { opacity = opacity.clamped(min: 0.0) }
    }
    
    /// The blur radius of the shadow.
    public var radius: CGFloat = 2.0 {
        didSet { radius = radius.clamped(min: 0.0) }
    }
    
    #if os(macOS)
    /// The offset of the shadow.
    public var offset: CGPoint = .init(x: 1.0, y: -1.5)
    #else
    /// The offset of the shadow.
    public var offset: CGPoint = .init(x: 1.0, y: 1.5)
    #endif
    
    var isInvisible: Bool {
        opacity == 0.0 || resolvedColor() == nil || resolvedColor()?.alphaComponent ?? 1.0 <= 0.0
    }
    
    /**
     A Boolean value indicating whether the shadow is visible.
     
     The shadow is visible if the ``opacity`` is larger than `0` and the ``color`` isn't `nil` and has an alpha value larger than `0`.
     */
    var isVisible: Bool {
        opacity > 0.0 && resolvedColor()?.alphaComponent ?? 0.0 > 0.0
    }
        
    #if os(macOS)
    /**
     Creates a shadow configuration.
     
     - Parameters:
        - color: The color of the shadow. The default value is `nil`.
        - colorTransformer: The color transformer for resolving the shadow color. The default value is `nil`.
        - opacity:The opacity of the shadow. The default value is `0.4`.
        - radius: The blur radius of the shadow. The default value is `2.0`.
        - offset: The offset of the shadow. The default value is `[1.0, -1.5]`.
     */
    public init(color: NSUIColor? = .black, colorTransformer: ColorTransformer? = nil, opacity: CGFloat = 0.4, radius: CGFloat = 2.0, offset: CGPoint = CGPoint(x: 1.0, y: -1.5)) {
        self.color = color
        self.colorTransformer = colorTransformer
        self.opacity = opacity.clamped(min: 0.0)
        self.radius = radius.clamped(min: 0.0)
        self.offset = offset
    }
    #else
    /**
     Creates a shadow configuration.
     
     - Parameters:
        - color: The color of the shadow. The default value is `nil`.
        - colorTransformer: The color transformer for resolving the shadow color. The default value is `nil`.
        - opacity:The opacity of the shadow. The default value is `0.4`.
        - radius: The blur radius of the shadow. The default value is `2.0`.
        - offset: The offset of the shadow. The default value is `[1.0, 1.5]`.
     */
    public init(color: NSUIColor? = .black, colorTransformer: ColorTransformer? = nil, opacity: CGFloat = 0.4, radius: CGFloat = 2.0, offset: CGPoint = CGPoint(x: 1.0, y: 1.5)) {
        self.color = color
        self.colorTransformer = colorTransformer
        self.opacity = opacity.clamped(min: 0.0)
        self.radius = radius.clamped(min: 0.0)
        self.offset = offset
    }
    #endif
    
    /// A configuration without shadow.
    public static let none = Self(color: nil, opacity: 0.0)
    
    #if os(macOS)
    /**
     A configuration for a black shadow.
     
     - Parameters:
        - opacity:The opacity of the shadow. The default value is `0.4`.
        - radius: The blur radius of the shadow. The default value is `2.0`.
        - offset: The offset of the shadow. The default value is `[1.0, -1.5]`.
     */
    public static func black(opacity: CGFloat = 0.4, radius: CGFloat = 2.0, offset: CGPoint = CGPoint(x: 1.0, y: -1.5)) -> Self { Self(color: .black, opacity: opacity, radius: radius, offset: offset) }
    
    /**
     A configuration for a white shadow.
     
     - Parameters:
        - opacity:The opacity of the shadow. The default value is `0.4`.
        - radius: The blur radius of the shadow. The default value is `2.0`.
        - offset: The offset of the shadow. The default value is `[1.0, -1.5]`.
     */
    public static func white(opacity: CGFloat = 0.4, radius: CGFloat = 2.0, offset: CGPoint = CGPoint(x: 1.0, y: 1.5)) -> Self { Self(color: .white, opacity: opacity, radius: radius, offset: offset) }
    
    /**
     A configuration for a shadow with the specified color.
     
     - Parameters:
        - color:The color of the shadow.
        - opacity:The opacity of the shadow. The default value is `0.4`.
        - radius: The blur radius of the shadow. The default value is `2.0`.
        - offset: The offset of the shadow. The default value is `[1.0, -1.5]`.
     */
    public static func color(_ color: NSUIColor, opacity: CGFloat = 0.4, radius: CGFloat = 2.0, offset: CGPoint = CGPoint(x: 1.0, y: -1.5)) -> Self {
        Self(color: color, opacity: opacity, radius: radius, offset: offset)
    }
    
    /**
     A configuration for a accent color shadow.
     
     - Parameters:
        - opacity:The opacity of the shadow. The default value is `0.4`.
        - radius: The blur radius of the shadow. The default value is `2.0`.
        - offset: The offset of the shadow. The default value is `[1.0, -1.5]`.
     */
    public static func accentColor(opacity: CGFloat = 0.4, radius: CGFloat = 2.0, offset: CGPoint = CGPoint(x: 1.0, y: -1.5)) -> Self { Self(color: .controlAccentColor, opacity: opacity, radius: radius, offset: offset) }
    
    #else
    /**
     A configuration for a black shadow.
     
     - Parameters:
        - opacity:The opacity of the shadow. The default value is `0.4`.
        - radius: The blur radius of the shadow. The default value is `2.0`.
        - offset: The offset of the shadow. The default value is `[1.0, 1.5]`.
     */
    public static func black(opacity: CGFloat = 0.4, radius: CGFloat = 2.0, offset: CGPoint = CGPoint(x: 1.0, y: 1.5)) -> Self { Self(color: .black, opacity: opacity, radius: radius, offset: offset) }
    
    /**
     A configuration for a white shadow.
     
     - Parameters:
        - opacity:The opacity of the shadow. The default value is `0.4`.
        - radius: The blur radius of the shadow. The default value is `2.0`.
        - offset: The offset of the shadow. The default value is `[1.0, 1.5]`.
     */
    public static func white(opacity: CGFloat = 0.4, radius: CGFloat = 2.0, offset: CGPoint = CGPoint(x: 1.0, y: 1.5)) -> Self { Self(color: .white, opacity: opacity, radius: radius, offset: offset) }
    
    /**
     A configuration for a shadow with the specified color.
     
     - Parameters:
        - color:The color of the shadow.
        - opacity:The opacity of the shadow. The default value is `0.4`.
        - radius: The blur radius of the shadow. The default value is `2.0`.
        - offset: The offset of the shadow. The default value is `[1.0, 1.5]`.
     */
    public static func color(_ color: NSUIColor, opacity: CGFloat = 0.4, radius: CGFloat = 2.0, offset: CGPoint = CGPoint(x: 1.0, y: 1.5)) -> Self {
        Self(color: color, opacity: opacity, radius: radius, offset: offset)
    }
    
    /**
     A configuration for a tint color shadow.
     
     - Parameters:
        - opacity:The opacity of the shadow. The default value is `0.4`.
        - radius: The blur radius of the shadow. The default value is `2.0`.
        - offset: The offset of the shadow. The default value is `[1.0, 1.5]`.
     */
    @available(iOS 15.0, tvOS 15.0, *)
    public static func tintColor(opacity: CGFloat = 0.3, radius: CGFloat = 2.0, offset: CGPoint = CGPoint(x: 1.0, y: 1.5)) -> Self { Self(color: .tintColor, opacity: opacity, radius: radius, offset: offset) }
    #endif
    
    var nsShadow: NSShadow {
        NSShadow(configuration: self)
    }
}

extension ShadowConfiguration: Codable {
    public enum CodingKeys: String, CodingKey {
        case color
        case opacity
        case radius
        case offset
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(color, forKey: .color)
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
public extension NSAttributedString {
    /**
     Applies the specified shadow to the attributed string.

     - Parameter shadow: The shadow to apply.

     - Returns: A new sttributed string with the specified shadow applied.
     */
    func shadow(_ shadow: ShadowConfiguration?) -> NSAttributedString {
        if let shadow = shadow {
            return applyingAttributes([.shadow:  NSShadow(configuration: shadow)])
        } else {
            return removingAttributes([.shadow])
        }
    }
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension AttributedString {
    #if os(macOS)
    /// The shadow configuration of the attributed string.
    @available(macOS 14.0, *)
    var shadowConfiguration: ShadowConfiguration? {
        get {
            guard let shadow: NSShadow = nsAttributedString[.shadow] else { return nil }
            #if os(macOS)
            return ShadowConfiguration(color: shadow.shadowColor, radius: shadow.shadowBlurRadius, offset: shadow.shadowOffset.point)
            #else
            if let color = shadow.shadowColor as? NSUIColor {
                return ShadowConfiguration(color: color, radius: shadow.shadowBlurRadius, offset: shadow.shadowOffset.point)
            }
            return nil
            #endif
        }
        set {
            self.shadow = newValue?.nsShadow
        }
    }
    #else
    /// The shadow configuration of the attributed string.
    var shadowConfiguration: ShadowConfiguration? {
        get {
            guard let shadow = nsAttributedString.shadow else { return nil }
            #if os(macOS)
            return ShadowConfiguration(color: shadow.shadowColor, radius: shadow.shadowBlurRadius, offset: shadow.shadowOffset.point)
            #else
            if let color = shadow.shadowColor as? NSUIColor {
                return ShadowConfiguration(color: color, radius: shadow.shadowBlurRadius, offset: shadow.shadowOffset.point)
            }
            return nil
            #endif
        }
    }
    #endif
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

public extension CGContext {
    /// Enables shadowing with color a graphics context.
    func setShadow(_ configuration: ShadowConfiguration) {
        setShadow(offset: configuration.offset.size, blur: configuration.opacity, color: configuration.resolvedColor()?.cgColor)
    }
}


/// The Objective-C class for ``ShadowConfiguration``.
public class __ShadowConfiguration: NSObject, NSCopying {
    let configuration: ShadowConfiguration
    
    public init(configuration: ShadowConfiguration) {
        self.configuration = configuration
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        __ShadowConfiguration(configuration: configuration)
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        configuration == (object as? __ShadowConfiguration)?.configuration
    }
}

extension ShadowConfiguration: ReferenceConvertible {
    /// The Objective-C type for the configuration.
    public typealias ReferenceType = __ShadowConfiguration
    
    public func _bridgeToObjectiveC() -> __ShadowConfiguration {
        return __ShadowConfiguration(configuration: self)
    }
    
    public static func _forceBridgeFromObjectiveC(_ source: __ShadowConfiguration, result: inout ShadowConfiguration?) {
        result = source.configuration
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
                color: \(color?.description ?? "-")
                colorTransformer: \(colorTransformer?.id ?? "-")
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
