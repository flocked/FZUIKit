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
        get { value(for: \._backgroundColor) }
        set { setValue(newValue, for: \._backgroundColor) }
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
        get { value(for: \._opacity) }
        set { setValue(newValue, for: \._opacity) }
    }
    
    /// The scale of the layer.
    public var scale: CGPoint {
        get { CGPoint(self.transform3D.scale.x, self.transform3D.scale.y) }
        set { self.transform3D.scale = Scale(newValue.x, newValue.y, transform3D.scale.z) }
    }
    
    /// The rotation of the layer.
    public var rotation: CGQuaternion {
        get { self.transform3D.rotation }
        set { self.transform3D.rotation = newValue }
    }
    
    /// The translation transform of the layer.
    public var translation: CGPoint {
        get { CGPoint(self.transform3D.translation.x, self.transform3D.translation.y) }
        set { self.transform3D.translation = Translation(newValue.x, newValue.y, self.transform3D.translation.z) }
    }
    
    /// The corner radius of the layer.
    public var cornerRadius: CGFloat {
        get { value(for: \.cornerRadius) }
        set { setValue(newValue, for: \.cornerRadius) }
    }
    
    /// The border color of the layer.
    public var borderColor: NSUIColor? {
        get { value(for: \._borderColor) }
        set { setValue(newValue, for: \._borderColor) }
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
        get { value(for: \._shadowColor) }
        set { setValue(newValue, for: \._shadowColor) }
    }
    
    internal var shadowOffset: CGSize {
        get { value(for: \.shadowOffset) }
        set { setValue(newValue, for: \.shadowOffset) }
    }
    
    internal var shadowRadius: CGFloat {
        get { value(for: \.shadowRadius) }
        set { setValue(newValue, for: \.shadowRadius) }
    }
    
    internal var transform3D: CATransform3D {
        get { value(for: \.transform) }
        set { setValue(newValue, for: \.transform) }
    }
}

internal extension CALayer {
    var _backgroundColor: NSUIColor? {
        get {
            #if os(macOS)
            self.backgroundColor?.nsColor
            #elseif canImport(UIKit)
            self.backgroundColor?.uiColor
            #endif
        }
        set { self.backgroundColor = newValue?.cgColor }
    }
    
    var _shadowColor: NSUIColor? {
        get {
            #if os(macOS)
            self.shadowColor?.nsColor
            #elseif canImport(UIKit)
            self.shadowColor?.uiColor
            #endif
        }
        set { self.shadowColor = newValue?.cgColor }
    }
    
    var _borderColor: NSUIColor? {
        get {
            #if os(macOS)
            self.borderColor?.nsColor
            #elseif canImport(UIKit)
            self.borderColor?.uiColor
            #endif
        }
        set { self.borderColor = newValue?.cgColor }
    }
    
    var _opacity: CGFloat {
        get { CGFloat(opacity) }
        set { opacity = Float(newValue) }
    }
    
    var _shadowOpacity: CGFloat {
        get { CGFloat(shadowOpacity) }
        set { shadowOpacity = Float(newValue) }
    }
}



#endif
