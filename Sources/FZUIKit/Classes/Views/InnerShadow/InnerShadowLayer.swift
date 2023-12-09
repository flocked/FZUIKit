//
//  InnerShadowLayer.swift
//  
//
//  Created by Florian Zand on 16.09.21.
//

#if os(macOS) || os(iOS) || os(tvOS)
import Foundation
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import FZSwiftUtils

/// A layer with an inner shadow.
public class InnerShadowLayer: CALayer {
    
    /// The configuration of the inner shadow.
    public var configuration: ContentConfiguration.InnerShadow {
        get { ContentConfiguration.InnerShadow(color: shadowColor?.nsUIColor, opacity: CGFloat(shadowOpacity), radius: shadowRadius, offset: shadowOffset.point)  }
        set {
            shadowColor = newValue.color?.cgColor
            shadowOpacity = Float(newValue.opacity)
            let needsUpdate = shadowOffset != newValue.offset.size || shadowRadius != newValue.radius
            isUpdating = true
            shadowOffset = newValue.offset.size
            shadowRadius = newValue.radius
            isUpdating = false
            if needsUpdate {
                updateShadowPath()
            }
        }
    }
    
    
    /**
     Initalizes an inner shadow layer with the specified configuration.
     
     - Parameters configuration: The configuration of the inner shadow.
     - Returns: The inner shadow layer.
     */
    public init(configuration: ContentConfiguration.InnerShadow) {
        super.init()
        self.configuration = configuration
    }
    
    
    override public init() {
        super.init()
        sharedInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    public override init(layer: Any) {
        super.init(layer: layer)
        sharedInit()
    }
    
    internal func sharedInit() {
        shadowOpacity = 0
        shadowColor = nil
        backgroundColor = .clear
        masksToBounds = true
        shadowOffset = .zero
        shadowRadius = 0.0
    }
    
    internal var isUpdating: Bool = false

    public override var shadowRadius: CGFloat {
        didSet { if !isUpdating, oldValue != shadowRadius { self.updateShadowPath() } }
    }
    
    public override var shadowOffset: CGSize {
        didSet { if !isUpdating, oldValue != shadowOffset { self.updateShadowPath() } }
    }
    
    override public var bounds: CGRect {
        didSet { 
            if !isUpdating, oldValue != bounds {
            updateShadowPath() } }
    }
    
    public override var cornerRadius: CGFloat {
        didSet { if !isUpdating, oldValue != cornerRadius {
            updateShadowPath() } }
    }

    internal func updateShadowPath() {
        let path: NSUIBezierPath
        let innerPart: NSUIBezierPath
        if cornerRadius != 0.0 {
            path = NSUIBezierPath(roundedRect: bounds.insetBy(dx: -20, dy: -20), cornerRadius: cornerRadius)
            #if os(macOS)
            innerPart = NSUIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).reversed
            #else
            innerPart = NSUIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).reversing()
            #endif
        } else {
            path = NSUIBezierPath(rect: bounds.insetBy(dx: -20, dy: -20))
            #if os(macOS)
            innerPart = NSUIBezierPath(rect: bounds).reversed
            #else
            innerPart = NSUIBezierPath(rect: bounds).reversing()
            #endif
        }
        path.append(innerPart)
        shadowPath = path.cgPath
    }
}

#endif
