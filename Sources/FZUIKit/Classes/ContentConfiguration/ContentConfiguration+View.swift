//
//  File.swift
//  
//
//  Created by Florian Zand on 05.10.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import FZSwiftUtils
import SwiftUI

public extension ContentConfiguration {
    /**
     A configuration that specifies the appearance of a view.
     
     On AppKit `NSView` can be configurated by passing the configuration to `configurate(using configuration: ContentConfiguration.View)`.
     
     On UIKit `UIView` can be configurated by passing the configuration to `configurate(using configuration: ContentConfiguration.View)`.
     */
    struct View: Hashable {
        /// The background color.
        var backgroundColor: NSUIColor? = nil {
            didSet { updateResolvedColor() } }
        
        /// The color transformer for resolving the background color.
        public var backgroundColorTransformer: ColorTransformer? = nil {
            didSet { updateResolvedColor() } }
        
        /// Generates the resolved background color,, using the background color and color transformer.
        public func resolvedBackgroundColor() -> NSUIColor? {
            if let backgroundColor = self.backgroundColor {
                return backgroundColorTransformer?(backgroundColor) ?? backgroundColor
            }
            return nil
        }
        
        /// The visual effect of the view.
        var visualEffect: VisualEffect? = nil
        
        /// The border of the view.
        var border: Border = .none()
        
        /// The shadow of the view.
        var shadow: Shadow = .none()
        
        /// The inner shadow of the view.
        var innerShadow: InnerShadow = .none()
        
        /// The corner radius of the view.
        var cornerRadius: CGFloat = 0.0
        
        /// The corner curve of the view.
        var cornerCurve: CALayerCornerCurve = .circular
        
        /// The rounded corners of the view.
        var roundedCorners: CACornerMask = .all
        
        /// The mask of the view.
        var mask: NSUIView? = nil
        
        /// The scale transform of the view.
        var scale: CGSize = CGSize(width: 1, height: 1)
        
        public init() {
            
        }
        
        internal var _backgroundColor: NSUIColor? = nil
        internal mutating func updateResolvedColor() {
            _backgroundColor = resolvedBackgroundColor()
        }
    }
}

public extension NSUIView {
    /**
     Configurates the border apperance of the view.

     - Parameters:
        - configuration:The configuration for configurating the apperance.
     */
    func configurate(using configuration: ContentConfiguration.View) {
        #if os(macOS)
        wantsLayer = true
        #endif
        self.backgroundColor = configuration._backgroundColor
        self.cornerRadius = configuration.cornerRadius
        self.cornerCurve = configuration.cornerCurve
        self.roundedCorners = configuration.roundedCorners
        self.mask = configuration.mask
        self.configurate(using: configuration.border)
        self.configurate(using: configuration.shadow)
        self.configurate(using: configuration.innerShadow)
        self.visualEffect = configuration.visualEffect
    }
}

#endif

/*
 transform: CGAffineTransform {
 var transform3D: CATransform3D
 */
