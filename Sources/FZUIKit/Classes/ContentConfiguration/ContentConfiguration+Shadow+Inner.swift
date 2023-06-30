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
        - configuration:The configuration for configurating the shadow.
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
    func firstSublayer<V>(type _: V.Type) -> V? {
        self.sublayers?.first(where: { $0 is V }) as? V
    }
    
    internal var innerShadowLayer: InnerShadowLayer? {
        self.firstSublayer(type: InnerShadowLayer.self)
    }
    
    /*
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
    */
    
    /**
     Configurates the shadow of the layer.

     - Parameters:
        - configuration:The configuration for configurating the shadow.
     */
    func configurate(using configuration: ContentConfiguration.InnerShadow) {
        Swift.print("innershadow configurate", configuration.isInvisible)
        if configuration.isInvisible {
            self.innerShadowLayer?.removeFromSuperlayer()
        } else {
            if self.innerShadowLayer == nil {
                Swift.print("innerShadowLayer add")
                let innerShadowLayer = InnerShadowLayer()
                self.addSublayer(innerShadowLayer)
                innerShadowLayer.sendToBack()
            }
            
            let frameUpdateHandler: (()->()) = { [weak self] in
                Swift.print("shadow frameUpdateHandler")
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
            
            self.innerShadowLayer?.layerObserver?[\.cornerRadius] = { old, new in
                Swift.print("innerShadowLayer cornerRdius")
                guard old != new else { return }
                frameUpdateHandler()
            }
            
            
            self.innerShadowLayer?.layerObserver?[\.bounds] = { old, new in
                Swift.print("innerShadowLayer bounds")
                guard old != new else { return }
                frameUpdateHandler()
            }
            
            Swift.print("shadow layerObserver", self.innerShadowLayer?.layerObserver ?? "" )
            
            frameUpdateHandler()
            self.innerShadowLayer?.color = configuration.color
            self.innerShadowLayer?.offset = CGSize(configuration.offset.x, configuration.offset.y)
            self.innerShadowLayer?.radius = configuration.radius
            self.innerShadowLayer?.opacity = Float(configuration.opacity)
        }
    }
}
