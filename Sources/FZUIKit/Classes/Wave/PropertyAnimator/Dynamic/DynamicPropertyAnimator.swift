//
//  DynamicPropertyAnimator.swift
//  
//
//  Created by Florian Zand on 07.11.23.
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

 All properties conforming to `AnimatableProperty` can be animated. A property can be accessed dynamically by writting it's name.
 
 ```swift
 public class MyObject: AnimatablePropertyProvider {
    var floatValue: CGFloat = 1.0
    var color: NSColor = .red
 }
 
 let object = MyObject()
 Wave.animate(withSpring: .smooth) {
    object.animator.floatValue = newFloat
    object.animator.color = newColor
 }
 ```
 
 To integralize a value  to the screen's pixel boundaries when animating, use it's keyPath and `integralizeValue`.  This helps prevent drawing frames between pixels, causing aliasing issues. Note: Enabling it effectively quantizes values, so don't use this for values that are supposed to be continuous.
 
 ```swift
 self[\.myAnimatableProperty, integralizeValue: true] = newValue
 ```
 
 */
@dynamicMemberLookup
public class DynamicPropertyAnimator<Object: AnyObject> {
    internal var object: Object
    
    internal init(_ object: Object) {
        self.object = object
    }
    
    /// A dictionary containing the current animated property keys and associated animations.
    public var animations: [String: AnimationProviding] = [:]
    
    /**
     The current value of the property at the specified keypath. Assigning a new value inside a ``Wave`` animation block animates to the new value.
     
     - Parameters keyPath: The keypath to the animatable property.
     */
    public subscript<Value>(dynamicMember member: WritableKeyPath<Object, Value>) -> Value where Value: AnimatableProperty  {
        get { value(for: member) }
        set { setValue(newValue, for: member) }
    }

    /**
     The current value of the property at the specified keypath. Assigning a new value inside a ``Wave`` animation block animates to the new value.
     
     - Parameters:
        - keyPath: The keypath to the animatable property.
        - integralizeValue: A Boolean value that indicates whether new values should be integralized to the screen's pixel boundaries while animating. This helps prevent drawing frames between pixels, causing aliasing issues. The default value is `false`.
     */
    subscript<Value: AnimatableProperty>(keyPath: WritableKeyPath<Object, Value>) -> Value {
        get { value(for: keyPath) }
        set { setValue(newValue, for: keyPath) }
    }
    
    /**
     The current animation velocity of the property at the specified keypath, or `zero` if there isn't an animation for the property or the animation doesn't support velocity values.

     - Parameters velocity: The keypath to the animatable property for the velocity.
     */
    public subscript<Value: AnimatableProperty>(velocity velocity: WritableKeyPath<Object, Value>) -> Value {
        get { ((self.animation(for: velocity)?.velocity as? Value)) ?? .zero  }
        set { self.animation(for: velocity)?.setVelocity(newValue) }
    }
    
    /**
     The current animation for the property at the specified keypath.
     
     - Parameters keyPath: The keypath to an animatable property.
     */
    public func animation(for keyPath: PartialKeyPath<DynamicPropertyAnimator>) -> AnimationProviding? {
        var key = keyPath.stringValue
        if let animation = self.animations[key] {
            return animation
        } else if key.contains("layer."), let viewAnimator = self as? DynamicPropertyAnimator<NSUIView> {
            key = key.replacingOccurrences(of: "layer.", with: "")
            return viewAnimator.object.optionalLayer?.animator.animations[key]
        }
        return nil
    }
    
    /// The current animation velocity for the property at the specified keypath, or `nil` if there isn't an animation for the keypath or the animation doesn't support velocity values.
    public func animationVelocity<Value: AnimatableProperty>(for keyPath: WritableKeyPath<DynamicPropertyAnimator, Value>) -> Value? {
        return (self.animation(for: keyPath) as? any ConfigurableAnimationProviding)?.velocity as? Value
    }
}

internal extension DynamicPropertyAnimator {
    /// The current value of the property at the keypath. If the property is currently animated, it returns the animation target value.
    func value<Value: AnimatableProperty>(for keyPath: WritableKeyPath<Object, Value>) -> Value {
        if AnimationController.shared.currentAnimationParameters?.animationType.isAnyVelocity == true {
            return (self.animation(for: keyPath)?.velocity as? Value) ?? .zero
        }
        return (self.animation(for: keyPath)?.target as? Value) ?? object[keyPath: keyPath]
    }
    
    /// Animates the value of the property at the keypath to a new value.
    func setValue<Value: AnimatableProperty>(_ newValue: Value, for keyPath: WritableKeyPath<Object, Value>, completion: (()->())? = nil)  {
        guard let settings = AnimationController.shared.currentAnimationParameters, settings.isAnimation else {
            self.animation(for: keyPath)?.stop(at: .current, immediately: true)
            self.object[keyPath: keyPath] = newValue
            return
        }
        
        guard value(for: keyPath) != newValue || settings.animationType.isNonAnimated else {
            return
        }
        
        var initialValue = object[keyPath: keyPath]
        var targetValue = newValue
        updateValue(&initialValue, target: &targetValue)
        
        AnimationController.shared.executeHandler(uuid: animation(for: keyPath)?.groupUUID, finished: false, retargeted: true)
        
        switch settings.animationType {
        case .spring(_,_):
            let animation = springAnimation(for: keyPath) ?? SpringAnimation<Value>(spring: .smooth, value: initialValue, target: targetValue)
            configurateAnimation(animation, target: targetValue, keyPath: keyPath, settings: settings, completion: completion)
        case .easing(_,_):
            let animation = easingAnimation(for: keyPath) ?? EasingAnimation<Value>(timingFunction: .linear, duration: 1.0, value: initialValue, target: targetValue)
            configurateAnimation(animation, target: targetValue, keyPath: keyPath, settings: settings, completion: completion)
        case .decay(_,_):
            let animation = decayAnimation(for: keyPath) ?? DecayAnimation<Value>(value: initialValue, target: targetValue)
            configurateAnimation(animation, target: targetValue, keyPath: keyPath, settings: settings, completion: completion)
        case .velocityUpdate:
            animation(for: keyPath)?.setVelocity(targetValue)
        case .nonAnimated:
            break
        }
    }
    
    /// Configurates an animation and starts it.
    func configurateAnimation<Value>(_ animation: some ConfigurableAnimationProviding<Value>, target: Value, keyPath: WritableKeyPath<Object, Value>, settings: AnimationController.AnimationParameters, completion: (()->())? = nil) {
        var animation = animation
        animation.reset()
        if settings.animationType.isDecayVelocity, let animation = animation as? DecayAnimation<Value> {
            animation.velocity = target
            animation._fromVelocity = animation._velocity
        } else {
            animation.target = target
        }
        animation.fromValue = animation.value
        animation.configure(withSettings: settings)
        animation.valueChanged = { [weak self] value in
            self?.object[keyPath: keyPath] = value
        }
        #if os(iOS) || os(tvOS)
        if settings.preventUserInteraction {
            (self as? DynamicPropertyAnimator<UIView>)?.preventingUserInteractionAnimations.insert(animation.id)
        } else {
            (self as? DynamicPropertyAnimator<UIView>)?.preventingUserInteractionAnimations.remove(animation.id)
        }
        #endif
        
        let animationKey = keyPath.stringValue
        animation.completion = { [weak self] event in
            switch event {
            case .finished:
                completion?()
                self?.animations[animationKey] = nil
                #if os(iOS) || os(tvOS)
                (self as? DynamicPropertyAnimator<UIView>)?.preventingUserInteractionAnimations.remove(animation.id)
                #endif
                AnimationController.shared.executeHandler(uuid: animation.groupUUID, finished: true, retargeted: false)
            default:
                break
            }
        }
        if let oldAnimation = animations[animationKey], oldAnimation.id != animation.id {
            oldAnimation.stop(at: .current, immediately: true)
        }
        animations[animationKey] = animation
        animation.start(afterDelay: settings.delay)
    }
    
    /// Updates the value and target of an animatable property for better animations.
    func updateValue<V: AnimatableProperty>(_ value: inout V, target: inout V) {
        if V.self == CGColor.self {
            let color = value as! CGColor
            let targetColor = target as! CGColor
            if color.alpha == 0.0 {
                value = (targetColor.copy(alpha: 0.0) ?? .clear) as! V
            }
            if targetColor.alpha == 0.0 {
                target = (color.copy(alpha: 0.0) ?? .clear) as! V
            }
        } else if var collection = value as? any AnimatableCollection, var targetCollection = target as? any AnimatableCollection, collection.count != targetCollection.count {
            collection.makeAnimatable(to: &targetCollection)
            value = collection as! V
            target = targetCollection as! V
        }
    }
}

internal extension DynamicPropertyAnimator {
    /// The current animation for the property at the keypath or key, or `nil` if there isn't an animation for the keypath.
    func animation<Val>(for keyPath: WritableKeyPath<Object, Val>) -> (any ConfigurableAnimationProviding)? {
        return animations[keyPath.stringValue] as? any ConfigurableAnimationProviding
    }
    
    /// The current spring animation for the property at the keypath or key, or `nil` if there isn't a spring animation for the keypath.
    func springAnimation<Val>(for keyPath: WritableKeyPath<Object, Val?>) -> SpringAnimation<Val>? {
        return self.animation(for: keyPath) as? SpringAnimation<Val>
    }
    
    /// The current spring animation for the property at the keypath or key, or `nil` if there isn't a spring animation for the keypath.
    func springAnimation<Val>(for keyPath: WritableKeyPath<Object, Val>) -> SpringAnimation<Val>? {
        return self.animation(for: keyPath) as? SpringAnimation<Val>
    }
    
    /// The current easing animation for the property at the keypath or key, or `nil` if there isn't an easing animation for the keypath.
    func easingAnimation<Val>(for keyPath: WritableKeyPath<Object, Val?>) -> EasingAnimation<Val>? {
        return self.animation(for: keyPath) as? EasingAnimation<Val>
    }
    
    /// The current easing animation for the property at the keypath or key, or `nil` if there isn't an easing animation for the keypath.
    func easingAnimation<Val>(for keyPath: WritableKeyPath<Object, Val>) -> EasingAnimation<Val>? {
        return self.animation(for: keyPath) as? EasingAnimation<Val>
    }
    
    /// The current decay animation for the property at the keypath or key, or `nil` if there isn't a decay animation for the keypath.
    func decayAnimation<Val>(for keyPath: WritableKeyPath<Object, Val?>) -> DecayAnimation<Val>? {
        return self.animation(for: keyPath) as? DecayAnimation<Val>
    }
    
    /// The current decay animation for the property at the keypath or key, or `nil` if there isn't a decay animation for the keypath.
    func decayAnimation<Val>(for keyPath: WritableKeyPath<Object, Val>) -> DecayAnimation<Val>? {
        return self.animation(for: keyPath) as? DecayAnimation<Val>
    }
}

#endif


/*
/**
 The current value of the property at the specified keypath. Assigning a new value inside a ``Wave`` animation block animates to the new value.
 
 - Parameters keyPath: The keypath to the animatable property.
 */
public subscript<Value>(dynamicMember member: WritableKeyPath<Object, Value?>) -> Value? where Value: AnimatableProperty  {
    get { value(for: member) }
    set { setValue(newValue, for: member) }
}
 
 /**
  The current value of the property at the specified keypath. Assigning a new value inside a ``Wave`` animation block animates to the new value.
  
  - Parameters:
     - keyPath: The keypath to the animatable property.
     - integralizeValue: A Boolean value that indicates whether new values should be integralized to the screen's pixel boundaries while animating. This helps prevent drawing frames between pixels, causing aliasing issues. The default value is `false`.
  */
 subscript<Value: AnimatableProperty>(keyPath: WritableKeyPath<Object, Value?>) -> Value? {
     get { value(for: keyPath) }
     set { setValue(newValue, for: keyPath) }
 }
 
 /**
  The current animation velocity of the property at the specified keypath, or `zero` if there isn't an animation for the property or the animation doesn't support velocity values.

  - Parameters velocity: The keypath to the animatable property for the velocity.
  */
 public subscript<Value: AnimatableProperty>(velocity velocity: WritableKeyPath<Object, Value?>) -> Value {
     get { ((self.animation(for: velocity)?.velocity as? Value)) ?? .zero  }
     set { self.animation(for: velocity)?.setVelocity(newValue) }
 }
 
 /// The current animation velocity for the property at the specified keypath, or `nil` if there isn't an animation for the keypath or the animation doesn't support velocity values.
 public func animationVelocity<Value: AnimatableProperty>(for keyPath: KeyPath<DynamicPropertyAnimator, Value?>) -> Value? {
     return (self.animation(for: keyPath) as? any ConfigurableAnimationProviding)?.velocity as? Value
 }
 */


/*
/// The current value of the property at the keypath. If the property is currently animated, it returns the animation target value.
func value<Value: AnimatableProperty>(for keyPath: WritableKeyPath<Object, Value?>) -> Value?  {
    if AnimationController.shared.currentAnimationParameters?.animationType.isAnyVelocity == true {
        return (self.animation(for: keyPath)?.velocity as? Value) ?? .zero
    }
    return (self.animation(for: keyPath)?.target as? Value) ?? object[keyPath: keyPath]
}
 
 /// Animates the value of the property at the keypath to a new value.
 func setValue<Value: AnimatableProperty>(_ newValue: Value?, for keyPath: WritableKeyPath<Object, Value?>, completion: (()->())? = nil)  {
     guard let settings = AnimationController.shared.currentAnimationParameters else {
         Wave.nonAnimate { self.setValue(newValue, for: keyPath) }
         return
     }
     
     guard settings.animationType.isVelocityUpdate == false else {
         self.animation(for: keyPath)?.setVelocity(newValue ?? .zero)
         return
     }
     
     guard value(for: keyPath) != newValue || settings.animationType.isNonAnimated else {
         return
     }
     
     var initialValue = object[keyPath: keyPath] ?? Value.zero
     var targetValue = newValue ?? Value.zero
     updateValue(&initialValue, target: &targetValue)
     
     AnimationController.shared.executeHandler(uuid: animation(for: keyPath)?.groupUUID, finished: false, retargeted: true)
     
     switch settings.animationType {
     case .spring(_,_):
         let animation = springAnimation(for: keyPath) ?? SpringAnimation<Value>(spring: .smooth, value: initialValue, target: targetValue)
         configurateAnimation(animation, target: targetValue, keyPath: keyPath, settings: settings, completion: completion)
     case .easing(_,_):
         let animation = easingAnimation(for: keyPath) ?? EasingAnimation<Value>(timingFunction: .linear, duration: 1.0, value: initialValue, target: targetValue)
         configurateAnimation(animation, target: targetValue, keyPath: keyPath, settings: settings, completion: completion)
     case .decay(_,_):
         let animation = decayAnimation(for: keyPath) ?? DecayAnimation<Value>(value: initialValue, target: targetValue)
         configurateAnimation(animation, target: targetValue, keyPath: keyPath, settings: settings, completion: completion)
     case .nonAnimated:
         self.animation(for: keyPath)?.stop(at: .current, immediately: true)
         self.animations[keyPath.stringValue] = nil
         self.object[keyPath: keyPath] = newValue
     case .velocityUpdate:
         break
     }
 }
 */
