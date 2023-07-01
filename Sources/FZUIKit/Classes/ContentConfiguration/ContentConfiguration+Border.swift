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
            Self(color: .black, width: 2.0)
        }
        
        public static func dashed(color: NSColor = .black, width: CGFloat = 2.0) -> Self {
            return Self(color: color, width: width, dashPattern: [2])
        }
        
        internal var _resolvedColor: NSUIColor? = nil
        internal mutating func updateResolvedColor() {
            _resolvedColor = resolvedColor()
        }
        
        internal var isInvisible: Bool {
            return (self.width == 0.0 || self._resolvedColor == nil)
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
    internal var layerObserver: KeyValueObserver<CALayer>? {
        get { getAssociatedValue(key: "CALayer.boundsObserver", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "CALayer.boundsObserver", object: self) }
    }
    
    internal var borderLayer: DashedBorderLayer? {
        self.firstSublayer(type: DashedBorderLayer.self)
    }
    /**
     Configurates the border apperance of the view.

     - Parameters:
        - configuration:The configuration for configurating the apperance.
     */
    func configurate(using configuration: ContentConfiguration.Border) {
        if configuration.isInvisible {
            self.borderLayer?.removeFromSuperlayer()
        } else {
            if self.borderLayer == nil {
                let borderedLayer = DashedBorderLayer()
                self.addSublayer(borderedLayer)
                borderedLayer.sendToBack()
            }
            
            let borderedLayer = self.borderLayer
            
            let frameUpdateHandler: (()->()) = { [weak self] in
                guard let self = self else { return }
                let frameSize = self.frame.size
                let shapeRect = CGRect(origin: .zero, size: frameSize)
                
                borderedLayer?.cornerRadius = self.cornerRadius
                borderedLayer?.bounds = CGRect(.zero, shapeRect.size)
                borderedLayer?.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
                Swift.print("borderedLayer.position", borderedLayer?.position ?? "")
                borderedLayer?.setNeedsDisplay()
            }
            
            if borderedLayer?.layerObserver == nil {
                borderedLayer?.layerObserver = KeyValueObserver(self)
            }
            
            Swift.print("borderedLayer.anchorPoint", borderedLayer?.anchorPoint ?? "")
            
            borderedLayer?.layerObserver?[\.cornerRadius] = { old, new in
                guard old != new else { return }
                frameUpdateHandler()
            }
            
            
            borderedLayer?.layerObserver?[\.bounds] = { old, new in
                guard old != new else { return }
                frameUpdateHandler()
            }
            
            frameUpdateHandler()
            borderedLayer?.configuration = configuration
        }
    }
}

public extension CALayer {
    internal var superlayerObserver: KeyValueObserver<CALayer>? {
        get { getAssociatedValue(key: "CALayer_superlayerObserver", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "CALayer_superlayerObserver", object: self) }
    }
    
    /// Constraints the layer to the superlayer.
    func constraintToSuperlayer() {
        if let superlayer = self.superlayer {
            let frameUpdateHandler: (()->()) = { [weak self] in
                guard let self = self else { return }
                let frameSize = superlayer.frame.size
                let shapeRect = CGRect(origin: .zero, size: frameSize)
                
                self.cornerRadius = superlayer.cornerRadius
                self.cornerCurve = superlayer.cornerCurve
                self.bounds = CGRect(.zero, shapeRect.size)
                self.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
                self.setNeedsDisplay()
            }
            
            if superlayerObserver?.observedObject != superlayer {
                superlayerObserver = KeyValueObserver(superlayer)
            }
            
            superlayerObserver?[\.cornerRadius] = { old, new in
                guard old != new else { return }
                frameUpdateHandler()
            }
            
            superlayerObserver?[\.bounds] = { old, new in
                guard old != new else { return }
                frameUpdateHandler()
            }
            frameUpdateHandler()
        }
    }
    
    func removeSuperlayerConstraits() {
        self.superlayerObserver = nil
    }
}
