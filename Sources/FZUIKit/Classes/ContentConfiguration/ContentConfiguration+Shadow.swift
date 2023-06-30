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
import FZSwiftUtils

public extension ContentConfiguration {
    /// A configuration that specifies the appearance of a shadow.
    struct Shadow: Hashable {
        public enum ShadowType {
            case inner
            case outer
        }

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
            return (color == nil || opacity == 0.0)
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

public extension NSShadow {
    convenience init(configuration: ContentConfiguration.Shadow) {
        self.init()
        self.configurate(using: configuration)
    }
    
    func configurate(using configuration: ContentConfiguration.Shadow) {
        self.shadowColor = configuration.resolvedColor(withOpacity: true)
        self.shadowOffset = CGSize(width: configuration.offset.x, height: configuration.offset.y)
        self.shadowBlurRadius = configuration.radius
    }
}

public extension NSMutableAttributedString {
    func configurate(using configuration: ContentConfiguration.Shadow) {
        var attributes = self.attributes(at: 0, effectiveRange: nil)
        attributes[.shadow] = configuration.isInvisible ? nil : NSShadow(configuration: configuration)
        self.setAttributes(attributes, range: NSRange(0..<length))
    }
}

@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
public extension AttributedString {
    mutating func configurate(using configuration: ContentConfiguration.Shadow) {
        self.shadow = configuration.isInvisible ? nil : NSShadow(configuration: configuration)
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
    internal var innerShadowLayer: InnerShadowLayer? {
        get { getAssociatedValue(key: "CALayer_innerShadowLayer", object: self, initialValue: nil) }
        set {
            if newValue != self.innerShadowLayer {
                self.innerShadowLayer?.removeFromSuperlayer()
                if let newValue = newValue, newValue.superlayer != self {
                    self.addSublayer(newValue)
                    newValue.sendToBack()
                }
            }
            set(associatedValue: newValue, key: "CALayer_innerShadowLayer", object: self)
        }
    }
    
    /**
     Configurates the shadow of the LAYER.

     - Parameters:
        - configuration:The configuration for configurating the shadow.
        - type:The type of shadow. Either inner or outer.
     */
    func configurate(using configuration: ContentConfiguration.Shadow, type: ContentConfiguration.Shadow.ShadowType = .outer) {
        if type == .outer {
            shadowColor = configuration._resolvedColor?.cgColor
            shadowOffset = CGSize(width: configuration.offset.x, height: configuration.offset.y)
            shadowRadius = configuration.radius
            shadowOpacity = Float(configuration.opacity)
        } else {
            if self.innerShadowLayer == nil {
                self.innerShadowLayer = InnerShadowLayer()
            }
            
            let frameUpdateHandler: (()->()) = { [weak self] in
                guard let self = self else { return }
                let frameSize = self.frame.size
                let shapeRect = CGRect(origin: .zero, size: frameSize)
                
                self.innerShadowLayer?.cornerRadius = self.cornerRadius
                self.innerShadowLayer?.bounds = CGRect(.zero, shapeRect.size)
                self.innerShadowLayer?.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
            }
            
            if self.innerShadowLayer?.layerObserver == nil {
                self.innerShadowLayer?.layerObserver = KeyValueObserver(self)
            }
            
            self.innerShadowLayer?.layerObserver?.remove(\.cornerRadius)
            self.innerShadowLayer?.layerObserver?.remove(\.bounds)

            self.innerShadowLayer?.layerObserver?.add(\.cornerRadius) { old, new in
                Swift.print("innerShadowLayer cornerRdius")
                guard old != new else { return }
                frameUpdateHandler()
            }
            self.innerShadowLayer?.layerObserver?.add(\.bounds) { old, new in
                Swift.print("innerShadowLayer bounds")
                guard old != new else { return }
                frameUpdateHandler()
            }
            
            frameUpdateHandler()
            self.innerShadowLayer?.color = configuration.color
            self.innerShadowLayer?.offset = CGSize(configuration.offset.x, configuration.offset.y)
            self.innerShadowLayer?.radius = configuration.radius
            self.innerShadowLayer?.opacity = Float(configuration.opacity)
        }
    }
}
