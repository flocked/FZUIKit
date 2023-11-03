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
 
 To integralize a value  to the screen's pixel boundaries when animating, use `integralizeValues`.  This helps prevent drawing frames between pixels, causing aliasing issues. Note: Enabling it effectively quantizes values, so don't use this for values that are supposed to be continuous.
 
 ```swift
 self[\.myAnimatableProperty, integralizeValues: true] = newValue
 ```
 */

// @dynamicMemberLookup
public class PropertyAnimator<Object: AnimatablePropertyProvider> {
    internal var object: Object
    
    internal init(_ object: Object) {
        self.object = object
    }
    
    internal var animations: [String: AnimationProviding] {
        get { getAssociatedValue(key: "animations", object: self, initialValue: [:]) }
        set { set(associatedValue: newValue, key: "animations", object: self) }
    }
    
    /*
    public subscript<Value>(dynamicMember member: WritableKeyPath<Object, Value>) -> Value where Value: AnimatableData  {
        get { value(for: member, key: nil) }
        set { setValue(newValue, for: member) }
    }
    
    public subscript<Value>(dynamicMember member: WritableKeyPath<Object, Value?>) -> Value? where Value: AnimatableData  {
        get { value(for: member, key: nil) }
        set { setValue(newValue, for: member) }
    }
     */
}

public extension PropertyAnimator {
    subscript<Value: AnimatableData>(keyPath: WritableKeyPath<Object, Value>, integralizeValues integralizeValues: Bool = false) -> Value {
        get { value(for: keyPath) }
        set { setValue(newValue, for: keyPath, integralizeValues: integralizeValues) }
    }
    
    subscript<Value: AnimatableData>(keyPath: WritableKeyPath<Object, Value>, integralizeValues integralizeValues: Bool = false, epsilon epsilon: Double? = nil) -> Value  where Value: ApproximateEquatable {
        get { value(for: keyPath) }
        set { setValue(newValue, for: keyPath, epsilon: epsilon, integralizeValues: integralizeValues) }
    }
    
    subscript<Value: AnimatableData>(keyPath: WritableKeyPath<Object, Value?>, integralizeValues integralizeValues: Bool = false) -> Value? {
        get { value(for: keyPath) }
        set { setValue(newValue, for: keyPath, integralizeValues: integralizeValues) }
    }
    
    subscript<Value: AnimatableData>(keyPath: WritableKeyPath<Object, Value?>, integralizeValues integralizeValues: Bool = false, epsilon epsilon: Double? = nil) -> Value? where Value: ApproximateEquatable {
        get { value(for: keyPath) }
        set { setValue(newValue, for: keyPath, epsilon: epsilon, integralizeValues: integralizeValues) }
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
    func animation<Val>(for keyPath: WritableKeyPath<Object, Val?>, key: String? = nil) -> SpringAnimator<Val>? {
        return animations[key ?? keyPath.stringValue] as? SpringAnimator<Val>
    }
    
    func animation<Val>(for keyPath: WritableKeyPath<Object, Val>, key: String? = nil) -> SpringAnimator<Val>? {
        return animations[key ?? keyPath.stringValue] as? SpringAnimator<Val>
    }
    
    func value<Value: AnimatableData>(for keyPath: WritableKeyPath<Object, Value>, key: String? = nil) -> Value {
        return animation(for: keyPath, key: key)?.target ?? object[keyPath: keyPath]
    }
    
    func value<Value: AnimatableData>(for keyPath: WritableKeyPath<Object, Value?>, key: String? = nil) -> Value?  {
        return animation(for: keyPath, key: key)?.target ?? object[keyPath: keyPath]
    }
    
    func setValue<Value: AnimatableData>(_ newValue: Value, for keyPath: WritableKeyPath<Object, Value>, key: String? = nil, epsilon: Double? = nil, integralizeValues: Bool = false, completion: (()->())? = nil)  {
        guard let settings = AnimationController.shared.currentAnimationParameters else {
            Wave.animate(withSpring: .nonAnimated) {
                self.setValue(newValue, for: keyPath, key: key)
            }
            return
        }
        
        guard value(for: keyPath, key: key) != newValue || (settings.spring == .nonAnimated && animation(for: keyPath, key: key) != nil) else {
            return
        }
        
        var initialValue = object[keyPath: keyPath]
        var targetValue = newValue
        updateValue(&initialValue, target: &targetValue)
        
        AnimationController.shared.executeHandler(uuid: animation(for: keyPath, key: key)?.groupUUID, finished: false, retargeted: true)

        let animation = (animation(for: keyPath, key: key) ?? SpringAnimator<Value>(spring: settings.spring, value: initialValue, target: targetValue))
        animation.epsilon = epsilon
        animation.integralizeValues = integralizeValues
        animation.configure(withSettings: settings)
        if let gestureVelocity = settings.gestureVelocity {
            (animation as? SpringAnimator<CGRect>)?.velocity.origin = gestureVelocity
            (animation as? SpringAnimator<CGPoint>)?.velocity = gestureVelocity
        }
        animation.target = targetValue
        animation.valueChanged = { [weak self] value in
            self?.object[keyPath: keyPath] = value
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
    
    func setValue<Value: AnimatableData>(_ newValue: Value?, for keyPath: WritableKeyPath<Object, Value?>, key: String? = nil, epsilon: Double? = nil, integralizeValues: Bool = false, completion: (()->())? = nil)  {
        guard let settings = AnimationController.shared.currentAnimationParameters else {
            Wave.animate(withSpring: .nonAnimated) {
                self.setValue(newValue, for: keyPath, key: key)
            }
            return
        }
        
        guard value(for: keyPath, key: key) != newValue || (settings.spring == .nonAnimated && animation(for: keyPath, key: key) != nil) else {
            return
        }
        
        var initialValue = object[keyPath: keyPath] ?? Value.zero
        var targetValue = newValue ?? Value.zero
        updateValue(&initialValue, target: &targetValue)
        
        AnimationController.shared.executeHandler(uuid: animation(for: keyPath, key: key)?.groupUUID, finished: false, retargeted: true)
        
        let animation = (animation(for: keyPath, key: key) ?? SpringAnimator<Value>(spring: settings.spring, value: initialValue, target: targetValue))
        animation.epsilon = epsilon
        animation.integralizeValues = integralizeValues
        animation.configure(withSettings: settings)
        if let gestureVelocity = settings.gestureVelocity {
            (animation as? SpringAnimator<CGRect>)?.velocity.origin = gestureVelocity
            (animation as? SpringAnimator<CGPoint>)?.velocity = gestureVelocity
        }
        animation.target = targetValue
        animation.valueChanged = { [weak self] value in
            self?.object[keyPath: keyPath] = value
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
    
    
    
    func configurateAnimation<V: AnimatableData>(_ animation: SpringAnimator<V>, value: V, target: V, key: String, settings: AnimationController.AnimationParameters) {
        animation.configure(withSettings: settings)
        animation.target = target
        if let gestureVelocity = settings.gestureVelocity {
            (animation as? SpringAnimator<CGRect>)?.velocity.origin = gestureVelocity
            (animation as? SpringAnimator<CGPoint>)?.velocity = gestureVelocity
        }
    }

    func updateValue<V: AnimatableData>(_ value: inout V, target: inout V) {
        if var val = value as? [Double], var tar = target as? [Double], val.count != tar.count {
            let diff = tar.count - val.count
            if diff < 0 {
                for i in tar.count-(diff * -1)..<tar.count {
                    tar[i] = .zero
                }
            } else if diff > 0 {
                val.append(contentsOf: Array(repeating: .zero, count: diff))
            }
            value = val as! V
            target = tar as! V
        } else if V.self == CGColor.self {
            let val = (value as! CGColor).nsUIColor
            let tar = (target as! CGColor).nsUIColor
            if val?.isVisible == false {
                value = (tar?.withAlphaComponent(0.0).cgColor ?? .clear) as! V
            }
            if tar?.isVisible == false {
                target = (tar?.withAlphaComponent(0.0).cgColor ?? .clear) as! V
            }
        }
    }
}

#endif

/*
 func setValue<Value: AnimatableData>(_ newValue: Value, for keyPath: WritableKeyPath<Object, Value>, key: String? = nil, epsilon: Double? = nil, integralizeValues: Bool = false, completion: (()->())? = nil) where Value: ApproximateEquatable {
     setValue(newValue, for: keyPath, key: key, integralizeValues: integralizeValues, completion: completion)
     animation(for: keyPath, key: key)?.epsilon = epsilon
 }
 
 func setValue<Value: AnimatableData>(_ newValue: Value?, for keyPath: WritableKeyPath<Object, Value?>, key: String? = nil, epsilon: Double? = nil, integralizeValues: Bool = false, completion: (()->())? = nil) where Value: ApproximateEquatable  {
     setValue(newValue, for: keyPath, key: key, integralizeValues: integralizeValues, completion: completion)
     animation(for: keyPath, key: key)?.epsilon = epsilon
 }
 */

/*
 internal enum AnimationType {
    case spring
 }
 var animationType: AnimationType
 
 func newAnimation<Val>(value: Val, target: Val, type: AnimationType) where Val: A {
 switch type {
 case .spring(let spring):
    return SpringAnimator<Value>(spring: spring, value: value, target: target))
 }
 }
 
 func animation<Val>(for keyPath: WritableKeyPath<Object, Val>, key: String? = nil, type: AnimationType?) -> SpringAnimator<Val>? {
 if let type = type {
    switch type {
    case .spring(_):
        return animations[key ?? keyPath.stringValue] as? SpringAnimator<Val>
    }
} else {
    return animations[key ?? keyPath.stringValue]
 }
 }
 */

