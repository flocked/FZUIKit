//
//  ViewAnimator.swift
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
        set {
            guard size != newValue else { return }
            frame.sizeCentered = newValue
        }
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
        get { value(for: \.backgroundColor) }
        set { setValue(newValue, for: \._backgroundColor) }
    }
        
    /// The alpha value of the view.
    public var alpha: CGFloat {
        get { value(for: \.alpha) }
        set { setValue(newValue, for: \.alpha) }
    }
    
    /// The scale transform of the view.
    public var scale: CGPoint {
        get { value(for: \.scale) }
        set { setValue(newValue, for: \.scale) }
    }
    
    /// The translation transform of the view.
    public var translation: CGPoint {
        get { value(for: \.translation) }
        set { setValue(newValue, for: \.translation) }
    }
    
    /// The corner radius of the view.
    public var cornerRadius: CGFloat {
        get { value(for: \.cornerRadius) }
        set { setValue(newValue, for: \.cornerRadius) }
    }
    
    /// The border color of the view.
    public var borderColor: NSUIColor? {
        get { value(for: \.borderColor) }
        set { setValue(newValue, for: \.borderColor) }
    }
    
    /// The border width of the view.
    public var borderWidth: CGFloat {
        get { value(for: \.borderWidth) }
        set { setValue(newValue, for: \.borderWidth) }
    }
    
    /// The shadow of the view.
    public var shadow: ContentConfiguration.Shadow {
        get {
            ContentConfiguration.Shadow(color: shadowColor != .clear ? shadowColor : nil, opacity: shadowOpacity, radius: shadowRadius, offset: CGPoint(shadowOffset.width, shadowOffset.height) )
        }
        set {
            guard newValue != shadow else { return }
            self.shadowColor = newValue.color
            self.shadowOffset = CGSize(newValue.offset.x, newValue.offset.y)
            self.shadowRadius = newValue.radius
            self.shadowOpacity = newValue.opacity
        }
    }
    
    internal var shadowOpacity: CGFloat {
        get { value(for: \.shadowOpacity) }
        set { setValue(newValue, for: \.shadowOpacity) }
    }
    
    internal var shadowColor: NSUIColor? {
        get { value(for: \.shadowColor) }
        set { setValue(newValue, for: \.shadowColor) }
    }
    
    internal var shadowOffset: CGSize {
        get { value(for: \.shadowOffset) }
        set { setValue(newValue, for: \.shadowOffset) }
    }
    
    internal var shadowRadius: CGFloat {
        get { value(for: \.shadowRadius) }
        set { setValue(newValue, for: \.shadowRadius) }
    }
}

fileprivate extension NSUIView {
    var optionalLayer: CALayer? {
        return self.layer
    }
    
    @objc dynamic var translation: CGPoint {
        get { self.optionalLayer?.translation ?? .zero }
        set {
            #if macOS
            self.wantsLayer = true
            #endif
            self.optionalLayer?.translation = newValue
        }
    }
}

#endif


/*
 public var transform: CGAffineTransform {
     get {
         runningTransformAnimator?.target ?? view.transform
     }
     set {
         guard transform != newValue else {
             return
         }
         
         guard let settings = AnimationController.shared.currentAnimationParameters else {
             Wave.animate(withSpring: .nonAnimated, mode: .nonAnimated) {
                 self.view.animator.transform = newValue
             }
             return
         }
         
         let initialValue = view.transform
         let targetValue = newValue
         
         let animationType = AnimatableProperty.transform
         
         // Re-targeting an animation.
         AnimationController.shared.executeHandler(uuid: runningTransformAnimator?.groupUUID, finished: false, retargeted: true)
         
         let animation = (runningTransformAnimator ?? SpringAnimator<CGAffineTransform>(spring: settings.spring, value: initialValue, target: targetValue))
         animation.configure(withSettings: settings)
         
         animation.target = targetValue
         animation.valueChanged = { [weak self] value in
             self?.view.transform = value
         }
         
         let groupUUID = animation.groupUUID
         animation.completion = { [weak self] event in
             switch event {
             case .finished:
                 self?.view.waveAnimations.removeValue(forKey: animationType)
                 AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
             default:
                 break
             }
         }
         
         start(animation: animation, type: animationType, delay: settings.delay)
     }
 }
 
 public var transform3D: CATransform3D {
     get {
         runningTransform3DAnimator?.target ?? view.transform3D
     }
     set {
         guard transform3D != newValue else {
             return
         }
         
         guard let settings = AnimationController.shared.currentAnimationParameters else {
             Wave.animate(withSpring: .nonAnimated, mode: .nonAnimated) {
                 self.view.animator.transform3D = newValue
             }
             return
         }
         
         let initialValue = view.transform3D
         let targetValue = newValue
         
         let animationType = AnimatableProperty.transform3D
         
         // Re-targeting an animation.
         AnimationController.shared.executeHandler(uuid: runningTransform3DAnimator?.groupUUID, finished: false, retargeted: true)
         
         let animation = (runningTransform3DAnimator ?? SpringAnimator<CATransform3D>(spring: settings.spring, value: initialValue, target: targetValue))
         animation.configure(withSettings: settings)
         
         animation.target = targetValue
         animation.valueChanged = { [weak self] value in
             self?.view.transform3D = value
         }
         
         let groupUUID = animation.groupUUID
         animation.completion = { [weak self] event in
             switch event {
             case .finished:
                 self?.view.waveAnimations.removeValue(forKey: animationType)
                 AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
             default:
                 break
             }
         }
         
         start(animation: animation, type: animationType, delay: settings.delay)
     }
 }
 
 public func addSubview(_ subview: NSView) {
     guard subview.superview != view else { return }
     subview.alpha = 0.0
     self.view.addSubview(subview)
     subview.animator.alpha = 1.0
 }
     
 public func removeFromSuperView() {
     guard view.superview != nil else { return }
     
     guard let settings = AnimationController.shared.currentAnimationParameters else {
         Wave.animate(withSpring: .nonAnimated, mode: .nonAnimated) {
             self.view.animator.alpha = 0.0
         }
         return
     }
     
     let initialValue = view.alpha
     let targetValue = 0.0
     
     let animationType = AnimatableProperty.alpha
     
     // Re-targeting an animation.
     AnimationController.shared.executeHandler(uuid: runningAlphaAnimator?.groupUUID, finished: false, retargeted: true)
     
     let animation = (runningAlphaAnimator ?? SpringAnimator<CGFloat>(spring: settings.spring, value: initialValue, target: targetValue))
     animation.configure(withSettings: settings)
     
     animation.target = targetValue
     animation.valueChanged = { [weak self] value in
         self?.view.alpha = value
     }
     
     animation.completion = { [weak self] event in
         switch event {
         case .finished:
             self?.view.waveAnimations.removeValue(forKey: animationType)
             AnimationController.shared.executeHandler(uuid: animation.groupUUID, finished: true, retargeted: false)
             self?.view.removeFromSuperview()
         default:
             break
         }
     }
     
     start(animation: animation, type: animationType, delay: settings.delay)
 }
 
 private var runningTransformAnimator: SpringAnimator<CGAffineTransform>? {
     view.waveAnimations[AnimatableProperty.transform] as? SpringAnimator<CGAffineTransform>
 }
 
 private var runningTransform3DAnimator: SpringAnimator<CATransform3D>? {
     view.waveAnimations[AnimatableProperty.transform3D] as? SpringAnimator<CATransform3D>
 }
 */
