//
//  ContentConfiguration+Border.swift
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

public extension ContentConfiguration {
    /**
     A configuration that specifies the appearance of a border.
     
     On AppKit `NSView` and `CALayer` can be configurated by passing the configuration to `configurate(using configuration: ContentConfiguration.Border)`.
     
     On UIKit `UIView` and `CALayer` can be configurated by passing the configuration to `configurate(using configuration: ContentConfiguration.Border)`.
     */
    struct Border: Hashable {
        
        /// The color of the border.
        public var color: NSUIColor? = nil {
            didSet { updateResolvedColor() } }
        
        /// The color transformer for resolving the border color.
        public var colorTransformer: ColorTransformer? = nil {
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
        
        /// Initalizes a border configuration.
        public init(color: NSUIColor? = nil,
                    colorTransformer: ColorTransformer? = nil,
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

        /// A border configuration without a border.
        public static func none() -> Self {
            return Self()
        }
        
        /// A configuration for a black border.
        public static func black(width: CGFloat = 2.0) -> Self {
            Self(color: .black, width: width)
        }
        
        /// A configuration for a border with the specified color.
        public static func color(_ color: NSUIColor, width: CGFloat = 2.0) -> Self {
            Self(color: color, width: width)
        }
        
        /// A configuration for a dashed border with the specified color.
        public static func dashed(color: NSUIColor = .black, width: CGFloat = 2.0) -> Self {
            return Self(color: color, width: width, dashPattern: [2])
        }
        
        internal var _resolvedColor: NSUIColor? = nil
        internal mutating func updateResolvedColor() {
            _resolvedColor = resolvedColor()
        }
        
        /// A Boolean value that indicates whether the border is invisible.
        internal var isInvisible: Bool {
            return (self.width == 0.0 || self._resolvedColor == nil || self._resolvedColor == .clear)
        }
        internal var needsDashedBordlerLayer: Bool {
           return (self.insets != .zero || self.dashPattern != nil)
        }
    }
}

public extension NSUIView {
    /**
     Configurates the border apperance of the view.

     - Parameters:
        - configuration:The configuration for configurating the apperance.
     */
    func configurate(using configuration: ContentConfiguration.Border) {
        #if os(macOS)
        wantsLayer = true
        if configuration.isInvisible || !configuration.needsDashedBordlerLayer {
            layer?.borderLayer?.removeFromSuperlayer()
        }
        if configuration.needsDashedBordlerLayer {
            layer?.configurate(using: configuration)
        } else {
            self.borderColor = configuration._resolvedColor
            self.borderWidth = configuration.width
        }
        #elseif canImport(UIKit)
        layer.configurate(using: configuration)
        #endif
    }
}

public extension CALayer {
    /**
     Configurates the border apperance of the view.

     - Parameters:
        - configuration:The configuration for configurating the apperance.
     */
    func configurate(using configuration: ContentConfiguration.Border) {
        if configuration.isInvisible || !configuration.needsDashedBordlerLayer {
            self.borderLayer?.removeFromSuperlayer()
        }
        
        if configuration.needsDashedBordlerLayer {
            self.borderColor = nil
            self.borderWidth = 0.0
            if self.borderLayer == nil {
                let borderedLayer = DashedBorderLayer()
                self.addSublayer(withConstraint: borderedLayer, insets: configuration.insets)
                // borderedLayer.sendToBack()
                borderedLayer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
            }
            self.borderLayer?.configuration = configuration
        } else {
            self.borderColor = configuration._resolvedColor?.cgColor
            self.borderWidth = configuration.width
        }
    }
    
    internal var borderLayer: DashedBorderLayer? {
        self.firstSublayer(type: DashedBorderLayer.self)
    }
}
#endif
