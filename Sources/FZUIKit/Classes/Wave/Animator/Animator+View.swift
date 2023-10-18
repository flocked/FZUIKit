//
//  Animator+View.swift
//
//  Modified by Florian Zand
//  Original: Copyright (c) 2022 Janum Trivedi.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

extension NSUIView: Animatable { }

extension Animator where Object: NSUIView {
    /// The bounds of the view.
    public var bounds: CGRect {
        get { value(for: \.bounds) }
        set { setValue(newValue, for: \.bounds) }
    }
    
    /// The frame of the view.
    public var frame: CGRect {
        get { value(for: \.frame) }
        set { setValue(newValue, for: \.frame) }
    }
    
    /// The size of the view. Changing this value keeps the view centered.
    public var size: CGSize {
        get { frame.size }
        set { frame.sizeCentered = newValue }
    }
    
    /// The origin of the view.
    public var origin: CGPoint {
        get { frame.origin }
        set { frame.origin = newValue }
    }
    
    /// The center of the view.
    public var center: CGPoint {
        get { frame.center }
        set { frame.center = newValue }
    }
    
    /// The background color of the view.
    public var backgroundColor: NSUIColor? {
        get { object.optionalLayer?.animator.backgroundColor }
        set { object.optionalLayer?.animator.backgroundColor = newValue?.resolvedColor(for: object)
            #if os(macOS)
            object.__backgroundColor = newValue
            #endif
        }
    }
    
    /// The alpha value of the view.
    public var alpha: CGFloat {
        get { object.optionalLayer?.animator.opacity ?? 1.0 }
        set { object.optionalLayer?.animator.opacity = newValue }
    }
    
    /// The corner radius of the view.
    public var cornerRadius: CGFloat {
        get { object.optionalLayer?.animator.cornerRadius ?? 0.0 }
        set { object.optionalLayer?.animator.cornerRadius = newValue }
    }
    
    /// The border color of the view.
    public var borderColor: NSUIColor? {
        get { object.optionalLayer?.animator.borderColor ?? .zero }
        set { object.optionalLayer?.animator.borderColor = newValue?.resolvedColor(for: object)
            #if os(macOS)
            object._borderColor = newValue
            #endif
        }
    }
    
    /// The border width of the view.
    public var borderWidth: CGFloat {
        get { object.optionalLayer?.animator.borderWidth ?? 0.0 }
        set { object.optionalLayer?.animator.borderWidth = newValue }
    }
    
    /// The shadow of the view.
    public var shadow: ContentConfiguration.Shadow {
        get { object.optionalLayer?.animator.shadow ?? .none() }
        set { 
            var newValue = newValue
            #if os(macOS)
            object._shadowColor = newValue.resolvedColor()
            #endif
            newValue.color = newValue.color?.resolvedColor(for: object)
            object.optionalLayer?.animator.shadow = newValue }
    }
    
    /// The inner shadow of the view.
    public var innerShadow: ContentConfiguration.InnerShadow {
        get { object.optionalLayer?.animator.innerShadow ?? .none() }
        set {
            var newValue = newValue
            newValue.color = newValue.color?.resolvedColor(for: object)
            object.optionalLayer?.animator.innerShadow = newValue
        }
    }
    
    /// The three-dimensional transform of the view.
    public var transform3D: CATransform3D {
        get { object.optionalLayer?.transform ?? CATransform3DIdentity }
        set { object.optionalLayer?.transform = newValue }
    }
    
    /// The scale transform of the view.
    public var scale: CGPoint {
        get { object.optionalLayer?.animator.scale ?? CGPoint(1, 1) }
        set { object.optionalLayer?.animator.scale = newValue  }
    }
    
    /// The rotation transform of the view.
    public var rotation: CGQuaternion {
        get { object.optionalLayer?.animator.rotation ?? .zero }
        set { object.optionalLayer?.animator.rotation = newValue }
    }
    
    /// The translation transform of the view.
    public var translation: CGPoint {
        get { object.optionalLayer?.animator.translation ?? .zero }
        set { object.optionalLayer?.animator.translation = newValue }
    }
}

fileprivate extension NSUIView {
    var optionalLayer: CALayer? {
#if os(macOS)
        self.wantsLayer = true
#endif
        return self.layer
    }
}

extension Animator where Object: NSUITextField {
    /// The text color of the text field.
    public var textColor: NSUIColor? {
        get { value(for: \.textColor) }
        set { setValue(newValue, for: \.textColor) }
    }
    
    /// The font size of the text field.
    public var fontSize: CGFloat {
        get { value(for: \.fontSize) }
        set { setValue(newValue, for: \.fontSize) } }
}

fileprivate extension NSUITextField {
    @objc var fontSize: CGFloat {
        get { font?.pointSize ?? 0.0 }
        set {  font = font?.withSize(newValue) } }
}


#if os(macOS)
extension Animator where Object: NSImageView {
    /// The tint color of the image.
    public var contentTintColor: NSUIColor? {
        get { value(for: \.contentTintColor) }
        set { setValue(newValue, for: \.contentTintColor) }
    }
}

extension Animator where Object: NSButton {
    /// The tint color of the button.
    public var contentTintColor: NSUIColor? {
        get { value(for: \.contentTintColor) }
        set { setValue(newValue, for: \.contentTintColor) }
    }
}

extension Animator where Object: ImageView {
    /// The tint color of the image.
    public var tintColor: NSUIColor? {
        get { value(for: \.tintColor) }
        set { setValue(newValue, for: \.tintColor) }
    }
}
#elseif canImport(UIKit)
extension Animator where Object: UIImageView {
    /// The tint color of the image.
    public var tintColor: NSUIColor {
        get { value(for: \.tintColor) }
        set { setValue(newValue, for: \.tintColor) }
    }
}

extension Animator where Object: UIButton {
    /// The tint color of the button.
    public var tintColor: NSUIColor {
        get { value(for: \.tintColor) }
        set { setValue(newValue, for: \.tintColor) }
    }
}

extension Animator where Object: UILabel {
    /// The text color of the label.
    public var textColor: NSUIColor {
        get { value(for: \.textColor) }
        set { setValue(newValue, for: \.textColor) }
    }
    
    /// The font size of the label.
    public var fontSize: CGFloat {
        get { value(for: \.fontSize) }
        set { setValue(newValue, for: \.fontSize) } }
}

extension Animator where Object: UITextView {
    /// The text color of the text view.
    public var textColor: NSUIColor? {
        get { value(for: \.textColor) }
        set { setValue(newValue, for: \.textColor) }
    }
    
    /// The font size of the text view.
    public var fontSize: CGFloat {
        get { value(for: \.fontSize) }
        set { setValue(newValue, for: \.fontSize) } }
}

fileprivate extension UILabel {
    @objc var fontSize: CGFloat {
        get { font.pointSize }
        set { font = font.withSize(newValue) } }
}

fileprivate extension UITextView {
    @objc var fontSize: CGFloat {
        get { font?.pointSize ?? 0.0 }
        set { font = font?.withSize(newValue) } }
}
#endif
#endif
