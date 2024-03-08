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
            didSet { updateResolvedColor() }
        }

        /// The color transformer for resolving the shadow color.
        public var colorTransformer: ColorTransformer? {
            didSet { updateResolvedColor() }
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
        public var offset: CGPoint = .init(x: -1.0, y: 1.5)
        #endif

        /// A Boolean value that indicates whether the shadow is invisible (when the color is `nil`, `clear` or the opacity `0`).
        var isInvisible: Bool {
            (_resolvedColor == nil || _resolvedColor?.alphaComponent == 0.0 || opacity == 0.0)
        }

        var _resolvedColor: NSUIColor?
        mutating func updateResolvedColor() {
            _resolvedColor = resolvedColor()
        }

        #if os(macOS)
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
            updateResolvedColor()
        }
        #else
        /// Initalizes a shadow configuration.
        public init(color: NSUIColor? = .black,
                    opacity: CGFloat = 0.3,
                    radius: CGFloat = 2.0,
                    offset: CGPoint = CGPoint(x: -1.0, y: 1.5))
        {
            self.color = color
            self.opacity = opacity
            self.radius = radius
            self.offset = offset
            updateResolvedColor()
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
    }

    public extension View {
        /**
         Adds a shadow to the view.

         - Parameter configuration:The configuration for configurating the shadow.
         */
        @ViewBuilder
        func shadow(_ configuration: ShadowConfiguration)-> some View {
            if configuration.isInvisible == false, let color = configuration.resolvedColor(withOpacity: true)?.swiftUI {
                shadow(color: color, radius: configuration.radius, x: configuration.offset.x, y: -configuration.offset.y)
            } else {
                self
            }
        }
    }

    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    public extension ShadowStyle {
        /// Creates a inner shadow style with the specified inner shadow configuration.
        static func inner(_ configuration: ShadowConfiguration) -> ShadowStyle {
            .inner(color: configuration.color?.swiftUI ?? .clear, radius: configuration.radius, x: configuration.offset.x, y: configuration.offset.y)
        }
        
        /// Creates a inner shadow style with the specified shadow configuration.
        static func drop(_ configuration: ShadowConfiguration) -> ShadowStyle {
            .drop(color: configuration.color?.swiftUI ?? .clear, radius: configuration.radius, x: configuration.offset.x, y: configuration.offset.y)
        }
    }

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
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
        func shadowConfiguration(_ configuration: ShadowConfiguration) -> some ShapeStyle {
            shadow(.drop(color: configuration.resolvedColor(withOpacity: true)?.swiftUI ?? .black.opacity(0.0), radius: configuration.radius, x: configuration.offset.x, y: configuration.offset.y))
        }

        /**
         Creates a inner shadow style with the specified configuration.

         - Parameters:
            - configuration:The configuration for configurating the apperance.
         */
        func innerShadowConfiguration(_ configuration: ShadowConfiguration) -> some ShapeStyle {
            shadow(.inner(color: configuration.resolvedColor(withOpacity: true)?.swiftUI ?? .black.opacity(0.0), radius: configuration.radius, x: configuration.offset.x, y: configuration.offset.y))
        }
    }

    public extension NSShadow {
        /// Creates a shadow with the specified shadow configuration.
        convenience init(configuration: ShadowConfiguration) {
            self.init()
            configurate(using: configuration)
        }

        /// Configurates the shadow.
        func configurate(using configuration: ShadowConfiguration) {
            shadowColor = configuration.resolvedColor(withOpacity: true)
            shadowOffset = CGSize(width: configuration.offset.x, height: configuration.offset.y)
            shadowBlurRadius = configuration.radius
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
                shadowColor = configuration._resolvedColor
                shadowOffset = configuration.offset
                shadowOpacity = configuration.opacity
                shadowRadius = configuration.radius
            } else {
                optionalLayer?.configurate(using: configuration, type: type)
            }
        }

        internal var innerShadowLayer: InnerShadowLayer? {
            #if os(macOS)
                layer?.firstSublayer(type: InnerShadowLayer.self)
            #else
                layer.firstSublayer(type: InnerShadowLayer.self)
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
