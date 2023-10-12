//
//  Animator+Layer.swift
//  
//
//  Created by Florian Zand on 12.10.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

extension CALayer: Animatable { }

extension Animator where Object: CALayer {
    /// The bounds of the layer.
    public var bounds: CGRect {
        get { value(for: \.bounds) }
        set { setValue(newValue, for: \.bounds) }
    }
    
    /// The frame of the layer.
    public var frame: CGRect {
        get { value(for: \.frame) }
        set { setValue(newValue, for: \.frame) }
    }
    
    /// The background color of the layer.
    public var backgroundColor: NSUIColor? {
        get { value(for: \.backgroundColor)?.nsUIColor }
        set { setValue(newValue?.cgColor, for: \.backgroundColor) }
    }
    
    /// The size of the layer. Changing this value keeps the layer centered.
    public var size: CGSize {
        get { frame.size }
        set {
            guard size != newValue else { return }
            frame.sizeCentered = newValue
        }
    }
    
    /// The origin of the layer.
    public var origin: CGPoint {
        get { frame.origin }
        set { frame.origin = newValue }
    }
    
    /// The center of the layer.
    public var center: CGPoint {
        get { frame.center }
        set { frame.center = newValue }
    }
        
    /// The opacity value of the layer.
    public var opacity: CGFloat {
        get { CGFloat(value(for: \.opacity)) }
        set { setValue(Float(newValue), for: \.opacity) }
    }
    
    /// The three-dimensional transform of the layer.
    public var transform: CATransform3D {
        get { value(for: \.transform) }
        set { setValue(newValue, for: \.transform) }
    }
    
    /// The scale of the layer.
    public var scale: CGPoint {
        get { CGPoint(self.transform.scale.x, self.transform.scale.y) }
        set { self.transform.scale = Scale(newValue.x, newValue.y, transform.scale.z) }
    }
    
    /// The rotation of the layer.
    public var rotation: CGQuaternion {
        get { self.transform.rotation }
        set { self.transform.rotation = newValue }
    }
    
    /// The translation transform of the layer.
    public var translation: CGPoint {
        get { CGPoint(self.transform.translation.x, self.transform.translation.y) }
        set { self.transform.translation = Translation(newValue.x, newValue.y, self.transform.translation.z) }
    }
    
    /// The corner radius of the layer.
    public var cornerRadius: CGFloat {
        get { value(for: \.cornerRadius) }
        set { setValue(newValue, for: \.cornerRadius) }
    }
    
    /// The border color of the layer.
    public var borderColor: NSUIColor? {
        get { value(for: \.borderColor)?.nsUIColor }
        set { setValue(newValue?.cgColor, for: \.borderColor) }
    }
    
    /// The border width of the layer.
    public var borderWidth: CGFloat {
        get { value(for: \.borderWidth) }
        set { setValue(newValue, for: \.borderWidth) }
    }
    
    /// The shadow of the layer.
    public var shadow: ContentConfiguration.Shadow {
        get { ContentConfiguration.Shadow(color: shadowColor != .clear ? shadowColor : nil, opacity: shadowOpacity, radius: shadowRadius, offset: CGPoint(shadowOffset.width, shadowOffset.height) ) }
        set {
            guard newValue != shadow else { return }
            self.shadowColor = newValue.color
            self.shadowOffset = CGSize(newValue.offset.x, newValue.offset.y)
            self.shadowRadius = newValue.radius
            self.shadowOpacity = newValue.opacity
        }
    }
    
    internal var shadowOpacity: CGFloat {
        get { CGFloat(value(for: \.shadowOpacity)) }
        set { setValue(Float(newValue), for: \.shadowOpacity) }
    }
    
    internal var shadowColor: NSUIColor? {
        get { value(for: \.shadowColor)?.nsUIColor }
        set { setValue(newValue?.cgColor, for: \.shadowColor) }
    }
    
    internal var shadowOffset: CGSize {
        get { value(for: \.shadowOffset) }
        set { setValue(newValue, for: \.shadowOffset) }
    }
    
    internal var shadowRadius: CGFloat {
        get { value(for: \.shadowRadius) }
        set { setValue(newValue, for: \.shadowRadius) }
    }
    
    /// The inner shadow of the layer.
    public var innerShadow: ContentConfiguration.InnerShadow {
        get { ContentConfiguration.InnerShadow(color: innerShadowColor, opacity: innerShadowOpacity, radius: innerShadowRadius, offset: innerShadowOffset ) }
        set {
            innerShadowColor = newValue.color
            innerShadowRadius = newValue.radius
            innerShadowOffset = newValue.offset
            innerShadowOpacity = newValue.opacity
        }
    }
    
    internal var innerShadowOpacity: CGFloat {
        get { value(for: \.innerShadowOpacity) }
        set { setValue(newValue, for: \.innerShadowOpacity) }
    }
    
    internal var innerShadowRadius: CGFloat {
        get { value(for: \.innerShadowRadius) }
        set { setValue(newValue, for: \.innerShadowRadius) }
    }
    
    internal var innerShadowOffset: CGPoint {
        get { value(for: \.innerShadowOffset) }
        set { setValue(newValue, for: \.innerShadowOffset) }
    }
    
    internal var innerShadowColor: NSUIColor? {
        get { value(for: \.innerShadowColor) }
        set { setValue(newValue, for: \.innerShadowColor) }
    }
}

extension Animator where Object: CATextLayer {
    /// The font size of the layer.
    public var fontSize: CGFloat {
        get { value(for: \.fontSize) }
        set { setValue(newValue, for: \.fontSize) } }
    
    /// The text color of the layer.
    public var textColor: NSUIColor? {
        get { value(for: \.textColor) }
        set { setValue(newValue, for: \.textColor) } }
}

fileprivate extension CATextLayer {
    @objc var textColor: NSUIColor? {
        get { self.foregroundColor?.nsUIColor }
        set { self.foregroundColor = newValue?.cgColor }
    }
}

fileprivate extension CALayer {
    var innerShadow: ContentConfiguration.InnerShadow {
        get { self.innerShadowLayer?.configuration ?? .none() }
        set { self.configurate(using: newValue) }
    }
    
   @objc var innerShadowOpacity: CGFloat {
        get { innerShadow.opacity }
        set { innerShadow.opacity = newValue }
    }
    
    @objc var innerShadowRadius: CGFloat {
         get { innerShadow.radius }
         set { innerShadow.radius = newValue }
     }
    
    @objc var innerShadowColor: NSUIColor? {
         get { innerShadow.color }
         set { innerShadow.color = newValue }
     }
    
    @objc var innerShadowOffset: CGPoint {
         get { innerShadow.offset }
         set { innerShadow.offset = newValue }
     }
}


#endif
