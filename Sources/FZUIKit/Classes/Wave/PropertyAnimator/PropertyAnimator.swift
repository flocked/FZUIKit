//
//  Animator.swift
//
//
//  Created by Florian Zand on 07.10.23.
//

#if os(macOS) || os(iOS) || os(tvOS)

import Foundation
import QuartzCore
import FZSwiftUtils
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
/**
 Provides animatable properties of an object conforming to `AnimatablePropertyProvider`.
 
 For easier access of a animatable property, you can extend the object's PropertyAnimator.
 
 ```swift
 extension: MyObject: AnimatablePropertyProvider { }
 
 public extension PropertyAnimator<MyObject> {
 var myAnimatableProperty: CGFloat {
 get { self[\.myAnimatableProperty] }
 set { self[\.myAnimatableProperty] = newValue }
 }
 }
 
 let object = MyObject()
 Wave.animate(withSpring: .smooth) {
 object.animator.myAnimatableProperty = newValue
 }
 ```
 
 To integralize a value  to the screen's pixel boundaries when animating, use `integralizeValue`.  This helps prevent drawing frames between pixels, causing aliasing issues. Note: Enabling it effectively quantizes values, so don't use this for values that are supposed to be continuous.
 
 ```swift
 self[\.myAnimatableProperty, integralizeValue: true] = newValue
 ```
 */
public class PropertyAnimator<Object: AnimatablePropertyProvider> {
    internal var object: Object
    
    internal init(_ object: Object) {
        self.object = object
    }
    /// A dictionary containing the current animated property keys and associated animations.
    public var animations: [String: AnimationProviding] = [:]
    
    /**
     The current value of the property at the specified keypath. Assigning a new value inside a ``Wave`` animation block animates to the new value.
     
     - Parameters:
        - keyPath: The keypath to the animatable property.
        - integralizeValue: A Boolean value that indicates whether new values should be integralized to the screen's pixel boundaries while animating. This helps prevent drawing frames between pixels, causing aliasing issues. The default value is `false`.
     */
    public subscript<Value: AnimatableProperty>(keyPath: WritableKeyPath<Object, Value>, integralizeValue integralizeValue: Bool = false) -> Value {
        get { value(for: keyPath) }
        set { setValue(newValue, for: keyPath, integralizeValue: integralizeValue) }
    }
        
    /**
     The current value of the property at the specified keypath. Assigning a new value inside a ``Wave`` animation block animates to the new value.
     
     - Parameters:
        - keyPath: The keypath to the animatable property.
        - integralizeValue: A Boolean value that indicates whether new values should be integralized to the screen's pixel boundaries while animating. This helps prevent drawing frames between pixels, causing aliasing issues. The default value is `false`.
     */
    public subscript<Value: AnimatableProperty>(keyPath: WritableKeyPath<Object, Value?>, integralizeValue integralizeValue: Bool = false) -> Value? {
        get { value(for: keyPath) }
        set { setValue(newValue, for: keyPath, integralizeValue: integralizeValue) }
    }
    
    /**
     The current animation for the property at the specified keypath.
     
     - Parameters keyPath: The keypath to an animatable property.
     */
    public func animation(for keyPath: PartialKeyPath<PropertyAnimator>) -> AnimationProviding? {
        var key = keyPath.stringValue
        if let animation = self.animations[key] {
            return animation
        } else if key.contains("layer."), let viewAnimator = self as? PropertyAnimator<NSUIView> {
            key = key.replacingOccurrences(of: "layer.", with: "")
            return viewAnimator.object.optionalLayer?.animator.animations[key]
        }
        return nil
    }
    
    /// The current animation velocity for the property at the specified keypath, or `nil` if there isn't an animation for the keypath or the animation doesn't support velocity values..
    public func animationVelocity<Value: AnimatableProperty>(for keyPath: WritableKeyPath<PropertyAnimator, Value>) -> Value? {
        return (self.animation(for: keyPath) as? (any AnimationVelocityProviding))?.velocity as? Value
    }
    
    /// The current animation velocity for the property at the specified keypath, or `nil` if there isn't an animation for the keypath or the animation doesn't support velocity values..
    public func animationVelocity<Value: AnimatableProperty>(for keyPath: KeyPath<PropertyAnimator, Value?>) -> Value? {
        return (self.animation(for: keyPath) as? (any AnimationVelocityProviding))?.velocity as? Value
    }
}

internal extension PropertyAnimator {
    /// The current value of the property at the keypath. If the property is currently animated, it returns the animation target value.
    func value<Value: AnimatableProperty>(for keyPath: WritableKeyPath<Object, Value>, key: String? = nil) -> Value {
        return (self.animation(for: keyPath, key: key)?.target as? Value) ?? object[keyPath: keyPath]
    }
    
    /// The current value of the property at the keypath. If the property is currently animated, it returns the animation target value.
    func value<Value: AnimatableProperty>(for keyPath: WritableKeyPath<Object, Value?>, key: String? = nil) -> Value?  {
        return (self.animation(for: keyPath, key: key)?.target as? Value) ?? object[keyPath: keyPath]
    }
    
    /// Animates the value of the property at the keypath to a new value.
    func setValue<Value: AnimatableProperty>(_ newValue: Value, for keyPath: WritableKeyPath<Object, Value>, key: String? = nil, integralizeValue: Bool = false, completion: (()->())? = nil)  {
        guard let settings = AnimationController.shared.currentAnimationParameters else {
            Wave.nonAnimate {
                self.setValue(newValue, for: keyPath, key: key)
            }
            return
        }
        
        guard value(for: keyPath, key: key) != newValue || (settings.animationType.isNonAnimated) else {
            return
        }
        
        var initialValue = object[keyPath: keyPath]
        var targetValue = newValue
        updateValue(&initialValue, target: &targetValue)
        
        AnimationController.shared.executeHandler(uuid: animation(for: keyPath, key: key)?.groupUUID, finished: false, retargeted: true)
        
        switch settings.animationType {
        case .spring(_,_):
            let animation = springAnimation(for: keyPath, key: key) ??  SpringAnimation<Value>(settings: settings, value: initialValue, target: targetValue)
            configurateAnimation(animation, target: targetValue, keyPath: keyPath, key: key, settings: settings, integralizeValue: integralizeValue, completion: completion)
        case .easing(_,_):
            let animation = easingAnimation(for: keyPath, key: key) ?? EasingAnimation<Value>(settings: settings, value: initialValue, target: targetValue)
            configurateAnimation(animation, target: targetValue, keyPath: keyPath, key: key, settings: settings, integralizeValue: integralizeValue, completion: completion)
        case .decay(_,_):
            let animation = decayAnimation(for: keyPath, key: key) ?? DecayAnimation<Value>(settings: settings, value: initialValue)
            configurateAnimation(animation, target: targetValue, keyPath: keyPath, key: key, settings: settings, integralizeValue: integralizeValue, completion: completion)
        case .nonAnimated:
            self.animation(for: keyPath, key: key)?.stop(at: .current)
            self.animations[key ?? keyPath.stringValue] = nil
            self.object[keyPath: keyPath] = targetValue
        }
    }
    
    /// Animates the value of the property at the keypath to a new value.
    func setValue<Value: AnimatableProperty>(_ newValue: Value?, for keyPath: WritableKeyPath<Object, Value?>, key: String? = nil, integralizeValue: Bool = false, completion: (()->())? = nil)  {
        guard let settings = AnimationController.shared.currentAnimationParameters else {
            Wave.nonAnimate {
                self.setValue(newValue, for: keyPath, key: key)
            }
            return
        }
        
        guard value(for: keyPath, key: key) != newValue || (settings.animationType.isNonAnimated) else {
            return
        }
        
        var initialValue = object[keyPath: keyPath] ?? Value.zero
        var targetValue = newValue ?? Value.zero
        updateValue(&initialValue, target: &targetValue)
        
        AnimationController.shared.executeHandler(uuid: animation(for: keyPath, key: key)?.groupUUID, finished: false, retargeted: true)
        
        switch settings.animationType {
        case .spring(_,_):
            let animation = springAnimation(for: keyPath, key: key) ?? SpringAnimation<Value>(settings: settings, value: initialValue, target: targetValue)
            configurateAnimation(animation, target: targetValue, keyPath: keyPath, key: key, settings: settings, integralizeValue: integralizeValue, completion: completion)
        case .easing(_,_):
            let animation = easingAnimation(for: keyPath, key: key) ?? EasingAnimation<Value>(settings: settings, value: initialValue, target: targetValue)
            configurateAnimation(animation, target: targetValue, keyPath: keyPath, key: key, settings: settings, integralizeValue: integralizeValue, completion: completion)
        case .decay(_,_):
            let animation = decayAnimation(for: keyPath, key: key) ?? DecayAnimation<Value>(settings: settings, value: initialValue, target: targetValue)
            configurateAnimation(animation, target: targetValue, keyPath: keyPath, key: key, settings: settings, integralizeValue: integralizeValue, completion: completion)
        case .nonAnimated:
            self.animation(for: keyPath, key: key)?.stop(at: .current)
            self.animations[key ?? keyPath.stringValue] = nil
            self.object[keyPath: keyPath] = targetValue
        }
    }
    
    /// Configurates an animation and starts it.
    func configurateAnimation<Value>(_ animation: some ConfigurableAnimationProviding<Value>, target: Value, keyPath: PartialKeyPath<Object>, key: String? = nil, settings: AnimationController.AnimationParameters, integralizeValue: Bool = false, completion: (()->())? = nil) {
        var animation = animation
        animation.target = target
        animation.fromValue = animation.value
        if let easingAnimation = animation as? EasingAnimation<Value> {
            easingAnimation.fractionComplete = 0.0
        }
        animation.integralizeValues = integralizeValue
        animation.configure(withSettings: settings)
        if let keyPath = keyPath as? WritableKeyPath<Object, Value> {
            animation.valueChanged = { [weak self] value in
                self?.object[keyPath: keyPath] = value
            }
        } else if let keyPath = keyPath as? WritableKeyPath<Object, Value?> {
            animation.valueChanged = { [weak self] value in
                self?.object[keyPath: keyPath] = value
            }
        }
        let groupUUID = animation.groupUUID
        let animationKey = key ?? keyPath.stringValue
        
        #if os(iOS) || os(tvOS)
        if settings.preventUserInteraction {
            (self as? PropertyAnimator<UIView>)?.preventingUserInteractionAnimations.insert(animation.id)
        } else {
            (self as? PropertyAnimator<UIView>)?.preventingUserInteractionAnimations.remove(animation.id)
        }
        #endif
        animation.animatorCompletion = { [weak self] in
            guard let self = self else { return }
            self.animations[animationKey] = nil
            #if os(iOS) || os(tvOS)
            (self as? PropertyAnimator<UIView>)?.preventingUserInteractionAnimations.remove(animation.id)
            #endif
        }
        
        animation.completion = { [weak self] event in
            switch event {
            case .finished:
                completion?()
                self?.animations[animationKey] = nil
                AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
            default:
                break
            }
        }
        animations[animationKey] = animation
        animation.start(afterDelay: settings.delay)
    }
    
    /// Updates the value and target of an animatable property for better animations.
    func updateValue<V: AnimatableProperty>(_ value: inout V, target: inout V) {
        if V.self == CGColor.self {
            let color = (value as! CGColor).nsUIColor
            let targetColor = (target as! CGColor).nsUIColor
            if color?.isVisible == false {
                value = (targetColor?.withAlphaComponent(0.0).cgColor ?? .clear) as! V
            }
            if targetColor?.isVisible == false {
                target = (color?.withAlphaComponent(0.0).cgColor ?? .clear) as! V
            }
        } else if var collection = value as? (any AnimatableCollection), var targetCollection = target as? (any AnimatableCollection), collection.count != targetCollection.count {
            collection.makeInterpolatable(to: &targetCollection)
            value = collection as! V
            target = targetCollection as! V
        }
    }
}

internal extension PropertyAnimator {
    /// The current spring animation for the property at the keypath or key, or `nil` if there isn't a spring animation for the keypath.
    func springAnimation<Val>(for keyPath: WritableKeyPath<Object, Val?>, key: String? = nil) -> SpringAnimation<Val>? {
        return animations[key ?? keyPath.stringValue] as? SpringAnimation<Val>
    }
    
    /// The current spring animation for the property at the keypath or key, or `nil` if there isn't a spring animation for the keypath.
    func springAnimation<Val>(for keyPath: WritableKeyPath<Object, Val>, key: String? = nil) -> SpringAnimation<Val>? {
        return animations[key ?? keyPath.stringValue] as? SpringAnimation<Val>
    }
    
    /// The current easing animation for the property at the keypath or key, or `nil` if there isn't an easing animation for the keypath.
    func easingAnimation<Val>(for keyPath: WritableKeyPath<Object, Val?>, key: String? = nil) -> EasingAnimation<Val>? {
        return animations[key ?? keyPath.stringValue] as? EasingAnimation<Val>
    }
    
    /// The current easing animation for the property at the keypath or key, or `nil` if there isn't an easing animation for the keypath.
    func easingAnimation<Val>(for keyPath: WritableKeyPath<Object, Val>, key: String? = nil) -> EasingAnimation<Val>? {
        return animations[key ?? keyPath.stringValue] as? EasingAnimation<Val>
    }
    
    /// The current decay animation for the property at the keypath or key, or `nil` if there isn't a decay animation for the keypath.
    func decayAnimation<Val>(for keyPath: WritableKeyPath<Object, Val?>, key: String? = nil) -> DecayAnimation<Val>? {
        return animations[key ?? keyPath.stringValue] as? DecayAnimation<Val>
    }
    
    /// The current decay animation for the property at the keypath or key, or `nil` if there isn't a decay animation for the keypath.
    func decayAnimation<Val>(for keyPath: WritableKeyPath<Object, Val>, key: String? = nil) -> DecayAnimation<Val>? {
        return animations[key ?? keyPath.stringValue] as? DecayAnimation<Val>
    }
    
    /// The current animation for the property at the keypath or key, or `nil` if there isn't an animation for the keypath.
    func animation<Val>(for keyPath: WritableKeyPath<Object, Val>, key: String? = nil) -> (any ConfigurableAnimationProviding)? {
        return animations[key ?? keyPath.stringValue] as? (any ConfigurableAnimationProviding)
    }
}

#endif


/*
 #if os(iOS) || os(tvOS)
 func configurateViewUserInteration(settings: AnimationController.AnimationParameters) {
 if settings.isUserInteractionEnabled == false, let view = object as? NSUIView {
 view.savedIsUserInteractionEnabled = view.isUserInteractionEnabled
 view.isUserInteractionEnabled = false
 }
 }
 #endif
 */

/*
 #if os(iOS) || os(tvOS)
 internal extension UIView {
 var savedIsUserInteractionEnabled: Bool {
 get { getAssociatedValue(key: "savedIsUserInteractionEnabled", object: self, initialValue: isUserInteractionEnabled) }
 set { set(associatedValue: newValue, key: "savedIsUserInteractionEnabled", object: self) }
 }
 }
 #endif
 
 
 subscript<Value: AnimatableProperty>(keyPath: WritableKeyPath<Object, Value?>, integralizeValue integralizeValue: Bool = false, epsilon epsilon: Double? = nil) -> Value? where Value: ApproximateEquatable {
     get { value(for: keyPath) }
     set { setValue(newValue, for: keyPath, epsilon: epsilon, integralizeValue: integralizeValue) }
 }
 */
