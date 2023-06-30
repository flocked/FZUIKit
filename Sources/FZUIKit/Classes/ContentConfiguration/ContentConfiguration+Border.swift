//
//  ContentConfiguration+Border.swift
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
    /// A configuration that specifies the appearance of a border.
    struct Border: Hashable {
        
        /// The color of the border.
        public var color: NSUIColor? = nil {
            didSet { updateResolvedColor() } }
        
        /// The color transformer for resolving the border color.
        public var colorTransformer: NSUIConfigurationColorTransformer? = nil {
            didSet { updateResolvedColor() } }
        
        /// Generates the resolved border color for the specified border color, using the border color and color transformer.
        public func resolvedColor() -> NSUIColor? {
            if let color = self.color {
                return colorTransformer?(color) ?? color
            }
            return nil
        }
        
        /// The width of the border.
        public var width: CGFloat = 0.0
        
        /// The dash pattern of the border.
        public var dashPattern: [CGFloat]? = nil
        
        /// The insets of the border.
        public var insets: NSDirectionalEdgeInsets = .init(0)
        
        public init(color: NSUIColor? = nil,
                    colorTransformer: NSUIConfigurationColorTransformer? = nil,
                    width: CGFloat = 0.0,
                    dashPattern: [CGFloat]? = nil,
                    insets: NSDirectionalEdgeInsets = .init(0))
        {
            self.color = color
            self.width = width
            self.dashPattern = dashPattern
            self.colorTransformer = colorTransformer
            self.insets = insets
            self.updateResolvedColor()
        }

        public static func none() -> Self {
            return Self()
        }
        
        public static func black() -> Self {
            Self(color: .black, width: 1.0)
        }
        
        internal var _resolvedColor: NSUIColor? = nil
        internal mutating func updateResolvedColor() {
            _resolvedColor = resolvedColor()
        }
    }
}

#if os(macOS)
@available(macOS 10.15.1, *)
public extension NSView {
    /**
     Configurates the border apperance of the view.

     - Parameters:
        - configuration:The configuration for configurating the apperance.
     */
    func configurate(using configuration: ContentConfiguration.Border) {
        wantsLayer = true
        layer?.configurate(using: configuration)
    }
}

#elseif canImport(UIKit)
@available(iOS 14.0, *)
public extension UIView {
    /**
     Configurates the border apperance of the view.

     - Parameters:
        - configuration:The configuration for configurating the apperance.
     */
    func configurate(using configuration: ContentConfiguration.Border) {
        layer.configurate(using: configuration)
    }
}
#endif

public extension CALayer {
    internal var layerBorderObserver: KeyValueObserver<CALayer>? {
        get { getAssociatedValue(key: "CALayer.boundsObserver", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "CALayer.boundsObserver", object: self) }
    }
    
    internal var borderLayer: CAShapeLayer? {
        get { getAssociatedValue(key: "CALayer_borderLayer", object: self, initialValue: nil) }
        set {
            if newValue != self.borderLayer {
                self.borderLayer?.removeFromSuperlayer()
                if let newValue = newValue, newValue.superlayer != self {
                    self.addSublayer(newValue)
                    newValue.sendToBack()
                }
            }
            set(associatedValue: newValue, key: "CALayer_borderLayer", object: self)
        }
    }
    
    /**
     Configurates the border apperance of the view.

     - Parameters:
        - configuration:The configuration for configurating the apperance.
     */
    func configurate(using configuration: ContentConfiguration.Border) {
        if configuration._resolvedColor == nil || configuration.width == 0.0 {
            self.borderLayer?.layerBorderObserver = nil
            self.borderLayer = nil
        } else {
            if self.borderLayer == nil {
                self.borderLayer = CAShapeLayer()
                self.borderLayer?.name = "_DashedBorderLayer"
            }
            
            let frameUpdateHandler: (()->()) = { [weak self] in
                guard let self = self else { return }
                let frameSize = CGSize(width: self.frame.size.width-configuration.insets.width, height: self.frame.size.height-configuration.insets.height)
                let shapeRect = CGRect(origin: CGPoint(x: configuration.insets.leading, y: configuration.insets.bottom), size: frameSize)
                
                let scale = (shapeRect.size.width-configuration.width)/self.frame.size.width
                let cornerRadius = self.cornerRadius * scale
                
                self.borderLayer?.bounds = CGRect(.zero, shapeRect.size)
                self.borderLayer?.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
                self.borderLayer?.path = NSUIBezierPath(roundedRect: shapeRect, cornerRadius: cornerRadius).cgPath
            }
            
            if self.borderLayer?.layerBorderObserver == nil {
                self.borderLayer?.layerBorderObserver = KeyValueObserver(self)
            }
            
            self.borderLayer?.layerBorderObserver?.remove(\.cornerRadius)
            self.borderLayer?.layerBorderObserver?.remove(\.bounds)

            self.borderLayer?.layerBorderObserver?.add(\.cornerRadius) { old, new in
                Swift.print("cornerRadius changed")
                guard old != new else { return }
                frameUpdateHandler()
            }
            self.borderLayer?.layerBorderObserver?.add(\.bounds) { old, new in
                Swift.print("bounds changed")
                guard old != new else { return }
                frameUpdateHandler()
            }
            
            frameUpdateHandler()
            self.borderLayer?.cornerCurve = self.cornerCurve
            self.borderLayer?.fillColor = .clear
            self.borderLayer?.strokeColor = configuration._resolvedColor?.cgColor
            self.borderLayer?.lineWidth = configuration.width
            self.borderLayer?.lineJoin = CAShapeLayerLineJoin.round
            self.borderLayer?.lineDashPattern = configuration.dashPattern as? [NSNumber]
        }
    }
}
