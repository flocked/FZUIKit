//
//  ContentConfiguration+View.swift
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

#if os(macOS)
/**
 A configuration that specifies the appearance of a view.
 
 `NSView`and `UIView` can be configurated by applying the configuration to the receiver's `configurate(using:_)`.
 */
public struct ViewConfiguration: Hashable {
    /// The background color.
    public var backgroundColor: NSUIColor? = nil {
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
    public var visualEffect: VisualEffectConfiguration? = nil
    
    /// The border of the view.
    public var border: BorderConfiguration = .none()
    
    /// The shadow of the view.
    public var shadow: ShadowConfiguration = .none()
    
    /// The inner shadow of the view.
    public var innerShadow: ShadowConfiguration = .none()
    
    /// The alpha value of the view.
    public var alpha: CGFloat = 1.0
    
    /// The corner radius of the view.
    public var cornerRadius: CGFloat = 0.0
    
    /// The corner curve of the view.
    public var cornerCurve: CALayerCornerCurve = .circular
    
    /// The rounded corners of the view.
    public var roundedCorners: CACornerMask = .all
    
    /// The mask of the view.
    public var mask: NSUIView? = nil
    
    /// A Boolean value indicating whether the mask is inverted.
    public var maskIsInverted: Bool = false
    
    /// The scale transform of the view.
    public var scale: CGSize = CGSize(width: 1, height: 1)
    
    /// The rotation of the view as euler angles in degrees.
    public var rotation: CGVector3 = .zero
    
    /// The background configuration of the view.
    public var backgrpundConfiguration: NSContentConfiguration? = nil
    
    public init() {
        
    }
    
    internal var _backgroundColor: NSUIColor? = nil
    internal mutating func updateResolvedColor() {
        _backgroundColor = resolvedBackgroundColor()
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(backgroundColor)
        hasher.combine(backgroundColorTransformer)
        hasher.combine(_backgroundColor)
        hasher.combine(visualEffect)
        hasher.combine(border)
        hasher.combine(shadow)
        hasher.combine(innerShadow)
        hasher.combine(alpha)
        hasher.combine(cornerRadius)
        hasher.combine(cornerCurve)
        hasher.combine(roundedCorners)
        hasher.combine(mask)
        hasher.combine(maskIsInverted)
        hasher.combine(scale)
        hasher.combine(rotation)
    }
    
    public static func == (lhs: ViewConfiguration, rhs: ViewConfiguration) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
#else
/**
 A configuration that specifies the appearance of a view.
 
 `NSView/UIView` can be configurated by passing the configuration to `configurate(using configuration: ViewConfiguration)`.
 */
public struct ViewConfiguration: Hashable {
    /// The background color.
    public var backgroundColor: NSUIColor? = nil {
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
    public var visualEffect: VisualEffectConfiguration? = nil
    
    /// The border of the view.
    public var border: BorderConfiguration = .none()
    
    /// The shadow of the view.
    public var shadow: ShadowConfiguration = .none()
    
    /// The inner shadow of the view.
    public var innerShadow: ShadowConfiguration = .none()
    
    /// The alpha value of the view.
    public var alpha: CGFloat = 1.0
    
    /// The corner radius of the view.
    public var cornerRadius: CGFloat = 0.0
    
    /// The corner curve of the view.
    public var cornerCurve: CALayerCornerCurve = .circular
    
    /// The rounded corners of the view.
    public var roundedCorners: CACornerMask = .all
    
    /// The mask of the view.
    public var mask: NSUIView? = nil
    
    /// A Boolean value indicating whether the mask is inverted.
    public var maskIsInverted: Bool = false

    /// The scale transform of the view.
    public var scale: CGSize = CGSize(width: 1, height: 1)
    
    /// The rotation of the view.
    public var rotation: CGVector3 = .zero
    
    public init() {
        
    }
    
    internal var _backgroundColor: NSUIColor? = nil
    internal mutating func updateResolvedColor() {
        _backgroundColor = resolvedBackgroundColor()
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(backgroundColor)
        hasher.combine(backgroundColorTransformer)
        hasher.combine(_backgroundColor)
        hasher.combine(visualEffect)
        hasher.combine(border)
        hasher.combine(shadow)
        hasher.combine(innerShadow)
        hasher.combine(alpha)
        hasher.combine(cornerRadius)
        hasher.combine(cornerCurve)
        hasher.combine(roundedCorners)
        hasher.combine(mask)
        hasher.combine(maskIsInverted)
        hasher.combine(scale)
        hasher.combine(rotation)
    }
    
    public static func == (lhs: ViewConfiguration, rhs: ViewConfiguration) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
#endif

public extension NSUIView {
    /**
     Configurates the border apperance of the view.

     - Parameters:
        - configuration:The configuration for configurating the apperance.
     */
    func configurate(using configuration: ViewConfiguration) {
        #if os(macOS)
        wantsLayer = true
        self.alphaValue = configuration.alpha
        #elseif canImport(UIKit)
        self.alpha = configuration.alpha
        #endif
        self.backgroundColor = configuration._backgroundColor
        self.cornerRadius = configuration.cornerRadius
        self.cornerCurve = configuration.cornerCurve
        self.roundedCorners = configuration.roundedCorners
        if configuration.maskIsInverted {
            self.inverseMask = configuration.mask
        } else {
            self.mask = configuration.mask
        }
        self.configurate(using: configuration.border)
        self.configurate(using: configuration.shadow, type: .outer)
        self.configurate(using: configuration.innerShadow, type: .inner)
        self.visualEffect = configuration.visualEffect
        self.scale = CGPoint(configuration.scale.width, configuration.scale.height)
        self.rotation = configuration.rotation
        
        #if os(macOS)
        if let backgrpundConfiguration = configuration.backgrpundConfiguration {
            if let backgroundView = backgroundView {
                backgroundView.configuration = backgrpundConfiguration
            } else {
                let backgroundView = BackgroundView(configuration: backgrpundConfiguration)
                self.insertSubview(withConstraint: backgroundView, at: 0)
            }
        } else {
            backgroundView?.removeFromSuperview()
        }
        #endif
    }
    
    #if os(macOS)
    fileprivate var backgroundView: BackgroundView? {
        self.viewWithTag(24532453) as? BackgroundView
    }
    
    fileprivate class BackgroundView: NSUIView {
        #if os(macOS)
        override var tag: Int {
            return 24532453
        }
        #endif
        
        var configuration: NSContentConfiguration {
            didSet {
                updateConfiguration()
            }
        }
        
        var contentView: (NSUIView & NSContentView)
        
        init(configuration: NSContentConfiguration) {
            self.configuration = configuration
            self.contentView = configuration.makeContentView()
            super.init(frame: .zero)
            self.addSubview(withConstraint: contentView)
            #if os(iOS) || os(tvOS)
            self.tag = 24532453
            #endif
        }
        
        func updateConfiguration() {
            if self.contentView.supports(configuration) {
                self.contentView.configuration = configuration
            } else {
                self.contentView.removeFromSuperview()
                self.contentView = configuration.makeContentView()
                self.addSubview(withConstraint: contentView)
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    #endif
}

#endif
