//
//  File.swift
//  
//
//  Created by Florian Zand on 30.06.23.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import FZSwiftUtils

public extension ContentConfiguration {
    /// A configuration that specifies the appearance of a inner shadow.
    struct InnerShadow: Hashable {
        /// The color of the shadow.
        public var color: NSUIColor? = .shadowColor {
            didSet { updateResolvedColor() } }
        
        /// The color transformer for resolving the shadow color.
        public var colorTransform: NSUIConfigurationColorTransformer? = nil {
            didSet { updateResolvedColor() } }
        
        /// Generates the resolved shadow color for the specified shadow color, using the shadow color and color transformer.
        public func resolvedColor(withOpacity: Bool = false) -> NSUIColor? {
            if let color = color {
                return colorTransform?(color) ?? color
            }
            return nil
        }
        
        /// The opacity of the shadow.
        public var opacity: CGFloat = 0.5
        /// The blur radius of the shadow.
        public var radius: CGFloat = 2.0
        /// The offset of the shadow.
        public var offset: CGPoint = .init(x: 1.0, y: -1.5)

        internal var isInvisible: Bool {
            return (_resolvedColor == nil || opacity == 0.0)
        }
        
        internal var _resolvedColor: NSUIColor? = nil
        internal mutating func updateResolvedColor() {
            _resolvedColor = resolvedColor()
        }

        public init(color: NSUIColor? = .shadowColor,
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

        public static func none() -> Self { return Self(color: nil, opacity: 0.0) }
        public static func `default`() -> Self { return Self() }
        public static func black() -> Self { return Self(color: .black) }
        #if os(macOS)
        public static func accentColor() -> Self { return Self(color: .controlAccentColor) }
        #endif
        public static func color(_ color: NSUIColor) -> Self {
            var value = Self()
            value.color = color
            return value
        }
    }
}

public extension NSUIView {
    /**
     Configurates the inner shadow of the view.

     - Parameters:
        - configuration:The configuration for configurating the inner shadow.
     */
    func configurate(using configuration: ContentConfiguration.InnerShadow) {
        #if os(macOS)
        wantsLayer = true
        layer?.configurate(using: configuration)
        #else
        layer.configurate(using: configuration)
        #endif
    }
}

public extension CALayer {
    /**
     Configurates the inner shadow of the layer.

     - Parameters:
        - configuration:The configuration for configurating the inner shadow.
     */
    func configurate(using configuration: ContentConfiguration.InnerShadow) {
        if configuration.isInvisible {
            self.innerShadowLayer?.removeFromSuperlayer()
        } else {
            if self.innerShadowLayer == nil {
                let innerShadowLayer = InnerShadowLayer()
                self.addSublayer(withConstraint: innerShadowLayer)
                innerShadowLayer.sendToBack()
            }
            
            self.innerShadowLayer?.configuration = configuration
        }
    }
    
    internal var innerShadowLayer: InnerShadowLayer? {
        self.firstSublayer(type: InnerShadowLayer.self)
    }
}
