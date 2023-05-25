//
//  ContentConfiguration+Shadow.swift
//
//
//  Created by Florian Zand on 03.09.22.
//

#if os(macOS)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

public extension ContentConfiguration {
    /// A configuration that specifies the appearance of a shadow.
    struct Shadow: Hashable {
        public enum ShadowType {
            case inner
            case outer
        }

        public var color: NSUIColor? = .shadowColor
        public var colorTransform: NSUIConfigurationColorTransformer? = nil
        public var opacity: CGFloat = 0.3
        public var radius: CGFloat = 2.0
        public var offset: CGSize = .init(width: 1.0, height: -1.5)

        public func resolvedColor() -> NSUIColor? {
            if let color = color {
                return colorTransform?(color) ?? color
            }
            return nil
        }

        internal var isInvisible: Bool {
            return (color == nil || opacity == 0.0)
        }

        public init(color: NSUIColor? = .shadowColor,
                    opacity: CGFloat = 0.3,
                    radius: CGFloat = 2.0,
                    offset: CGSize = CGSize(width: 1.0, height: -1.5))
        {
            self.color = color
            self.opacity = opacity
            self.radius = radius
            self.offset = offset
        }

        public static func none() -> Self { return Self(color: nil, opacity: 0.0) }
        public static func `default`() -> Self { return Self() }
        #if os(macOS)
            public static func defaultAccent() -> Self { return Self(color: .controlAccentColor) }
        #endif
        public static func color(_ color: NSUIColor) -> Self {
            var value = Self()
            value.color = color
            return value
        }
    }
}

#if os(macOS)
    public extension NSView {
        /**
         Configurates the shadow of the view.

         - Parameters:
            - configuration:The configuration for configurating the shadow.
            - type:The type of shadow. Either inner or outer.
         */
        func configurate(using configuration: ContentConfiguration.Shadow, type: ContentConfiguration.Shadow.ShadowType = .outer) {
            wantsLayer = true
            layer?.configurate(using: configuration, type: type)
        }
    }

#elseif canImport(UIKit)
    public extension UIView {
        /**
         Configurates the shadow of the view.

         - Parameters:
            - configuration:The configuration for configurating the shadow.
            - type:The type of shadow. Either inner or outer.
         */
        func configurate(using configuration: ContentConfiguration.Shadow, type: ContentConfiguration.Shadow.ShadowType = .outer) {
            layer.configurate(using: configuration, type: type)
        }
    }
#endif

public extension CALayer {
    /**
     Configurates the shadow of the LAYER.

     - Parameters:
        - configuration:The configuration for configurating the shadow.
        - type:The type of shadow. Either inner or outer.
     */
    func configurate(using configuration: ContentConfiguration.Shadow, type: ContentConfiguration.Shadow.ShadowType = .outer) {
        if type == .outer {
            shadowColor = configuration.resolvedColor()?.cgColor
            shadowOffset = configuration.offset
            shadowRadius = configuration.radius
            shadowOpacity = Float(configuration.opacity)
        } else {
            if let layer = sublayers?.compactMap({ $0 as? InnerShadowLayer }).first {
                layer.configuration = configuration
            } else {
                let layer = InnerShadowLayer(configuration: configuration)
                insertSublayer(layer, at: 0)
            }
        }
    }
}
