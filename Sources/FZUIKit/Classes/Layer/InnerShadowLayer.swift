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
open class InnerShadowLayer: CALayer {
    
    /// The configuration of the inner shadow.
    open var configuration: ShadowConfiguration {
        get { ShadowConfiguration(color: color, colorTransformer: colorTransformer, opacity: CGFloat(shadowOpacity), radius: shadowRadius, offset: shadowOffset.point) }
        set {
            
            
            isUpdating = true
            color = newValue.color
            colorTransformer = newValue.colorTransformer
            if let view = superlayer?.parentView {
                updateShadowColor(for: view)
            } else {
                shadowColor = newValue.resolvedColor()?.cgColor
            }
            shadowOpacity = Float(newValue.opacity)
            let needsUpdate = shadowOffset != newValue.offset.size || shadowRadius != newValue.radius
            shadowOffset = newValue.offset.size
            shadowRadius = newValue.radius
            isUpdating = false
            if needsUpdate {
                updateShadowPath()
            }
        }
    }
    
    var _maskShape: PathShape? {
        didSet { updateShadowPath() }
    }
    
    /**
     Initalizes an inner shadow layer with the specified configuration.
     
     - Parameter configuration: The configuration of the inner shadow.
     - Returns: The inner shadow layer.
     */
    public init(configuration: ShadowConfiguration) {
        defer { self.configuration = configuration }
        super.init()
        sharedInit()
    }
    
    override public init() {
        super.init()
        sharedInit()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    override public init(layer: Any) {
        super.init(layer: layer)
        sharedInit()
    }
    
    var color: NSUIColor? = nil
    var colorTransformer: ColorTransformer? = nil
    var isUpdating: Bool = false
    var _superlayerObservation: KeyValueObservation?
    var viewObservation: KeyValueObservation?
    
    func sharedInit() {
        shadowOpacity = 0.0
        shadowColor = nil
        backgroundColor = .clear
        masksToBounds = true
        shadowOffset = .zero
        shadowRadius = 0.0
        zPosition = -CGFloat(Float.greatestFiniteMagnitude) + 1
        #if os(macOS)
        _superlayerObservation = observeChanges(for: \.superlayer) { [weak self] old, new in
            guard let self = self, old != new else { return }
            self.updateViewObservation()
        }
        #endif
    }
    
    #if os(macOS)
    func updateViewObservation() {
        if let view = superlayer?.parentView {
            updateShadowColor(for: view)
            shadowColor = color?.resolvedColor(for: view).cgColor
            viewObservation = view.observeChanges(for: \.effectiveAppearance) { [weak self] old, new in
                guard let self = self, old != new else { return }
                self.updateShadowColor(for: view)
            }
        } else {
            viewObservation = nil
        }
    }
    #endif
    
    func updateShadowColor(for view: NSUIView) {
        if let color = color?.resolvedColor(for: view) {
            shadowColor = (colorTransformer?(color) ?? color).cgColor
        }
    }
    
    func updateShadowPath() {
        let path: NSUIBezierPath
        let innerPart: NSUIBezierPath
        if let maskPath = _maskShape?.path(in: bounds.insetBy(dx: -20, dy: -20)), let innerMaskPath = maskShape?.path(in: bounds) {
            path = NSUIBezierPath(cgPath: maskPath)
            #if os(macOS)
            innerPart = NSUIBezierPath(cgPath: innerMaskPath).reversed
            #else
            innerPart = NSUIBezierPath(cgPath: innerMaskPath).reversing()
            #endif
        } else {
            path = NSUIBezierPath(roundedRect: bounds.insetBy(dx: -20, dy: -20), cornerRadius: cornerRadius)
            #if os(macOS)
            innerPart = NSUIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).reversed
            #else
            innerPart = NSUIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).reversing()
            #endif
        }
        path.append(innerPart)
        shadowPath = path.cgPath
    }
    
    override open var shadowRadius: CGFloat {
        didSet {
            if !isUpdating, oldValue != shadowRadius { updateShadowPath() }
        }
    }
    
    override open var shadowOffset: CGSize {
        didSet {
            if !isUpdating, oldValue != shadowOffset { updateShadowPath() }
        }
    }
    
    override open var bounds: CGRect {
        didSet {
            if !isUpdating, oldValue != bounds { updateShadowPath() }
        }
    }
    
    override open var cornerRadius: CGFloat {
        didSet {
            if !isUpdating, oldValue != cornerRadius { updateShadowPath() }
        }
    }
    
    override open var shadowColor: CGColor? {
        didSet {
            if !isUpdating, oldValue != shadowColor { color = shadowColor?.nsUIColor }
        }
    }
}

extension CALayer {
    class _InnerShadowLayer: CALayer {
        var isUpdating = false
        
        var configuration: ShadowConfiguration = .none {
            didSet {
                guard oldValue != configuration else { return }
                isUpdating = true
                shadowRadius = configuration.radius
                shadowOffset = configuration.offset.size
                shadowOpacity = Float(configuration.opacity)
                shadowColor = superlayer?.resolvedColor(for: configuration.resolvedColor())
                isUpdating = false
                updateShadowPath()
            }
        }
        
        func updateShadowPath() {
            let path: NSUIBezierPath
            let innerPart: NSUIBezierPath
            if let maskPath = _maskShape?.path(in: bounds.insetBy(dx: -20, dy: -20)), let innerMaskPath = maskShape?.path(in: bounds) {
                path = NSUIBezierPath(cgPath: maskPath)
                #if os(macOS)
                innerPart = NSUIBezierPath(cgPath: innerMaskPath).reversed
                #else
                innerPart = NSUIBezierPath(cgPath: innerMaskPath).reversing()
                #endif
            } else {
                path = NSUIBezierPath(roundedRect: bounds.insetBy(dx: -20, dy: -20), cornerRadius: cornerRadius)
                #if os(macOS)
                innerPart = NSUIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).reversed
                #else
                innerPart = NSUIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).reversing()
                #endif
            }
            path.append(innerPart)
            shadowPath = path.cgPath
        }
        
        var _maskShape: PathShape? {
            didSet { updateShadowPath() }
        }
        
        override var bounds: CGRect {
            didSet { if !isUpdating, oldValue != bounds { updateShadowPath() } }
        }
        
        override var cornerRadius: CGFloat {
            didSet { if !isUpdating, oldValue != cornerRadius { updateShadowPath() } }
        }
        
        override var shadowRadius: CGFloat {
            didSet { if !isUpdating, oldValue != shadowRadius { updateShadowPath() } }
        }
        
        override var shadowOffset: CGSize {
            didSet { if !isUpdating, oldValue != shadowOffset { updateShadowPath() } }
        }
        
        init(for layer: CALayer) {
            super.init()
            
            shadowOpacity = 0.0
            shadowColor = nil
            backgroundColor = .clear
            masksToBounds = true
            shadowOffset = .zero
            shadowRadius = 0.0
            layer.addSublayer(withConstraint: self)
            sendToBack()
            zPosition = -CGFloat(Float.greatestFiniteMagnitude) + 1
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

#endif
