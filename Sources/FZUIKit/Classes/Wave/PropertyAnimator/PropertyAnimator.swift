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
    
    internal var animations: [String: AnimationProviding] {
        get { getAssociatedValue(key: "animations", object: self, initialValue: [:]) }
        set { set(associatedValue: newValue, key: "animations", object: self) }
    }
}

public extension PropertyAnimator {
    subscript<Value: AnimatableData>(keyPath: WritableKeyPath<Object, Value>, integralizeValue integralizeValue: Bool = false) -> Value {
        get { value(for: keyPath) }
        set { setValue(newValue, for: keyPath, integralizeValue: integralizeValue) }
    }
    
    subscript<Value: AnimatableData>(keyPath: WritableKeyPath<Object, Value>, integralizeValue integralizeValue: Bool = false, epsilon epsilon: Double? = nil) -> Value  where Value: ApproximateEquatable {
        get { value(for: keyPath) }
        set { setValue(newValue, for: keyPath, epsilon: epsilon, integralizeValue: integralizeValue) }
    }
    
    subscript<Value: AnimatableData>(keyPath: WritableKeyPath<Object, Value?>, integralizeValue integralizeValue: Bool = false) -> Value? {
        get { value(for: keyPath) }
        set { setValue(newValue, for: keyPath, integralizeValue: integralizeValue) }
    }
    
    subscript<Value: AnimatableData>(keyPath: WritableKeyPath<Object, Value?>, integralizeValue integralizeValue: Bool = false, epsilon epsilon: Double? = nil) -> Value? where Value: ApproximateEquatable {
        get { value(for: keyPath) }
        set { setValue(newValue, for: keyPath, epsilon: epsilon, integralizeValue: integralizeValue) }
    }
    
    /// The current animation velocity of the specified keypath, or `nil` if there isn't an animation for the keypath.
    func animationVelocity<Value: AnimatableData>(for keyPath: KeyPath<PropertyAnimator, Value>) -> Value? {
        if let animation = self.animations[keyPath.stringValue] as? SpringAnimator<Value> {
            return animation.velocity
        } else if let animation = (object as? NSUIView)?.optionalLayer?.animator.animations[keyPath.stringValue] as? SpringAnimator<Value> {
            return animation.velocity
        }
        return nil
    }
    
    /// The current animation velocity of the specified keypath, or `nil` if there isn't an animation for the keypath.
    func animationVelocity<Value: AnimatableData>(for keyPath: KeyPath<PropertyAnimator, Value?>) -> Value? {
        if let animation = self.animations[keyPath.stringValue] as? SpringAnimator<Value> {
            return animation.velocity
        } else if let animation = (object as? NSUIView)?.optionalLayer?.animator.animations[keyPath.stringValue] as? SpringAnimator<Value> {
            return animation.velocity
        }
        return nil
    }
}

internal extension PropertyAnimator {
    /// The current spring animation for the property at the keypath, or `nil` if there isn't an animation for the keypath.
    func springAnimation<Val>(for keyPath: WritableKeyPath<Object, Val?>, key: String? = nil) -> SpringAnimator<Val>? {
        return animations[key ?? keyPath.stringValue] as? SpringAnimator<Val>
    }
    
    /// The current spring animation for the property at the keypath, or `nil` if there isn't an animation for the keypath.
    func springAnimation<Val>(for keyPath: WritableKeyPath<Object, Val>, key: String? = nil) -> SpringAnimator<Val>? {
        return animations[key ?? keyPath.stringValue] as? SpringAnimator<Val>
    }
        
    /// The current value of the property at the keypath,. If the property is currently animated, it returns the animation target value.
    func value<Value: AnimatableData>(for keyPath: WritableKeyPath<Object, Value>, key: String? = nil) -> Value {
        return springAnimation(for: keyPath, key: key)?.target ?? object[keyPath: keyPath]
    }
    
    /// The current value of the property at the keypath,. If the property is currently animated, it returns the animation target value.
    func value<Value: AnimatableData>(for keyPath: WritableKeyPath<Object, Value?>, key: String? = nil) -> Value?  {
        return springAnimation(for: keyPath, key: key)?.target ?? object[keyPath: keyPath]
    }
    
    func setValue<Value: AnimatableData>(_ newValue: Value, for keyPath: WritableKeyPath<Object, Value>, key: String? = nil, epsilon: Double? = nil, integralizeValue: Bool = false, completion: (()->())? = nil)  {
        guard let settings = AnimationController.shared.currentAnimationParameters else {
            Wave.animate(withSpring: .nonAnimated) {
                self.setValue(newValue, for: keyPath, key: key)
            }
            return
        }
        
        guard value(for: keyPath, key: key) != newValue || (settings.spring == .nonAnimated && springAnimation(for: keyPath, key: key) != nil) else {
            return
        }
        
        var initialValue = object[keyPath: keyPath]
        var targetValue = newValue
        updateValue(&initialValue, target: &targetValue)
        
        if settings.spring == .nonAnimated {
            if let animation = springAnimation(for: keyPath, key: key) {
                animation.stop(at: targetValue)
            } else {
                object[keyPath: keyPath] = targetValue
            }
        } else {
            AnimationController.shared.executeHandler(uuid: springAnimation(for: keyPath, key: key)?.groupUUID, finished: false, retargeted: true)
            
            configurateViewUserInteration(settings: settings)
            
            let animation = springAnimation(for: keyPath, key: key) ?? SpringAnimator<Value>(spring: settings.spring, value: initialValue, target: targetValue)
            
            configurateAnimation(animation, target: targetValue, keyPath: keyPath, key: key, settings: settings, epsilon: epsilon, integralizeValue: integralizeValue, completion: completion)
        }
    }
    
    func setValue<Value: AnimatableData>(_ newValue: Value?, for keyPath: WritableKeyPath<Object, Value?>, key: String? = nil, epsilon: Double? = nil, integralizeValue: Bool = false, completion: (()->())? = nil)  {
        guard let settings = AnimationController.shared.currentAnimationParameters else {
            Wave.animate(withSpring: .nonAnimated) {
                self.setValue(newValue, for: keyPath, key: key)
            }
            return
        }
        
        guard value(for: keyPath, key: key) != newValue || (settings.spring == .nonAnimated && springAnimation(for: keyPath, key: key) != nil) else {
            return
        }
                
        var initialValue = object[keyPath: keyPath] ?? Value.zero
        var targetValue = newValue ?? Value.zero
        updateValue(&initialValue, target: &targetValue)
        
        if settings.spring == .nonAnimated {
            if let animation = springAnimation(for: keyPath, key: key) {
                animation.stop(at: targetValue)
            } else {
                object[keyPath: keyPath] = newValue
            }
        } else {
            AnimationController.shared.executeHandler(uuid: springAnimation(for: keyPath, key: key)?.groupUUID, finished: false, retargeted: true)
            
            configurateViewUserInteration(settings: settings)
            
            let animation = springAnimation(for: keyPath, key: key) ?? SpringAnimator<Value>(spring: settings.spring, value: initialValue, target: targetValue)
            
            configurateAnimation(animation, target: targetValue, keyPath: keyPath, key: key, settings: settings, epsilon: epsilon, integralizeValue: integralizeValue, completion: completion)
        }
    }
    
    func configurateViewUserInteration(settings: AnimationController.AnimationParameters) {
        if settings.isUserInteractionEnabled == false, let view = object as? NSUIView {
            if var array = AnimationController.shared.mouseDownDisabledViews[settings.groupUUID], array.contains(view) == false {
                array.append(view)
                AnimationController.shared.mouseDownDisabledViews[settings.groupUUID] = array
            } else {
                AnimationController.shared.mouseDownDisabledViews[settings.groupUUID] = [view]
            }
        }
    }
        
    func configurateAnimation<Value>(_ animation: SpringAnimator<Value>, target: Value, keyPath: PartialKeyPath<Object>, key: String? = nil, settings: AnimationController.AnimationParameters, epsilon: Double? = nil, integralizeValue: Bool = false, completion: (()->())? = nil) {
        animation.target = target
        animation.epsilon = epsilon
        animation.integralizeValues = integralizeValue
        animation.configure(withSettings: settings)
        if let gestureVelocity = settings.gestureVelocity {
            (animation as? SpringAnimator<CGPoint>)?.velocity = gestureVelocity
            (animation as? SpringAnimator<CGRect>)?.velocity.origin = gestureVelocity
        }
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

    /// Updates values of specific types for better animations.
    func updateValue<V: AnimatableData>(_ value: inout V, target: inout V) {
        if V.self == CGColor.self {
            let val = (value as! CGColor).nsUIColor
            let tar = (target as! CGColor).nsUIColor
            if val?.isVisible == false {
                value = (tar?.withAlphaComponent(0.0).cgColor ?? .clear) as! V
            }
            if tar?.isVisible == false {
                target = (tar?.withAlphaComponent(0.0).cgColor ?? .clear) as! V
            }
        } else if var val = value as? AnimatableArrayType, var tar = target as? AnimatableArrayType, val.count != tar.count {
            let diff = tar.count - val.count
            if diff < 0 {
                tar.appendZeroValues(amount: (diff * -1))
                /*
                for i in tar.count-(diff * -1)..<tar.count {
                    tar[i] = .zero
                }
                 */
            } else if diff > 0 {
                val.appendZeroValues(amount: diff)
            }
            value = val as! V
            target = tar as! V
        }
    }
}

internal extension PropertyAnimator {
    /// The current decay animation for the property at the keypath, or `nil` if there isn't an animation for the keypath.
    func decayAnimation<Val>(for keyPath: WritableKeyPath<Object, Val?>, key: String? = nil) -> DecayAnimator<Val>? {
        return animations[key ?? keyPath.stringValue] as? DecayAnimator<Val>
    }
    
    /// The current decay animation for the property at the keypath, or `nil` if there isn't an animation for the keypath.
    func decayAnimation<Val>(for keyPath: WritableKeyPath<Object, Val>, key: String? = nil) -> DecayAnimator<Val>? {
        return animations[key ?? keyPath.stringValue] as? DecayAnimator<Val>
    }
    
    /// The current easing animation for the property at the keypath, or `nil` if there isn't an animation for the keypath.
    func easingAnimation<Val>(for keyPath: WritableKeyPath<Object, Val?>, key: String? = nil) -> EasingAnimator<Val>? {
        return animations[key ?? keyPath.stringValue] as? EasingAnimator<Val>
    }
    
    /// The current easing animation for the property at the keypath, or `nil` if there isn't an animation for the keypath.
    func easingAnimation<Val>(for keyPath: WritableKeyPath<Object, Val>, key: String? = nil) -> EasingAnimator<Val>? {
        return animations[key ?? keyPath.stringValue] as? EasingAnimator<Val>
    }
}

#endif
